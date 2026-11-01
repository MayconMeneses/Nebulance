extends RefCounted
## Fase 33 (O Jardim dos Ecos): ilusoes distinguiveis por EVIDENCIA, penalidade do erro, estabilizacao da travessia, portal da S06,
## reinicio idempotente no checkpoint e bot que escolhe so pela evidencia.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> UmbraxisLevel33:
	var level := UmbraxisLevel33.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel33 = _level(tree)
	await _settle(tree, 3)
	TestWorld.rec(out, "fase 33: o portal da S06 comeca fechado e a S06 esta no catalogo fora da ordem principal",
			not level.portal.can_interact() and level.portal.destination_level_id == &"umbraxis_s06" and LevelCatalog.has("umbraxis_s06")
			and not "umbraxis_s06" in LevelCatalog.MAIN_ORDER["umbraxis"])
	# Evidencia 1 (pisca): ao longo de 1 s a real nunca alterna; cada ilusao alterna ao menos uma vez.
	var changed: Array[bool] = [false, false, false]
	for i in 70:
		await tree.physics_frame
		for k in 3:
			if not level.stones_a[k].steady():
				changed[k] = true
	TestWorld.rec(out, "TC-051 fase 33: conjunto 1 - a unica pedra que nunca pisca e a verdadeira (as ilusoes alternam)",
			not changed[UmbraxisLevel33.REAL_A] and changed.count(true) == 2 and level.stones_a.filter(func(s: EchoStone) -> bool: return s.is_real).size() == 1)
	# Evidencia 2 (forma): ilusoes sao colunas finas; a real e cheia e nao pisca.
	var shapes_ok: bool = true
	for k in 3:
		var s: EchoStone = level.stones_b[k]
		shapes_ok = shapes_ok and ((s.body_scale() == Vector3.ONE) == s.is_real) and s.steady()
	TestWorld.rec(out, "TC-051 fase 33: conjunto 2 - a unica pedra de forma cheia e a verdadeira (as ilusoes sao finas, sem piscar)",
			shapes_ok and level.stones_b[UmbraxisLevel33.REAL_B].is_real)
	# Acessibilidade: sem flashes, a ilusao do conjunto 1 deixa de alternar a cor e continua distinta da real.
	Accessibility.reduce_flashing = true
	var colors: Dictionary = {}
	for i in 40:
		await tree.physics_frame
		var fake: EchoStone = level.stones_a[0]
		colors[fake._material.albedo_color] = true
	var real_color: Color = level.stones_a[UmbraxisLevel33.REAL_A]._material.albedo_color
	var fake_color: Color = level.stones_a[0]._material.albedo_color
	Accessibility.reduce_flashing = false
	TestWorld.rec(out, "TC-051 fase 33: com 'reduzir flashes' a ilusao nao alterna cor e continua distinguivel da pedra real", colors.size() == 1 and real_color != fake_color)
	# Errar custa um coracao e nao estabiliza nada.
	var hearts: int = level.rig.vitals.hearts
	level.stones_a[0].interact()
	TestWorld.rec(out, "TC-051 fase 33: tocar uma ilusao tira um coracao e nao estabiliza a travessia",
			level.rig.vitals.hearts == hearts - 1 and level.platforms_a.all(func(p: RupturePlatform) -> bool: return not p.stabilized))
	# Checkpoint antes das ilusoes: resolver, perder a vida duas vezes e conferir o estado.
	level.rig.body.global_position = Vector3(14.0, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 4)
	TestWorld.rec(out, "fase 33: o primeiro checkpoint vem antes das ilusoes", level.rig.last_checkpoint_id == &"umbraxis_33_cp1" and 14.0 < UmbraxisLevel33.STONES_A_X[0])
	level.stones_a[UmbraxisLevel33.REAL_A].interact()
	level.inscription.interact()
	TestWorld.rec(out, "TC-044 fase 33: a pedra real estabiliza o conjunto 1 (e so ele) e a inscricao revela o portal da S06",
			level.platforms_a.all(func(p: RupturePlatform) -> bool: return p.stabilized) and level.platforms_b.all(func(p: RupturePlatform) -> bool: return not p.stabilized)
			and level.portal.can_interact())
	for round_index in 2:
		level.controller._on_life_lost(&"test")
		level.rig.body.respawn(level.rig.checkpoint_position)
		await _settle(tree, 3)
		TestWorld.rec(out, "TC-051 fase 33: reaparecer (%da vez) devolve pedras, plataformas, inscricao e portal ao estado do checkpoint" % (round_index + 1),
				not level.stones_a[UmbraxisLevel33.REAL_A].solved and level.platforms_a.all(func(p: RupturePlatform) -> bool: return not p.stabilized)
				and not level.inscription.is_active and not level.portal.can_interact())
		level.stones_a[UmbraxisLevel33.REAL_A].interact()
		level.inscription.interact()
	level.queue_free()
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel33 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot33.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 33 distinguindo as pedras-eco so por evidencia, sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 33 com 9 moedas, traje, arquivo da tripulacao e portal da S06 aberto, sem perder vidas nem coracoes, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["umbraxis_33_crew_suit"] and "memory_expedition_projection_33" in c.session.memory_ids
				and level.portal.can_interact() and c.session.lives_lost == 0 and level.rig.vitals.hearts == level.rig.difficulty.hearts_per_attempt
				and level.save["economy"]["best_grade_by_level"].get("umbraxis_33") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
