extends RefCounted
## Fase 31 (O Limiar das Raizes): plataformas dimensionais instaveis, checkpoint depois do primeiro risco, reinicio idempotente e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> UmbraxisLevel31:
	var level := UmbraxisLevel31.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel31 = _level(tree)
	await _settle(tree, 3)
	TestWorld.rec(out, "fase 31: Umbraxis esta no catalogo, a ordem principal comeca na fase 31 e o planeta e jogavel",
			LevelCatalog.has("umbraxis_31") and LevelCatalog.next_for(SaveData.new_game(), "umbraxis") == "umbraxis_31"
			and GalaxyState.planets()[5].playable)
	var solid_seen: bool = false
	var gone_seen: bool = false
	for i in 400:
		await tree.physics_frame
		var p: RupturePlatform = level.platforms[0]
		solid_seen = solid_seen or p.is_solid()
		gone_seen = gone_seen or not p.is_solid()
	TestWorld.rec(out, "fase 31: as plataformas dimensionais alternam solido e intangivel (ciclo deterministico)", solid_seen and gone_seen)
	level.rig.body.global_position = Vector3(35.0, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 4)
	TestWorld.rec(out, "fase 31: o checkpoint fica na ilha, depois do pouso e do primeiro risco", level.rig.last_checkpoint_id == &"umbraxis_31_cp1")
	for round_index in 2:
		level.rig.body.global_position = Vector3(60.0, -8.0, 0.0)
		await _settle(tree, 4)
		TestWorld.rec(out, "fase 31: cair (%da vez) reaparece no checkpoint da ilha, nao no inicio" % (round_index + 1),
				level.rig.body.global_position.x > 30.0 and level.rig.body.global_position.y > -1.0, "(x=%.1f)" % level.rig.body.global_position.x)
	level.queue_free()
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel31 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot31.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 31 (plataformas dimensionais, fragmento com Zuri, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 31 com 9 moedas e o fragmento do Legado Celestial, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["umbraxis_31_legacy_fragment"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("umbraxis_31") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
