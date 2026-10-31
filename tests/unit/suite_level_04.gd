extends RefCounted
## Fase 04 (O Rio Luminoso): plataformas moveis, resgate, onda de raizes, reset por checkpoint e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> SylvaraLevel04:
	var level := SylvaraLevel04.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel04 = _level(tree)
	await tree.physics_frame
	var mp: MovingPlatform = level.find_children("*", "MovingPlatform", true, false)[0] as MovingPlatform
	var xs: Array[float] = []
	for i in 400:
		await tree.physics_frame
		xs.append(mp.position.x)
	TestWorld.rec(out, "fase 04: plataforma movel vai e volta dentro da amplitude", xs.min() >= mp.origin_x - mp.amplitude - 0.05
			and xs.max() <= mp.origin_x + mp.amplitude + 0.05 and xs.max() - xs.min() > 3.0)
	TestWorld.rec(out, "fase 04: movimento deterministico (posicao = funcao do tempo)", is_equal_approx(mp.position.x, mp.current_x()))
	# O heroi e carregado pela plataforma.
	level.rig.body.global_position = Vector3(mp.position.x, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	for i in 20:
		await tree.physics_frame
	var dx0: float = level.rig.body.global_position.x - mp.position.x
	for i in 90:
		await tree.physics_frame
	var dx1: float = level.rig.body.global_position.x - mp.position.x
	TestWorld.rec(out, "fase 04: a plataforma movel carrega o heroi (posicao relativa estavel)", level.rig.body.is_on_floor() and absf(dx1 - dx0) < 0.3,
			"(dx %.2f -> %.2f)" % [dx0, dx1])
	var wave: ChaseWave = level.find_children("*", "ChaseWave", true, false)[0] as ChaseWave
	TestWorld.rec(out, "fase 04: onda de raizes comeca parada e desarmada", not wave.running and is_equal_approx(wave.position.x, wave.start_x))
	level.rig.body.global_position = Vector3(66.0, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	for i in 120:
		await tree.physics_frame
		level.rig.body.global_position = Vector3(66.0, 1.0, 0.0)
	TestWorld.rec(out, "fase 04: ao passar do gatilho a onda avanca a 3 m/s", wave.running and wave.position.x > wave.start_x + 4.0,
			"(x=%.1f)" % wave.position.x)
	level.rig.body.global_position = Vector3(81.25, -5.0, 0.0)
	for i in 6:
		await tree.physics_frame
	TestWorld.rec(out, "TC-013 fase 04: cair no buraco volta ao checkpoint e reinicia a onda e as plataformas",
			not wave.running and is_equal_approx(wave.position.x, wave.start_x) and level.rig.vitals.lives == 4)
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel04 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot04.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 04 (plataformas moveis, resgate, perseguicao, buraco) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f)" % [bot.stage, bot.x(), bot.body.global_position.y])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 04 com as 9 moedas e a criatura resgatada", c.session.coin_ids.size() == 9 and c.session.rescued_ids == ["sylvara_04_creature"],
				"(moedas=%d faltam=%s)" % [c.session.coin_ids.size(), ",".join(missing)])
		TestWorld.rec(out, "bot: fase 04 sem perder vidas, Ouro e criatura registrada na historia",
				c.session.lives_lost == 0 and level.save["economy"]["best_grade_by_level"].get("sylvara_04") == RewardLedger.Grade.GOLD
				and level.save["story"]["rescued_creatures"] == ["sylvara_04_creature"], "(vidas perdidas=%d)" % c.session.lives_lost)
	level.queue_free()
