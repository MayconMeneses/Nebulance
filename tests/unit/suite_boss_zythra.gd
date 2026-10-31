extends RefCounted
## Zythra (TC-027..029, TC-034 parcial): etapas proprias, flor real x ilusoes, penalidade, Triade, semente de Cristalia, mapa, bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _stages(tree, out)
	await _flowers(tree, out)
	await _flow_and_map(tree, out)
	await _bot(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _arena(tree: SceneTree) -> CristaliaLevel12:
	var level := CristaliaLevel12.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _stages(tree: SceneTree, out: Array) -> void:
	var level: CristaliaLevel12 = _arena(tree)
	for i in 3:
		await tree.physics_frame
	var b: ZythraBoss = level.boss
	TestWorld.rec(out, "TC-029 Zythra: mecanismos fora de ordem NAO avancam a fase (real e pipa antes do prisma)",
			not b.mechanism_done(&"real") and not b.mechanism_done(&"pipa") and b.phase == 1)
	level.prism.interact()
	for i in 4:
		await tree.physics_frame
	TestWorld.rec(out, "TC-029 Zythra etapa 1: o prisma na orientacao certa leva a luz ao nucleo e avanca para a fase 2",
			level.prism.orientation == 0 and level.field.is_lit(&"core") and b.phase == 2)
	TestWorld.rec(out, "TC-029 Zythra: as flores so sao interagiveis na fase 2 e o mecanismo de Pipa so na fase 3",
			level.flowers[0].can_interact() and not level.pipa_mechanism.can_interact())
	b.mechanism_done(&"real")
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "TC-029 Zythra etapa 3: o mecanismo de Pipa so habilita na fase 3 e o Triade so na FINISH",
			level.pipa_mechanism.can_interact() and not level.flowers[0].can_interact() and not level.triad.nodes[0].can_interact())
	level.queue_free()


func _flowers(tree: SceneTree, out: Array) -> void:
	var level: CristaliaLevel12 = _arena(tree)
	for i in 3:
		await tree.physics_frame
	level.prism.interact()
	for i in 4:
		await tree.physics_frame
	var steady_real: bool = true
	var illusion_flickers: bool = false
	for step in 40:
		level.flowers[1].elapsed = 0.1 * step
		level.flowers[0].elapsed = 0.1 * step
		steady_real = steady_real and level.flowers[1].steady()
		illusion_flickers = illusion_flickers or not level.flowers[0].steady()
	TestWorld.rec(out, "TC-034 Zythra: a flor real NUNCA pisca e as ilusoes piscam (evidencia visual)", steady_real and illusion_flickers)
	var hearts: int = level.rig.vitals.hearts
	level.flowers[0].interact()
	TestWorld.rec(out, "TC-029 Zythra: tocar uma ILUSAO tira um coracao e a fase NAO avanca", level.rig.vitals.hearts == hearts - 1 and level.boss.phase == 2)
	level.flowers[1].interact()
	TestWorld.rec(out, "TC-029 Zythra: tocar a flor REAL avanca para a fase 3", level.boss.phase == 3)
	level.queue_free()


func _flow_and_map(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("zythra")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	# Sylvara salva (semente 1) para que Cristalia esteja disponivel no mapa.
	ProgressLedger.new().commit_seed(flow.profile, GalaxyState.planets()[0], "relic_sylvara", "astralis_memory_sylvara")
	flow.level.queue_free()
	flow.level = null
	flow._start_level("cristalia_12")
	await tree.process_frame
	var arena: CristaliaLevel12 = flow.level as CristaliaLevel12
	arena.boss.phase = VyrkanBoss.Phase.FINISH
	arena.boss.finish_triad()
	await tree.process_frame
	TestWorld.rec(out, "TC-027 Zythra: derrota -> semente de Cristalia salva na hora e a reacao de Caeldron (texto de Cristalia) toca 1x",
			"seed_cristalia" in SaveService.new(dir + "/slot1.json").load_save()["data"]["world"]["seed_destroyed_ids"] and flow.reaction_plays == 1
			and "Astralis" in arena.reaction_message)
	TestWorld.rec(out, "TC-028 Zythra: guardiao libertado, reliquia e memoria de Cristalia no perfil e bau liberado",
			"zythra" in flow.profile["world"]["boss_freed_ids"] and "relic_cristalia" in flow.profile["economy"]["owned_items"]
			and "astralis_memory_cristalia" in flow.profile["story"]["memories"] and not arena.chest.locked)
	flow._back_to_menu()
	await tree.process_frame
	await tree.process_frame
	flow.continue_game(true, "cristalia_12")
	await tree.process_frame
	var again: CristaliaLevel12 = flow.level as CristaliaLevel12
	again.controller._on_life_lost(&"abyss")
	for i in 90:
		await tree.physics_frame
	TestWorld.rec(out, "TC-028 Zythra: recarregar apos a vitoria abre a arena restaurada e o chefe nao ressuscita (nem apos morte)",
			again.boss.is_defeated() and not again.chest.locked and flow.reaction_plays == 1)
	var p: Dictionary = flow.profile
	TestWorld.rec(out, "TC-028 mapa: Cristalia Salva (raiz removida) e Mecatron Disponivel (ainda em producao)",
			GalaxyState.status(p, 1) == GalaxyState.Status.SAVED and not GalaxyState.root_visible(p, 1)
			and GalaxyState.status(p, 2) == GalaxyState.Status.AVAILABLE and not GalaxyState.can_travel(p, 2))
	TestWorld.rec(out, "mapa: viajar para Cristalia abre a proxima fase principal do planeta (nao a de Sylvara)",
			LevelCatalog.next_for(SaveData.new_game(), "cristalia") == "cristalia_07")
	tree.paused = false
	flow.queue_free()
	await tree.process_frame


func _bot(tree: SceneTree, out: Array) -> void:
	var level: CristaliaLevel12 = _arena(tree)
	await tree.physics_frame
	var bot := LevelBot12.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: derrota Zythra (prisma, flor real, planeio, Golpe Triade com 3 herois) e abre o bau sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f fase=%d heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.boss.phase, level.rig.body.profile.hero_id])
	if finished:
		TestWorld.rec(out, "bot: semente de Cristalia destruida, reliquia no perfil, 6 moedas e nenhuma vida perdida",
				"seed_cristalia" in level.save["world"]["seed_destroyed_ids"] and "relic_cristalia" in level.save["economy"]["owned_items"]
				and c.session.coin_ids.size() == 6 and c.session.lives_lost == 0,
				"(moedas=%d vidas perdidas=%d)" % [c.session.coin_ids.size(), c.session.lives_lost])
	level.queue_free()
