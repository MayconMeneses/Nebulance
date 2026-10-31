extends RefCounted
## Fase 07 (O Despertar dos Cristais): prismas, pontes de luz, reset por checkpoint e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> CristaliaLevel07:
	var level := CristaliaLevel07.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: CristaliaLevel07 = _level(tree)
	for i in 3:
		await tree.physics_frame
	var bridges: Array[LightBridge] = []
	for n in level.find_children("*", "LightBridge", true, false):
		bridges.append(n as LightBridge)
	TestWorld.rec(out, "fase 07: duas pontes de luz, ambas apagadas no inicio", bridges.size() == 2 and not bridges[0].is_solid() and not bridges[1].is_solid())
	level.rig.body.global_position = Vector3(12.0, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	for i in 4:
		await tree.physics_frame
	level.rig.body.current_intent.interact_pressed = true
	level.controller._physics_process(0.0)
	for i in 4:
		await tree.physics_frame
	TestWorld.rec(out, "TC-013 fase 07: girar o prisma (E) acende o cristal e forma a ponte de luz", level.prism_a.orientation == 0 and level.field.is_lit(&"b1"))
	level.rig.body.global_position = Vector3(28, -5, 0)
	for i in 6:
		await tree.physics_frame
	TestWorld.rec(out, "TC-013 fase 07: cair e reaparecer antes do checkpoint desfaz o prisma e apaga a ponte", level.prism_a.orientation == 1 and not level.field.is_lit(&"b1"))
	var ids: Array[String] = []
	for node in level.find_children("*", "Pickup", true, false):
		ids.append(String((node as Pickup).pickup_id))
	var unique: Dictionary = {}
	for id in ids:
		unique[id] = true
	TestWorld.rec(out, "fase 07: IDs unicos (9 moedas + 1 item) e bau", unique.size() == ids.size() and ids.size() == 10 and level.find_children("*", "Chest", true, false).size() == 1)
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: CristaliaLevel07 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot07.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 07 (2 prismas, 2 pontes de luz, segredo) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 07 com 9 moedas e o simbolo, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["cristalia_07_prism_symbol"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("cristalia_07") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
