extends RefCounted
## Fase 08 (O Labirinto dos Reflexos): luz derivada dos prismas e do dispositivo, parede de luz, checkpoint e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> CristaliaLevel08:
	var level := CristaliaLevel08.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: CristaliaLevel08 = _level(tree)
	for i in 3:
		await tree.physics_frame
	var wall: LightBridge = level.find_children("*", "LightBridge", true, false)[0] as LightBridge
	TestWorld.rec(out, "fase 08: no inicio a parede de luz esta fechada (solida)", wall.is_solid() and not level.field.is_lit(&"wall"))
	level.prism_ground.interact()
	level.prism_high.interact()
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "fase 08: com os dois prismas certos mas o emissor DESLIGADO, a parede continua fechada", level.prism_ground.orientation == 0
			and level.prism_high.orientation == 0 and wall.is_solid())
	level.device.activate()
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "TC-013 fase 08: o dispositivo liga o emissor, a luz chega ao cristal e a parede abre", level.field.is_lit(&"wall") and not wall.is_solid())
	level.prism_high.interact()
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "fase 08: a orientacao errada de UM prisma fecha a parede de novo (a luz decide)", not level.field.is_lit(&"wall") and wall.is_solid())
	level.prism_high.interact()
	level.rig.body.global_position = Vector3(20, 3, 0)
	level.controller._on_life_lost(&"test")
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "TC-013 fase 08: reaparecer desfaz dispositivo e prismas (parede volta a fechar)",
			not level.device.is_active and level.prism_ground.orientation == 1 and wall.is_solid())
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: CristaliaLevel08 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot08.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 08 (prisma do chao, prisma alto, dispositivo aereo, parede de luz) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 08 com 9 moedas e o cristal musical, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["cristalia_08_music_crystal"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("cristalia_08") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
