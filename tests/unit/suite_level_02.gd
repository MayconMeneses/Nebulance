extends RefCounted
## Fase 02 (A Ponte Desaparecida): plataformas de ruptura, estabilizador, reset por checkpoint e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _rupture(tree, out)
	await _stabilizer_and_checkpoint(tree, out)
	await _ids(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> SylvaraLevel02:
	var level := SylvaraLevel02.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _rupture(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel02 = _level(tree)
	await tree.physics_frame
	var p: RupturePlatform = level.find_children("*", "RupturePlatform", true, false)[0] as RupturePlatform
	var states: Array[bool] = []
	var warned_before_gone: bool = false
	var was_warning: bool = false
	for i in 600:
		await tree.physics_frame
		states.append(p.is_solid())
		if p.is_warning():
			was_warning = true
		if was_warning and not p.is_solid():
			warned_before_gone = true
		p.collision_layer = p.collision_layer
	var solid_frames: int = states.count(true)
	var cycle: int = int(round((p.solid_time + p.gone_time) * 60.0))
	TestWorld.rec(out, "TC-013 fase 02: ruptura alterna solida e intangivel", states.has(true) and states.has(false))
	TestWorld.rec(out, "fase 02: proporcao solida/intangivel bate com os tempos (3.0 s / 1.2 s)",
			absf(float(solid_frames) / float(states.size()) - p.solid_time / (p.solid_time + p.gone_time)) < 0.06)
	TestWorld.rec(out, "fase 02: ha aviso visual ANTES de a plataforma sumir", warned_before_gone)
	TestWorld.rec(out, "fase 02: colisao acompanha o estado (solida = camada world; intangivel = sem camada)",
			(p.collision_layer == PhysicsLayers.WORLD) == p.is_solid())
	var q := RupturePlatform.new()
	q.phase_offset = 0.0
	var r := RupturePlatform.new()
	r.phase_offset = 0.0
	q.elapsed = 1.0
	r.elapsed = 1.0
	TestWorld.rec(out, "fase 02: o ciclo e deterministico (mesmo tempo = mesmo estado)", q.is_solid() == r.is_solid() and q.solid_remaining() == r.solid_remaining())
	q.free()
	r.free()
	level.queue_free()
	var _unused: int = cycle


func _teleport(level: SylvaraLevel02, tree: SceneTree, pos: Vector3, frames: int = 3) -> void:
	level.rig.body.global_position = pos
	level.rig.body.velocity = Vector3.ZERO
	for i in frames:
		await tree.physics_frame


func _stabilizer_and_checkpoint(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel02 = _level(tree)
	await tree.physics_frame
	var stabilizer: Mechanism = level.find_children("*", "Mechanism", true, false)[0] as Mechanism
	var linked: Array[RupturePlatform] = []
	for node in level.find_children("*", "RupturePlatform", true, false):
		if (node as RupturePlatform).link_id == &"bridge_b":
			linked.append(node as RupturePlatform)
	TestWorld.rec(out, "fase 02: 4 plataformas ligadas ao estabilizador", linked.size() == 4)
	var all_solid_before: bool = true
	for pl in linked:
		all_solid_before = all_solid_before and pl.is_solid()
	TestWorld.rec(out, "fase 02: antes do estabilizador as plataformas ligadas alternam (nem todas solidas sempre)", true if not all_solid_before else linked[1].phase_offset > 0.0)
	await _teleport(level, tree, Vector3(45.3, 1.0, 0.0))
	level.rig.body.current_intent.interact_pressed = true
	level.controller._physics_process(0.0)
	TestWorld.rec(out, "TC-013 fase 02: interagir ativa o estabilizador", stabilizer.is_active)
	var solid_forever: bool = true
	for i in 300:
		await tree.physics_frame
		for pl in linked:
			solid_forever = solid_forever and pl.is_solid()
		level.rig.body.global_position = Vector3(45.3, 1.0, 0.0)
	TestWorld.rec(out, "fase 02: depois do estabilizador as 4 plataformas ficam solidas para sempre", solid_forever)
	await _teleport(level, tree, Vector3(28, -5, 0))
	TestWorld.rec(out, "TC-013 fase 02: cair depois do checkpoint volta o estabilizador e as plataformas ao estado do checkpoint",
			not stabilizer.is_active and not linked[0].stabilized)
	level.queue_free()


func _ids(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel02 = _level(tree)
	await tree.physics_frame
	var def: LevelDefinition = level.definition
	var ids: Array[String] = []
	var coins: Array[String] = []
	for node in level.find_children("*", "Pickup", true, false):
		var pk := node as Pickup
		ids.append(String(pk.pickup_id))
		if pk.kind == Pickup.Kind.COIN:
			coins.append(String(pk.pickup_id))
	var unique: Dictionary = {}
	for id in ids:
		unique[id] = true
	coins.sort()
	var expected: Array[String] = []
	for id in def.coin_ids:
		expected.append(id)
	expected.sort()
	TestWorld.rec(out, "fase 02: IDs unicos e moedas == definicao (9)", unique.size() == ids.size() and coins == expected)
	TestWorld.rec(out, "fase 02: segredo (item + memoria) e bau batem com a definicao", "sylvara_02_vine_charm" in ids
			and "memory_roots_clue_02" in ids and level.find_children("*", "Chest", true, false).size() == 1)
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel02 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot02.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 02 do inicio ao bau sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		TestWorld.rec(out, "bot: fase 02 com as 9 moedas e o segredo", c.session.coin_ids.size() == 9 and c.session.item_ids.size() == 1
				and c.session.memory_ids.size() == 1, "(moedas=%d faltam=%s)" % [c.session.coin_ids.size(), _missing(level)])
		TestWorld.rec(out, "bot: fase 02 sem perder vidas e classificacao Ouro",
				c.session.lives_lost == 0 and level.save["economy"]["best_grade_by_level"].get("sylvara_02") == RewardLedger.Grade.GOLD,
				"(vidas perdidas=%d grau=%s)" % [c.session.lives_lost, str(level.save["economy"]["best_grade_by_level"].get("sylvara_02"))])
	level.queue_free()


func _missing(level: SylvaraLevel02) -> String:
	var missing: PackedStringArray = []
	for id in level.definition.coin_ids:
		if not id in level.controller.session.coin_ids:
			missing.append(id)
	return ",".join(missing)
