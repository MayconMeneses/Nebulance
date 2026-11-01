extends RefCounted
## Fase 35 (A Ultima Mensagem): puzzle-sintese das cinco mecanicas, terminal que destranca o bau, checkpoint apos a mensagem, opcao de
## acessibilidade (plataforma movel -> ponte fixa), reinicio idempotente e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _assist(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> UmbraxisLevel35:
	var level := UmbraxisLevel35.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel35 = _level(tree)
	await _settle(tree, 3)
	TestWorld.rec(out, "fase 35: as cinco mecanicas estao presentes na ordem (ponte de ruptura, plataforma movel, esteira+elevadores, mare, planeio)",
			level.bridge_mod["platforms"].size() == 3 and level.moving_mod["mp"] != null and level.belt_mod["up"] != null and level.tide_mod["control"] != null
			and level.glide_mod["len"] > 0.0 and not level.assisted)
	TestWorld.rec(out, "fase 35: o bau comeca trancado e o terminal dos exploradores o libera (estado derivado do terminal)",
			level.chest.locked and level.terminal.can_interact())
	level.rig.body.global_position = Vector3(206.0, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 4)
	TestWorld.rec(out, "fase 35: o ultimo checkpoint vem depois da mensagem, antes do chefe", level.rig.last_checkpoint_id == &"umbraxis_35_cp5"
			and 206.0 > UmbraxisLevel35.TERMINAL_X)
	level.terminal.interact()
	await _settle(tree, 2)
	TestWorld.rec(out, "fase 35: ativar o terminal destranca o bau", not level.chest.locked)
	for round_index in 2:
		level.controller._on_life_lost(&"test")
		level.rig.body.respawn(level.rig.checkpoint_position)
		await _settle(tree, 3)
		TestWorld.rec(out, "fase 35: reaparecer (%da vez) no checkpoint 5 desfaz o terminal lido depois dele e tranca o bau de novo" % (round_index + 1),
				not level.terminal.is_active and level.chest.locked and level.rig.body.global_position.x > 200.0)
		level.terminal.interact()
		await _settle(tree, 2)
	level.queue_free()
	await _settle(tree, 3)


func _assist(tree: SceneTree, out: Array) -> void:
	Accessibility.reduce_motion = true
	var level: UmbraxisLevel35 = _level(tree)
	await _settle(tree, 3)
	var ok: bool = level.assisted and level.moving_mod["mp"] == null
	Accessibility.reduce_motion = false
	TestWorld.rec(out, "fase 35: com 'reduzir movimento' a plataforma movel vira ponte fixa (opcao de acessibilidade)", ok)
	level.queue_free()
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel35 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot35.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 35 (cinco mecanicas, terminal, mensagem e bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 35 com 9 moedas e a ultima mensagem, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and "memory_last_message_35" in c.session.memory_ids and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("umbraxis_35") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
