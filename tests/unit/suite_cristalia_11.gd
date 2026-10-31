extends RefCounted
## Fase 11 (Catedral Prismatica): parede de luz, torre, mecanismos SINCRONIZADOS, reset e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _sync(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> CristaliaLevel11:
	var level := CristaliaLevel11.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _sync(tree: SceneTree, out: Array) -> void:
	var level: CristaliaLevel11 = _level(tree)
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "fase 11: a parede de luz e o portao sincronizado comecam fechados", level.wall.is_solid() and not level.sync_gate.is_open)
	level.mech_a.activate()
	for i in 430:
		await tree.physics_frame
	TestWorld.rec(out, "fase 11: um mecanismo sozinho se desativa depois de 6 s (sincronia)", not level.mech_a.is_active and not level.sync_gate.is_open)
	level.mech_b.activate()
	TestWorld.rec(out, "fase 11: ativar so o segundo (o primeiro ja apagou) nao abre o portao", not level.sync_gate.is_open and level.mech_b.is_active)
	level.mech_a.activate()
	TestWorld.rec(out, "TC-013 fase 11: os dois ativos ao mesmo tempo abrem o portao e o travam aberto", level.sync_gate.is_open and level.mech_a.latched and level.mech_b.latched)
	for i in 430:
		await tree.physics_frame
	TestWorld.rec(out, "fase 11: depois de aberto, o portao e os mecanismos continuam ativos (travados)", level.sync_gate.is_open and level.mech_a.is_active and level.mech_b.is_active)
	level.rig.body.global_position = Vector3(20, 3, 0)
	level.controller._on_life_lost(&"test")
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "TC-013 fase 11: reaparecer reabre o desafio (portao fechado, mecanismos apagados, prisma desfeito)",
			not level.sync_gate.is_open and not level.mech_a.is_active and not level.mech_b.is_active and level.prism.orientation == 1)
	level.prism.interact()
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "fase 11: o prisma certo acende o cristal e a parede abre", level.field.is_lit(&"hall") and not level.wall.is_solid())
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: CristaliaLevel11 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot11.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 11 (luz, torre, mecanismos sincronizados, arquivo) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 11 com 9 moedas e o registro da Astralis, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.memory_ids == ["memory_astralis_expedition_11"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("cristalia_11") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s)" % [c.session.coin_ids.size(), ",".join(missing)])
	level.queue_free()
