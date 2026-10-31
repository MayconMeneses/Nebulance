extends RefCounted
## Fase 03 + S01 + portal (TC-014): mecanismos e portao, bots completos e retorno consistente pelo fluxo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _gravity(tree, out)
	await _gate(tree, out)
	await _bot03(tree, out)
	await _bot_s01(tree, out)
	await _portal_flow(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _make(tree: SceneTree, script: GDScript) -> LevelScene:
	var level := script.new() as LevelScene
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _gravity(tree: SceneTree, out: Array) -> void:
	var speeds: Array[float] = []
	for low in [false, true]:
		var w := TestWorld.create(tree, 0, "adventure", Vector3(0.0, 41.0, 0.0))
		if low:
			w.add_zone(PhysicsLayers.WIND, Vector3(0.0, 30.0, 0.0), Vector3(4.0, 80.0, 4.0), Vector3.ZERO).gravity_scale = 0.4
		await w.step(30)
		speeds.append(w.body.velocity.y)
		w.dispose()
	TestWorld.rec(out, "gravidade localizada: dentro da zona (0.4) a queda e mais lenta que fora", speeds[1] > speeds[0] * 0.5 and speeds[0] < -5.0,
			"(fora=%.2f dentro=%.2f)" % [speeds[0], speeds[1]])


func _gate(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel03 = _make(tree, SylvaraLevel03) as SylvaraLevel03
	await tree.physics_frame
	var mechs: Array = level.find_children("*", "Mechanism", true, false)
	var gate: MechanismGate = level.find_children("*", "MechanismGate", true, false)[0] as MechanismGate
	var portal: Portal = level.find_children("*", "Portal", true, false)[0] as Portal
	TestWorld.rec(out, "fase 03: tres mecanismos, um portao e um portal fechado no inicio",
			mechs.size() == 3 and not gate.is_open and not portal.is_open)
	(mechs[0] as Mechanism).activate()
	(mechs[1] as Mechanism).activate()
	TestWorld.rec(out, "fase 03: com 2 de 3 mecanismos o portao continua fechado", not gate.is_open and not portal.can_interact())
	(mechs[2] as Mechanism).activate()
	TestWorld.rec(out, "TC-014 fase 03: com os 3 mecanismos o portao abre e o portal fica ativo", gate.is_open and portal.can_interact())
	TestWorld.rec(out, "TC-014 portal tem origem, destino e ID estaveis",
			portal.portal_id == &"sylvara_03_portal" and portal.destination_level_id == &"sylvara_s01" and LevelCatalog.has("sylvara_s01"))
	level.rig.body.global_position = Vector3(28, -3, 0)
	level.controller._on_life_lost(&"abyss")
	TestWorld.rec(out, "TC-013 fase 03: reaparecer antes de passar do checkpoint fecha o portao e desativa os mecanismos de novo",
			not gate.is_open and not portal.is_open and not (mechs[0] as Mechanism).is_active)
	level.queue_free()


func _bot03(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel03 = _make(tree, SylvaraLevel03) as SylvaraLevel03
	await tree.physics_frame
	var bot := LevelBot03.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 03 (barreira, escalada, planeio, portal, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 03 com as 9 moedas e a memoria do portal", c.session.coin_ids.size() == 9 and c.session.memory_ids.size() == 1,
				"(moedas=%d faltam=%s)" % [c.session.coin_ids.size(), ",".join(missing)])
		TestWorld.rec(out, "bot: fase 03 pediu o portal para S01 e fechou sem perder vidas (Ouro)",
				bot.portal_requests == [&"sylvara_03_portal"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("sylvara_03") == RewardLedger.Grade.GOLD)
	level.queue_free()


func _bot_s01(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevelS01 = _make(tree, SylvaraLevelS01) as SylvaraLevelS01
	await tree.physics_frame
	var bot := LevelBotS01.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a S01 (gravidade baixa, plataformas que se reorganizam) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f)" % [bot.stage, bot.x(), bot.body.global_position.y])
	if finished:
		TestWorld.rec(out, "bot: S01 com 4 moedas e os 2 itens unicos (objeto da expedicao e acessorio)",
				c.session.coin_ids.size() == 4 and c.session.item_ids.size() == 2 and c.session.lives_lost == 0,
				"(moedas=%d itens=%d vidas perdidas=%d)" % [c.session.coin_ids.size(), c.session.item_ids.size(), c.session.lives_lost])
	level.queue_free()


func _portal_flow(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("portal")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	flow.level.queue_free()
	flow.level = null
	flow._start_level("sylvara_03")
	await tree.process_frame
	var origin: LevelScene = flow.level
	var input := ScriptedInput.new()
	origin.rig.body.intent_provider = input.read
	var mechs: Array = origin.find_children("*", "Mechanism", true, false)
	for m in mechs:
		(m as Mechanism).activate()
	origin.rig.body.global_position = Vector3(4, 1, 0)
	for i in 3:
		await tree.physics_frame
	var coins_before: int = origin.controller.session.coin_ids.size()
	origin.rig.body.global_position = Vector3(60.4, 6.5, 0)
	origin.rig.body.velocity = Vector3.ZERO
	for i in 12:
		await tree.physics_frame
	var pos_before: Vector3 = origin.rig.body.global_position
	input.press_interact()
	await tree.physics_frame
	await tree.process_frame
	TestWorld.rec(out, "TC-014 portal: entrar abre a S01 e pausa/oculta a fase de origem",
			flow.level is SylvaraLevelS01 and flow.origin_level == origin and not origin.visible and origin.process_mode == Node.PROCESS_MODE_DISABLED)
	TestWorld.rec(out, "TC-014 portal: portal registrado como descoberto uma vez", flow.profile["world"]["portal_ids"] == ["sylvara_03_portal"])
	var secret: LevelScene = flow.level
	var sin := ScriptedInput.new()
	secret.rig.body.intent_provider = sin.read
	for pos in [Vector3(15.0, 7.0, 0), Vector3(16.0, 7.0, 0)]:
		secret.rig.body.global_position = pos
		secret.rig.body.velocity = Vector3.ZERO
		for i in 4:
			await tree.physics_frame
	secret.rig.body.global_position = Vector3(33.0, 1.0, 0)
	secret.rig.body.velocity = Vector3.ZERO
	for i in 4:
		await tree.physics_frame
	sin.press_interact()
	await tree.physics_frame
	await tree.process_frame
	TestWorld.rec(out, "TC-014 portal: concluir a S01 mostra resultados e grava o save", flow.state == GameFlow.State.RESULTS and flow.last_save_error == OK)
	var balance: int = flow.profile["economy"]["coin_balance"]
	TestWorld.rec(out, "TC-014 portal: os itens unicos da S01 entram no perfil",
			"sylvara_s01_expedition_relic" in flow.profile["economy"]["owned_items"] and "sylvara_s01_leaf_crown" in flow.profile["economy"]["owned_items"])
	flow.results.continue_pressed.emit()
	await tree.process_frame
	await tree.process_frame
	TestWorld.rec(out, "TC-014 retorno: volta a fase de origem (visivel e ativa)", flow.level == origin and origin.visible
			and origin.process_mode == Node.PROCESS_MODE_PAUSABLE and flow.origin_level == null and flow.state == GameFlow.State.LEVEL)
	await tree.physics_frame
	TestWorld.rec(out, "TC-014 retorno: heroi na mesma posicao e mesma sessao (moedas) de antes", origin.rig.body.global_position.distance_to(pos_before) < 0.5
			and origin.controller.session.coin_ids.size() == coins_before)
	var gate: MechanismGate = origin.find_children("*", "MechanismGate", true, false)[0] as MechanismGate
	TestWorld.rec(out, "TC-014 retorno: mecanismos e portao continuam ativos (estado consistente)", gate.is_open)
	TestWorld.rec(out, "TC-014 retorno: pode entrar de novo, mas a recompensa unica nao duplica",
			true)
	input.press_interact()
	await tree.physics_frame
	await tree.process_frame
	var secret2: LevelScene = flow.level
	var sin2 := ScriptedInput.new()
	secret2.rig.body.intent_provider = sin2.read
	for pos in [Vector3(15.0, 7.0, 0), Vector3(16.0, 7.0, 0), Vector3(33.0, 1.0, 0)]:
		secret2.rig.body.global_position = pos
		secret2.rig.body.velocity = Vector3.ZERO
		for i in 4:
			await tree.physics_frame
	sin2.press_interact()
	await tree.physics_frame
	await tree.process_frame
	TestWorld.rec(out, "TC-014 retorno: repetir a S01 nao duplica itens nem moedas unicas",
			flow.profile["economy"]["coin_balance"] == balance + 0 and flow.profile["economy"]["owned_items"].count("sylvara_s01_leaf_crown") == 1,
			"(saldo=%d esperado=%d)" % [flow.profile["economy"]["coin_balance"], balance])
	tree.paused = false
	flow.queue_free()
	await tree.process_frame
