extends RefCounted
## Fase 20 (Os Canais Suspensos): escolha de nivel, passarela antes submersa, barreira de Rocco, coletavel de Zuri, reinicio e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> AquarysLevel20:
	var level := AquarysLevel20.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel20 = _level(tree)
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-046 fase 20: com a mare baixa a passarela esta exposta; com a mare alta fica submersa (rota depende do nivel)",
			level.walkway.is_solid())
	level.raise_control.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-046 fase 20: subir a mare submerge a passarela", not level.walkway.is_solid())
	await _settle(tree, 120)
	level.lower_control.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-046 fase 20: baixar a mare revela a passarela de novo", level.walkway.is_solid())
	TestWorld.rec(out, "TC-046 fase 20: a barreira marcada so cede ao impacto (existe e esta inteira)", not level.barrier.is_broken)
	level.barrier.on_impacted()
	level.raise_control.interact()
	await _settle(tree, 30)
	level.rig.body.global_position = Vector3(30.0, 1.0, 0.0)
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-046 fase 20: reaparecer devolve a mare e a barreira ao estado do checkpoint", level.water.level == 0 and not level.barrier.is_broken)
	level.queue_free()
	# O heroi liberado ainda existe neste quadro e coletaria as moedas da proxima instancia (mesmas coordenadas no mundo de fisica).
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel20 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot20.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 20 (mare alta, Zuri, mare baixa, Rocco, passarela, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 20 com 9 moedas e o coletavel, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["aquarys_20_gate_collectible"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("aquarys_20") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
