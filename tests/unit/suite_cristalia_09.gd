extends RefCounted
## Fase 09 (Jardim das Orquideas) e S02 (Camara das Frequencias Perdidas): puzzle de tres sinais, portal, fechadura de sequencia.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _gate(tree, out)
	await _sequence_rules(tree, out)
	await _bots(tree, out)
	return out


func _make(tree: SceneTree, script: GDScript) -> LevelScene:
	var level := script.new() as LevelScene
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _gate(tree: SceneTree, out: Array) -> void:
	var level: CristaliaLevel09 = _make(tree, CristaliaLevel09) as CristaliaLevel09
	for i in 3:
		await tree.physics_frame
	var gate: LightBridge = level.find_children("*", "LightBridge", true, false)[0] as LightBridge
	TestWorld.rec(out, "fase 09: portao de luz fechado e portal fechado no inicio", gate.is_solid() and not level.portal.can_interact())
	level.prism_a.interact()
	level.prism_b.interact()
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "fase 09: com 2 de 3 sinais acesos o portao continua fechado", gate.is_solid() and not level.portal.can_interact())
	level.prism_c.interact()
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "TC-014 fase 09: os 3 sinais acesos abrem o portao e o portal (para a S02)", not gate.is_solid() and level.portal.can_interact()
			and level.portal.destination_level_id == &"cristalia_s02" and LevelCatalog.has("cristalia_s02"))
	level.queue_free()


func _sequence_rules(tree: SceneTree, out: Array) -> void:
	var level: CristaliaLevelS02 = _make(tree, CristaliaLevelS02) as CristaliaLevelS02
	await tree.physics_frame
	var lock: SequenceLock = level.lock
	TestWorld.rec(out, "S02: bau trancado no inicio", level.chest.locked and not level.chest.can_interact())
	lock.press(0)
	TestWorld.rec(out, "S02: cristal fora de ordem zera o progresso", lock.progress == 0)
	lock.press(2)
	lock.press(0)
	lock.press(1)
	TestWorld.rec(out, "S02: errar no meio da sequencia reinicia (ordem 2,0,3,1)", lock.progress == 0 and not lock.is_unlocked)
	for i in lock.order:
		lock.press(i)
	TestWorld.rec(out, "S02: a ordem certa destranca o bau", lock.is_unlocked and not level.chest.locked)
	lock.restore(null)
	TestWorld.rec(out, "S02: reaparecer (checkpoint) refaz a fechadura e tranca o bau", not lock.is_unlocked and level.chest.locked and lock.progress == 0)
	var hints: Array[int] = []
	for step in 8:
		lock.elapsed = step * SequenceLock.HINT_STEP + 0.1
		hints.append(lock.hint_index())
	TestWorld.rec(out, "S02: a dica pisca a ordem certa e depois pausa (deterministico)", hints.slice(0, 5) == [2, 0, 3, 1, -1])
	level.queue_free()


func _bots(tree: SceneTree, out: Array) -> void:
	var l9: CristaliaLevel09 = _make(tree, CristaliaLevel09) as CristaliaLevel09
	await tree.physics_frame
	var b9 := LevelBot09.new(tree, l9)
	b9.trace = OS.get_cmdline_user_args().has("--trace")
	var ok9: bool = await b9.play()
	var c9: LevelController = l9.controller
	TestWorld.rec(out, "bot: completa a fase 09 (3 sinais de luz, portal e bau) sem teleporte", ok9,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [b9.stage, b9.x(), b9.body.global_position.y, l9.rig.body.profile.hero_id])
	if ok9:
		var missing: PackedStringArray = []
		for id in l9.definition.coin_ids:
			if not id in c9.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 09 com 9 moedas e a memoria do portal, Ouro, pediu o portal da S02",
				c9.session.coin_ids.size() == 9 and c9.session.memory_ids == ["memory_orchid_signals_09"] and c9.session.lives_lost == 0
				and b9.portal_requests == [&"cristalia_09_portal"] and l9.save["economy"]["best_grade_by_level"].get("cristalia_09") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s)" % [c9.session.coin_ids.size(), ",".join(missing)])
	l9.queue_free()
	var s2: CristaliaLevelS02 = _make(tree, CristaliaLevelS02) as CristaliaLevelS02
	await tree.physics_frame
	var bs := LevelBotS02.new(tree, s2)
	bs.trace = OS.get_cmdline_user_args().has("--trace")
	var oks: bool = await bs.play()
	var cs: LevelController = s2.controller
	TestWorld.rec(out, "bot: completa a S02 (sequencia de cristais musicais) sem teleporte", oks, "(etapa=%s x=%.1f)" % [bs.stage, bs.x()])
	if oks:
		TestWorld.rec(out, "bot: S02 com 4 moedas e os 2 itens unicos (Lente do Primeiro Explorador e item Prisma Cosmico)",
				cs.session.coin_ids.size() == 4 and cs.session.item_ids.size() == 2 and cs.session.lives_lost == 0,
				"(moedas=%d itens=%d)" % [cs.session.coin_ids.size(), cs.session.item_ids.size()])
	s2.queue_free()
