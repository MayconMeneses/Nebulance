extends RefCounted
## Fase 19 (A Costa das Luzes) e pecas de Aquarys: nivel discreto, plataforma que boia, passarela de mare baixa, comporta, reinicio e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> AquarysLevel19:
	var level := AquarysLevel19.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel19 = _level(tree)
	await _settle(tree, 3)
	var w: WaterBody = level.water
	TestWorld.rec(out, "TC-045 Aquarys: a mare comeca no nivel 0 (baixa), passarela solida e plataformas abaixo da praia",
			w.level == 0 and level.walkway.is_solid() and level.floaters[0].position.y < -0.1)
	w.set_level(99)
	TestWorld.rec(out, "TC-045 Aquarys: nivel fora do intervalo e limitado ao maximo (discreto, sem valores intermediarios)", w.level == w.max_level)
	w.set_level(0)
	level.raise_control.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-045 Aquarys: a superficie sobe a velocidade fixa (nao salta) ate o nivel-alvo", not w.is_settled() and w.height > w.base_y)
	await _settle(tree, 120)
	TestWorld.rec(out, "TC-045 Aquarys: na mare alta a plataforma flutuante alinha com a praia (topo em y=0) e a passarela some",
			w.is_settled() and is_equal_approx(level.floaters[0].position.y + 0.2, 0.0) and not level.walkway.is_solid())
	TestWorld.rec(out, "TC-045 Aquarys: operar a comporta no nivel que ja esta ativo nao e oferecido", not level.raise_control.can_interact() and level.lower_control.can_interact())
	level.lower_control.interact()
	await _settle(tree, 120)
	TestWorld.rec(out, "TC-045 Aquarys: baixar a mare expoe a passarela de novo", w.level == 0 and level.walkway.is_solid() and is_equal_approx(w.height, w.base_y))
	level.raise_control.interact()
	await _settle(tree, 20)
	level.rig.body.global_position = Vector3(10.0, 1.0, 0.0)
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-045 fase 19: reaparecer restaura o nivel da agua do checkpoint (idempotente, sem estado residual)", w.level == 0 and w.is_settled())
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel19 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot19.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 19 (mare alta, flutuantes, mare baixa, passarela, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f)" % [bot.stage, bot.x(), bot.body.global_position.y])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 19 com 9 moedas e o acessorio Mare Estelar, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["aquarys_19_star_tide"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("aquarys_19") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
