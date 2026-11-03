extends RefCounted
## Fase 29 (O Observatorio Celestial): tres coordenadas por desafios aprendidos, console narrativo, ponte da rota, checkpoint e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> AerionLevel29:
	var level := AerionLevel29.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel29 = _level(tree)
	await _settle(tree, 3)
	var body: ActorController = level.rig.body
	TestWorld.rec(out, "TC-054 fase 29: combina os tres desafios (vento de popa, gravidade invertida, corrente ascendente) em zonas definidas",
			is_equal_approx(level.tailwind.wind_on.x, 40.0) and level.gravity_zone.gravity_scale < 0.0 and level.lift.is_blowing())
	TestWorld.rec(out, "TC-054 fase 29: o console comeca bloqueado e a ponte da rota nao existe",
			not level.console.can_interact() and not level.bridge.is_solid() and level.bridge.collision_layer == 0)
	level.coord_wind.interact()
	level.coord_gravity.interact()
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-054 fase 29: com so duas coordenadas o console continua bloqueado", not level.console.can_interact() and not level.console.enabled)
	level.coord_route.interact()
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-054 fase 29: com as tres coordenadas o console responde", level.console.can_interact())
	level.console.interact()
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-054 fase 29: ler o console constroi a ponte da rota para o planeta final (solida)", level.bridge.is_solid() and level.bridge.collision_layer == PhysicsLayers.WORLD)
	# Checkpoint antes do console: o estado das coordenadas capturado e o restaurado; a ponte volta a sumir se o console nao foi lido.
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-054 fase 29: reaparecer sem checkpoint devolve coordenadas, console e ponte ao estado inicial",
			not level.coord_wind.is_active and not level.coord_route.is_active and not level.console.is_active and not level.bridge.is_solid())
	body.global_position = Vector3(81.0, 1.0, 0.0)
	await _settle(tree, 5)
	level.coord_wind.interact()
	level.coord_gravity.interact()
	level.coord_route.interact()
	await _settle(tree, 2)
	level.console.interact()
	body.global_position = Vector3(60.0, -9.0, 0.0)
	await _settle(tree, 6)
	TestWorld.rec(out, "TC-054 fase 29: apos o checkpoint antes do console, cair restaura o estado capturado nele (nada ligado) e reaparece ali",
			absf(body.global_position.x - 81.0) < 2.0 and not level.console.is_active and not level.bridge.is_solid(),
			"(x=%.1f)" % body.global_position.x)
	TestWorld.rec(out, "TC-054 fase 29: memoria quase completa, previa de Umbraxis, bau e 9 moedas com ids estaveis",
			level.definition.secret_memory_ids == PackedStringArray(["memory_first_expedition_29"])
			and level.definition.secret_item_ids == PackedStringArray(["aerion_29_umbraxis_preview"]) and level.definition.coin_ids.size() == 9
			and level.definition.chest_id == &"aerion_29_chest")
	level.queue_free()
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel29 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot29.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 29 (vento, gravidade, planeio, tres coordenadas, console, ponte, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 29 com 9 moedas, previa de Umbraxis e memoria, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["aerion_29_umbraxis_preview"]
				and c.session.memory_ids == ["memory_first_expedition_29"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("aerion_29") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
