extends RefCounted
## S04 (Oceano Esquecido): fase secreta compacta (fora da ordem principal), comporta e plataformas flutuantes, itens unicos e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	var level := AquarysLevelS04.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "S04: a fase e secreta (fora da ordem principal), esta no catalogo e a unica entrada e o portal da fase 21",
			LevelCatalog.has("aquarys_s04") and not "aquarys_s04" in LevelCatalog.MAIN_ORDER["aquarys"])
	TestWorld.rec(out, "S04: com a mare baixa as plataformas flutuantes ficam abaixo do piso; a comporta so e oferecida se a mare nao estiver alta",
			level.floaters[0].position.y < -0.1 and level.raise_control.can_interact())
	var bot := LevelBotS04.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a S04 (comporta, flutuantes, degraus, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f)" % [bot.stage, bot.x(), bot.body.global_position.y])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: S04 com 9 moedas, acessorio da expedicao e gravacao da antiga expedicao, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["aquarys_s04_expedition_badge"] and "memory_old_expedition_recording_s04" in c.session.memory_ids
				and c.session.lives_lost == 0 and level.save["economy"]["best_grade_by_level"].get("aquarys_s04") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
	return out
