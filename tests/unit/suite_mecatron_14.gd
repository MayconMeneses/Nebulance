extends RefCounted
## Fase 14 (As Esteiras de Titanio): prensas deterministicas (so ferem em DOWN, aviso >= 0,6 s), barreira de Rocco, reinicio e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_cycle(out)
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _cycle(out: Array) -> void:
	TestWorld.rec(out, "TC-042 prensa: o aviso (telegraph) dura pelo menos 0,6 s", HydraulicPress.TELEGRAPH_TIME >= 0.6)
	var seen: Array = []
	var t: float = 0.0
	while t < HydraulicPress.PERIOD:
		var s: int = HydraulicPress.state_at(t)
		if seen.is_empty() or seen[-1] != s:
			seen.append(s)
		t += 0.05
	TestWorld.rec(out, "TC-042 prensa: ciclo IDLE -> TELEGRAPH -> DOWN -> RECOVER, sempre nessa ordem", seen == [0, 1, 2, 3], "(%s)" % str(seen))
	TestWorld.rec(out, "prensa: o estado so depende do tempo (mesmo tempo, mesmo estado)", HydraulicPress.state_at(1.234) == HydraulicPress.state_at(1.234 + HydraulicPress.PERIOD * 3.0))


func _level(tree: SceneTree) -> MecatronLevel14:
	var level := MecatronLevel14.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel14 = _level(tree)
	for i in 3:
		await tree.physics_frame
	var press: HydraulicPress = level.presses[0]
	press.elapsed = HydraulicPress.IDLE_TIME - 0.1 - press.phase
	press._apply()
	TestWorld.rec(out, "TC-042 prensa: em IDLE e TELEGRAPH nao ha camada de perigo", press.state == HydraulicPress.State.IDLE and press.collision_layer == 0)
	press.elapsed = HydraulicPress.IDLE_TIME + 0.4 - press.phase
	press._apply()
	TestWorld.rec(out, "TC-042 prensa: o aviso nao fere (amarelo, sem perigo)", press.state == HydraulicPress.State.TELEGRAPH and press.collision_layer == 0)
	press.elapsed = HydraulicPress.IDLE_TIME + HydraulicPress.TELEGRAPH_TIME + 0.2 - press.phase
	press._apply()
	TestWorld.rec(out, "TC-042 prensa: em DOWN a camada de perigo esta ativa", press.state == HydraulicPress.State.DOWN and press.collision_layer == PhysicsLayers.HAZARD)
	var body: ActorController = level.rig.body
	body.respawn(Vector3(40.0, 1.0, 0.0))
	var hearts_before: int = level.rig.vitals.hearts
	press.elapsed = HydraulicPress.IDLE_TIME + HydraulicPress.TELEGRAPH_TIME + 0.05 - press.phase
	for i in 6:
		await tree.physics_frame
	TestWorld.rec(out, "TC-042 prensa: estar sob ela em DOWN custa um coracao", level.rig.vitals.hearts < hearts_before)
	press.elapsed = 0.0
	level.rig.body.global_position = Vector3(28.0, 1.0, 0.0)
	level.controller._on_life_lost(&"test")
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "TC-042 fase 14: reaparecer reinicia o ciclo das prensas e restaura a barreira", press.elapsed < 0.2 and not level.barrier.is_broken)
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel14 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot14.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 14 (barreira, esteira, escalada de Zuri, tres prensas) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 14 com 9 moedas e o item industrial, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["mecatron_14_industrial_decor"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("mecatron_14") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
