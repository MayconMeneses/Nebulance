extends RefCounted
## Fase 16 (O Labirinto Magnetico): polaridade (alavancas alternam), esteira que inverte, reinicio e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> MecatronLevel16:
	var level := MecatronLevel16.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel16 = _level(tree)
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-043 fase 16: tudo comeca em polaridade desligada (elevador embaixo, trilho a esquerda, esteira contraria)",
			level.lift_up.progress == 0.0 and level.rail.progress == 0.0 and level.lift_down.progress == 0.0 and level.belt.effective_direction() < 0.0)
	level.rail.control.interact()
	await _settle(tree, 200)
	TestWorld.rec(out, "TC-043 fase 16: ligar a polaridade do trilho o leva 7 m a direita", level.rail.progress == 1.0 and is_equal_approx(level.rail.position.x, 37.5))
	level.rail.control.interact()
	await _settle(tree, 200)
	TestWorld.rec(out, "TC-043 fase 16: inverter a polaridade (E de novo) devolve o trilho", level.rail.progress == 0.0 and is_equal_approx(level.rail.position.x, 30.5))
	level.lift_down.control.interact()
	await _settle(tree, 200)
	TestWorld.rec(out, "TC-043 fase 16: o elevador de descida desce 5 m", level.lift_down.progress == 1.0 and is_equal_approx(level.lift_down.position.y, -0.2))
	TestWorld.rec(out, "TC-043 fase 16: a esteira rapida (6 m/s) vence a corrida de Rocco (5,5) enquanto contraria",
			level.belt.speed > level.rig.profiles[0].tuning.run_speed and level.belt.effective_direction() < 0.0)
	level.lever_belt.interact()
	TestWorld.rec(out, "TC-043 fase 16: a alavanca do chao inverte o sentido da esteira", level.belt.effective_direction() > 0.0
			and level.belt.constant_linear_velocity.x < 0.0)
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-043 fase 16: a esteira aplica o novo sentido no passo de fisica seguinte", level.belt.constant_linear_velocity.x > 0.0)
	level.rig.body.global_position = Vector3(42.0, 7.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-043 fase 16: reaparecer reinicia todas as polaridades (idempotente)", level.rail.progress == 0.0 and level.lift_down.progress == 0.0
			and level.belt.effective_direction() < 0.0 and not level.lever_belt.is_active)
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel16 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot16.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 16 (tres plataformas de polaridade e esteira invertida) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f)" % [bot.stage, bot.x(), bot.body.global_position.y])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 16 com 9 moedas, o amuleto, a pista da Oficina Zero, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["mecatron_16_magnet_charm"] and c.session.lives_lost == 0
				and "memory_workshop_clue_16" in c.session.memory_ids and level.save["economy"]["best_grade_by_level"].get("mecatron_16") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
