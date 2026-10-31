extends RefCounted
## S03 (Oficina Zero): maquinas de polaridade em espaco compacto, itens unicos e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	var level := MecatronLevelS03.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	await tree.physics_frame
	TestWorld.rec(out, "S03: a fase e secreta (fora da ordem principal) e esta no catalogo", LevelCatalog.has("mecatron_s03")
			and not "mecatron_s03" in LevelCatalog.MAIN_ORDER["mecatron"])
	var bot := LevelBotS03.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a S03 (elevador, trilho, bancada, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f)" % [bot.stage, bot.x(), bot.body.global_position.y])
	if finished:
		TestWorld.rec(out, "bot: S03 com 4 moedas, acessorio tecnologico e registro da Astralis, sem perder vidas",
				c.session.coin_ids.size() == 4 and c.session.item_ids == ["mecatron_s03_tech_accessory"] and "memory_astralis_maintenance_s03" in c.session.memory_ids
				and c.session.lives_lost == 0, "(moedas=%d vidas perdidas=%d)" % [c.session.coin_ids.size(), c.session.lives_lost])
	level.queue_free()
	return out
