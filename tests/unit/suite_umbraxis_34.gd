extends RefCounted
## Fase 34 (A Estrada para o Coracao): prensa-raiz sinalizada, barreira de Caeldron, checkpoint antes do trecho dificil, plataformas
## temporarias, resgate opcional, reinicio idempotente e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> UmbraxisLevel34:
	var level := UmbraxisLevel34.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel34 = _level(tree)
	await _settle(tree, 3)
	TestWorld.rec(out, "fase 34: a prensa-raiz avisa (>= 0,6 s) antes de ferir e a barreira so cede ao impacto",
			HydraulicPress.TELEGRAPH_TIME >= 0.6 and not level.barrier.is_broken and level.survivor.can_interact() and "umbraxis_34_survivor" in level.definition.rescue_ids)
	level.rig.body.global_position = Vector3(34.0, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 4)
	TestWorld.rec(out, "fase 34: o checkpoint vem antes do trecho dificil (escalada, plataformas temporarias)",
			level.rig.last_checkpoint_id == &"umbraxis_34_cp1" and 34.0 < level.platforms[0].position.x)
	level.barrier.on_impacted()
	level.survivor.interact()
	await _settle(tree, 40)
	var before_loss: float = level.press.elapsed
	for round_index in 2:
		level.controller._on_life_lost(&"test")
		level.rig.body.respawn(level.rig.checkpoint_position)
		await _settle(tree, 3)
		TestWorld.rec(out, "fase 34: reaparecer (%da vez) devolve barreira e resgate ao estado do checkpoint e a prensa ao seu ciclo salvo" % (round_index + 1),
				not level.barrier.is_broken and not level.survivor.is_rescued and level.rig.body.global_position.x < 40.0
				and level.press.elapsed < before_loss - 0.4, "(prensa %.2f -> %.2f)" % [before_loss, level.press.elapsed])
		level.barrier.on_impacted()
		level.survivor.interact()
	level.queue_free()
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel34 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot34.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 34 (prensa, barreira, escaladas, plataformas temporarias, resgate, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 34 com 9 moedas e o sobrevivente resgatado, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.rescued_ids == ["umbraxis_34_survivor"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("umbraxis_34") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
