extends RefCounted
## Fase 05 (A Torre Esquecida): IDs, torre (so se passa escalando) e bot completo com os tres herois.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _structure(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> SylvaraLevel05:
	var level := SylvaraLevel05.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _structure(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel05 = _level(tree)
	await tree.physics_frame
	var ids: Array[String] = []
	var coins: Array[String] = []
	for node in level.find_children("*", "Pickup", true, false):
		var pk := node as Pickup
		ids.append(String(pk.pickup_id))
		if pk.kind == Pickup.Kind.COIN:
			coins.append(String(pk.pickup_id))
	coins.sort()
	var expected: Array[String] = []
	for id in level.definition.coin_ids:
		expected.append(id)
	expected.sort()
	var unique: Dictionary = {}
	for id in ids:
		unique[id] = true
	TestWorld.rec(out, "fase 05: IDs unicos, 9 moedas == definicao e memoria do holograma", unique.size() == ids.size() and coins == expected
			and "memory_tower_hologram_05" in ids)
	# Rocco nao passa da torre: corre contra o bloco de 5 m.
	var w := TestWorld.create(tree, 0, "adventure", Vector3(33.0, 1.0, 0.0), -10.0, 60.0)
	w.add_box(Vector3(40.0, 2.5, 0.0), Vector3(12.0, 5.0, 4.0), PhysicsLayers.WORLD)
	await w.step(20)
	w.input.move_axis = 1.0
	for i in 40:
		w.input.press_jump()
		await w.step(2)
	TestWorld.rec(out, "fase 05: a torre bloqueia quem nao escala (Rocco pulando nao passa)", w.body.global_position.x < 34.0,
			"(x=%.2f)" % w.body.global_position.x)
	w.dispose()
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel05 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot05.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 05 (3 poderes em sequencia + ponte de ruptura) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 05 com as 9 moedas e o holograma, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.memory_ids == ["memory_tower_hologram_05"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("sylvara_05") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
