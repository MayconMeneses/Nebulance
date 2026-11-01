extends RefCounted
## Fase 22 (A Onda Colossal): onda que so avanca apos o gatilho, barreira de Rocco, resgate opcional, reinicio idempotente no checkpoint e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> AquarysLevel22:
	var level := AquarysLevel22.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel22 = _level(tree)
	await _settle(tree, 3)
	var w: ChaseWave = level.wave
	TestWorld.rec(out, "fase 22: a onda comeca parada atras do ponto de partida e desarmada, sem ferir quem anda pelo trecho inicial",
			not w.running and is_equal_approx(w.position.x, w.start_x) and w.start_x < level.rig.body.global_position.x - 2.0)
	TestWorld.rec(out, "fase 22: a barreira marcada so cede ao impacto e o sobrevivente (resgate opcional) esta inteiro e disponivel",
			not level.barrier.is_broken and level.survivor.can_interact() and "aquarys_22_survivor" in level.definition.rescue_ids)
	level.rig.body.global_position = Vector3(34.0, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 4)
	TestWorld.rec(out, "fase 22: o checkpoint vem antes do gatilho da onda", level.rig.last_checkpoint_id == &"aquarys_22_cp1" and 34.0 < w.trigger_x)
	level.rig.body.global_position = Vector3(44.6, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 60)
	TestWorld.rec(out, "fase 22: ao passar do gatilho a onda avanca a 7 m/s", w.running and w.position.x > w.start_x + 3.0 and is_equal_approx(w.speed, 7.0),
			"(x=%.1f)" % w.position.x)
	level.barrier.on_impacted()
	level.survivor.interact()
	for round_index in 2:
		level.controller._on_life_lost(&"test")
		# A restauracao e sincrona; o heroi volta ao checkpoint (antes do gatilho) e a onda continua parada.
		level.rig.body.respawn(level.rig.checkpoint_position)
		await _settle(tree, 3)
		TestWorld.rec(out, "TC-013 fase 22: reaparecer (%da vez) no checkpoint desarma e reposiciona a onda e devolve barreira e resgate" % (round_index + 1),
				not w.running and is_equal_approx(w.position.x, w.start_x) and not level.barrier.is_broken and not level.survivor.is_rescued
				and level.rig.body.global_position.x < w.trigger_x,
				"(run=%s wx=%.1f quebrada=%s resgatado=%s hx=%.1f)" % [w.running, w.position.x, level.barrier.is_broken, level.survivor.is_rescued, level.rig.body.global_position.x])
		level.barrier.on_impacted()
		level.survivor.interact()
	level.queue_free()
	# O heroi liberado ainda existe neste quadro e coletaria as moedas da proxima instancia (mesmas coordenadas no mundo de fisica).
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel22 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot22.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 22 (barreira, muro, planeio com vento, resgate, laje, bau) fugindo da onda sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 22 com a onda em movimento e sempre a mais de 3 m do heroi",
				level.wave.running and bot.min_gap > 3.0, "(menor distancia=%.1f onda x=%.1f)" % [bot.min_gap, level.wave.position.x])
		TestWorld.rec(out, "bot: fase 22 com 9 moedas, sobrevivente resgatado, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.rescued_ids == ["aquarys_22_survivor"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("aquarys_22") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
