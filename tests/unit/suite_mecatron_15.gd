extends RefCounted
## Fase 15 (O Trem do Eclipse): plataformas moveis, resgate, onda de raizes, reset por checkpoint e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _wagon(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> MecatronLevel15:
	var level := MecatronLevel15.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel15 = _level(tree)
	await tree.physics_frame
	var mp: MovingPlatform = level.find_children("*", "MovingPlatform", true, false)[0] as MovingPlatform
	var xs: Array[float] = []
	for i in 400:
		await tree.physics_frame
		xs.append(mp.position.x)
	TestWorld.rec(out, "fase 15: plataforma movel vai e volta dentro da amplitude", xs.min() >= mp.origin_x - mp.amplitude - 0.05
			and xs.max() <= mp.origin_x + mp.amplitude + 0.05 and xs.max() - xs.min() > 3.0)
	TestWorld.rec(out, "fase 15: movimento deterministico (posicao = funcao do tempo)", is_equal_approx(mp.position.x, mp.current_x()))
	# O heroi e carregado pela plataforma.
	level.rig.body.global_position = Vector3(mp.position.x, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	for i in 20:
		await tree.physics_frame
	var dx0: float = level.rig.body.global_position.x - mp.position.x
	for i in 90:
		await tree.physics_frame
	var dx1: float = level.rig.body.global_position.x - mp.position.x
	TestWorld.rec(out, "fase 15: a plataforma movel carrega o heroi (posicao relativa estavel)", level.rig.body.is_on_floor() and absf(dx1 - dx0) < 0.3,
			"(dx %.2f -> %.2f)" % [dx0, dx1])
	var wave: ChaseWave = level.find_children("*", "ChaseWave", true, false)[0] as ChaseWave
	TestWorld.rec(out, "fase 15: onda de raizes comeca parada e desarmada", not wave.running and is_equal_approx(wave.position.x, wave.start_x))
	level.rig.body.global_position = Vector3(66.0, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	for i in 120:
		await tree.physics_frame
		level.rig.body.global_position = Vector3(66.0, 1.0, 0.0)
	TestWorld.rec(out, "fase 15: ao passar do gatilho a tempestade avanca a 3,3 m/s", wave.running and wave.position.x > wave.start_x + 4.0,
			"(x=%.1f)" % wave.position.x)
	level.rig.body.global_position = Vector3(81.25, -5.0, 0.0)
	for i in 6:
		await tree.physics_frame
	TestWorld.rec(out, "TC-013 fase 15: cair no buraco volta ao checkpoint e reinicia a onda e as plataformas",
			not wave.running and is_equal_approx(wave.position.x, wave.start_x) and level.rig.vitals.lives == 4)
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel15 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot04.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 15 (plataformas moveis, resgate, perseguicao, buraco) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f)" % [bot.stage, bot.x(), bot.body.global_position.y])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 15 com as 9 moedas e a criatura resgatada", c.session.coin_ids.size() == 9 and c.session.rescued_ids == ["mecatron_15_creature"],
				"(moedas=%d faltam=%s)" % [c.session.coin_ids.size(), ",".join(missing)])
		TestWorld.rec(out, "bot: fase 15 sem perder vidas, e criatura registrada na historia (com o colecionavel ao lado: Prata)",
				c.session.lives_lost == 0 and level.save["economy"]["best_grade_by_level"].get("mecatron_15") >= RewardLedger.Grade.SILVER
				and level.save["story"]["rescued_creatures"] == ["mecatron_15_creature"], "(vidas perdidas=%d)" % c.session.lives_lost)
	level.queue_free()


## O colecionavel do trilho esta num vagao elevado (topo a 2,4 m): Rocco, com um salto so, nao o alcanca; Zuri, com o salto duplo, sim.
func _wagon(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel15 = _level(tree)
	await tree.physics_frame
	var rocco: Dictionary = await _jump_at_wagon(level, tree, 0, 1)
	var zuri: Dictionary = await _jump_at_wagon(level, tree, 1, 2)
	TestWorld.rec(out, "fase 15: o colecionavel fica num vagao elevado; Rocco (um salto) nao o pega e Zuri (salto duplo) pega e pousa nele",
			not rocco["item"] and zuri["item"] and zuri["foot"] > 2.2 and rocco["foot"] < 1.0,
			"(Rocco item=%s y=%.2f; Zuri item=%s y=%.2f)" % [rocco["item"], rocco["foot"], zuri["item"], zuri["foot"]])
	level.queue_free()
	await tree.physics_frame


func _jump_at_wagon(level: MecatronLevel15, tree: SceneTree, hero: int, presses: int) -> Dictionary:
	var body: ActorController = level.rig.body
	level.rig.request_swap(hero)
	for i in 10:
		await tree.physics_frame
	body.global_position = Vector3(46.0, 0.9, 0.0)
	body.velocity = Vector3.ZERO
	for i in 20:
		await tree.physics_frame
	var counter: Array[int] = [0]
	body.intent_provider = func() -> HeroIntent:
		var i := HeroIntent.new()
		var n: int = counter[0]
		counter[0] += 1
		i.jump_pressed = (n == 0) or (presses > 1 and n == 21)
		i.jump_held = n < 30
		i.move_axis = 0.35
		return i
	for i in 100:
		await tree.physics_frame
	body.intent_provider = Callable()
	return {"item": "mecatron_15_rail_collectible" in level.controller.session.item_ids, "foot": body.global_position.y - 0.75}
