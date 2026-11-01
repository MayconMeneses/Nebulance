extends RefCounted
## Fase 32 (As Fases Quebradas): cinco modulos de ecossistemas, checkpoints entre eles, reinicio no checkpoint do meio e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> UmbraxisLevel32:
	var level := UmbraxisLevel32.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel32 = _level(tree)
	await _settle(tree, 3)
	TestWorld.rec(out, "fase 32: os cinco modulos existem (barreira, plataforma movel, esteira+elevadores, mare, planeio) e ha 4 checkpoints entre eles",
			level.barrier_mod["barrier"] != null and level.moving_mod["mp"] != null and level.belt_mod["up"] != null and level.tide_mod["control"] != null
			and level.glide_mod["len"] > 0.0 and level.definition.checkpoint_ids.size() == 4)
	# Checkpoint do meio (modulo Aquarys): estado da mare e da barreira apos o ponto salvo.
	level.barrier_mod["barrier"].on_impacted()
	level.rig.body.global_position = Vector3(99.0, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 4)
	TestWorld.rec(out, "fase 32: alcancar o modulo de Aquarys registra o checkpoint 3", level.rig.last_checkpoint_id == &"umbraxis_32_cp3")
	level.tide_mod["control"].interact()
	await _settle(tree, 5)
	for round_index in 2:
		level.controller._on_life_lost(&"test")
		level.rig.body.respawn(level.rig.checkpoint_position)
		await _settle(tree, 3)
		TestWorld.rec(out, "TC-050 fase 32: reaparecer (%da vez) volta a mare ao nivel do checkpoint e mantem a barreira ja quebrada antes dele" % (round_index + 1),
				level.tide_mod["water"].level == 0 and level.barrier_mod["barrier"].is_broken and level.rig.body.global_position.x > 90.0)
		level.tide_mod["control"].interact()
		await _settle(tree, 2)
	level.queue_free()
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel32 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot32.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 32 (cinco modulos de ecossistemas) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 32 com 9 moedas e o registro oculto, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and "memory_hidden_record_32" in c.session.memory_ids and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("umbraxis_32") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
