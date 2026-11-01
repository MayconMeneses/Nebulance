extends RefCounted
## S06 (Camara da Primeira Expedicao): secreta (fora da ordem principal), ilusoes leves por evidencia, fechadura de sequencia e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	var level := UmbraxisLevelS06.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "S06: a fase e secreta (fora da ordem principal) e esta no catalogo; o bau comeca trancado pela fechadura",
			LevelCatalog.has("umbraxis_s06") and not "umbraxis_s06" in LevelCatalog.MAIN_ORDER["umbraxis"] and level.chest.locked)
	var changed: Array[bool] = [false, false, false]
	for i in 70:
		await tree.physics_frame
		for k in 3:
			if not level.stones[k].steady():
				changed[k] = true
	TestWorld.rec(out, "S06: a unica pedra que nunca pisca e a verdadeira (ilusoes leves, distinguiveis por evidencia)",
			not changed[0] and changed[1] and changed[2] and level.stones[0].is_real)
	level.lock.press(level.lock.order[0] + 1)
	TestWorld.rec(out, "S06: errar a ordem da fechadura zera o progresso e o bau continua trancado", level.lock.progress == 0 and level.chest.locked)
	var bot := LevelBotS06.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a S06 (ilusoes leves, plataformas, fechadura, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f)" % [bot.stage, bot.x(), bot.body.global_position.y])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: S06 com 9 moedas, traje exclusivo e arquivo final da expedicao, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["umbraxis_s06_expedition_suit"] and "memory_first_expedition_final_s06" in c.session.memory_ids
				and c.session.lives_lost == 0 and level.save["economy"]["best_grade_by_level"].get("umbraxis_s06") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
	await tree.physics_frame
	return out
