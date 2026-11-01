extends RefCounted
## Necryon (fase 36): etapas proprias (combinacao, ilusoes por evidencia, ruptura), Triade, sexta semente, reinicio idempotente, fluxo e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _stages(tree, out)
	await _reset(tree, out)
	await _flow_and_map(tree, out)
	await _bot(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _arena(tree: SceneTree) -> UmbraxisLevel36:
	var level := UmbraxisLevel36.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _stages(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel36 = _arena(tree)
	await _settle(tree, 3)
	var b: NecryonBoss = level.boss
	TestWorld.rec(out, "TC-052 Necryon: etapas fora de ordem NAO avancam a fase (ilusao e nucleo antes da combinacao)",
			not b.mechanism_done(&"real") and not b.mechanism_done(&"core") and b.phase == 1)
	TestWorld.rec(out, "TC-052 Necryon: na fase 1 so a fechadura responde (pedras-eco, estabilizador e nucleo bloqueados)",
			level.lock.crystals[0].can_interact() and not level.stones[0].can_interact() and not level.stabilizer.can_interact() and not level.core.can_interact())
	# Combinacao: errar a ordem zera; a ordem certa avanca.
	level.lock.press((level.lock.order[0] + 1) % 4)
	TestWorld.rec(out, "TC-052 Necryon etapa 1: ordem errada zera a combinacao", level.lock.progress == 0 and b.phase == 1)
	for idx in level.lock.order:
		level.lock.press(idx)
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-052 Necryon etapa 1: a combinacao certa avanca para a fase 2", level.lock.is_unlocked and b.phase == 2)
	TestWorld.rec(out, "TC-052 Necryon fase 2: so as pedras-eco respondem", level.stones[0].can_interact() and not level.stabilizer.can_interact() and not level.core.can_interact())
	# Evidencias: a unica pedra sem piscar e de forma cheia e a real; cada ilusao tem uma evidencia diferente.
	var blinked: Array[bool] = [false, false, false]
	for i in 70:
		await tree.physics_frame
		for k in 3:
			if not level.stones[k].steady():
				blinked[k] = true
	var thin: Array[bool] = []
	for s in level.stones:
		thin.append(s.body_scale() != Vector3.ONE)
	TestWorld.rec(out, "TC-052 Necryon etapa 2: uma ilusao pisca, a outra e fina e a real nao tem nenhuma das duas evidencias",
			blinked == [true, false, false] and thin == [false, false, true] and level.stones[UmbraxisLevel36.REAL_STONE].is_real)
	var hearts: int = level.rig.vitals.hearts
	level.stones[0].interact()
	TestWorld.rec(out, "TC-052 Necryon etapa 2: tocar uma ilusao tira um coracao, reinicia o ciclo e a fase continua a 2",
			level.rig.vitals.hearts == hearts - 1 and b.phase == 2 and not level.stones[0].solved)
	level.stones[UmbraxisLevel36.REAL_STONE].interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-052 Necryon etapa 2: a pedra real avanca para a fase 3", b.phase == 3 and level.stones[1].solved)
	TestWorld.rec(out, "TC-052 Necryon fase 3: so o estabilizador e o nucleo respondem, e o Triade so na FINISH",
			level.stabilizer.can_interact() and level.core.can_interact() and not level.stones[0].can_interact() and not level.triad.nodes[0].can_interact())
	TestWorld.rec(out, "TC-052 Necryon etapa 3: as plataformas de ruptura so ficam estaveis depois do estabilizador",
			level.platforms.all(func(p: RupturePlatform) -> bool: return not p.stabilized))
	level.stabilizer.interact()
	TestWorld.rec(out, "TC-052 Necryon etapa 3: o estabilizador estabiliza as tres plataformas", level.platforms.all(func(p: RupturePlatform) -> bool: return p.stabilized))
	level.core.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-052 Necryon: selar o nucleo libera o Golpe Triade (fase FINISH)", b.phase == VyrkanBoss.Phase.FINISH and level.triad.nodes[0].can_interact())
	level.queue_free()
	await _settle(tree, 3)


func _reset(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel36 = _arena(tree)
	await _settle(tree, 3)
	for idx in level.lock.order:
		level.lock.press(idx)
	await _settle(tree, 3)
	level.stones[UmbraxisLevel36.REAL_STONE].interact()
	await _settle(tree, 3)
	level.stabilizer.interact()
	var reached_three: bool = level.boss.phase == 3
	for round_index in 2:
		level.controller._on_life_lost(&"test")
		level.rig.body.respawn(level.rig.checkpoint_position)
		await _settle(tree, 3)
		TestWorld.rec(out, "TC-052 Necryon: reaparecer (%da vez) reinicia fechadura, pedras, estabilizador, plataformas e o chefe (idempotente)" % (round_index + 1),
				reached_three and level.boss.phase == 1 and not level.lock.is_unlocked and not level.stones[1].solved and not level.stabilizer.is_active
				and level.platforms.all(func(p: RupturePlatform) -> bool: return not p.stabilized) and level.lock.crystals[0].can_interact())
	level.queue_free()
	await _settle(tree, 3)


func _flow_and_map(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("necryon")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	var ledger := ProgressLedger.new()
	var relics: Array[String] = ["sylvara", "cristalia", "mecatron", "aquarys", "aerion"]
	for i in relics.size():
		ledger.commit_seed(flow.profile, GalaxyState.planets()[i], "relic_%s" % relics[i], "astralis_memory_%s" % relics[i])
	flow.level.queue_free()
	flow.level = null
	flow._start_level("umbraxis_36")
	await tree.process_frame
	var arena: UmbraxisLevel36 = flow.level as UmbraxisLevel36
	arena.boss.phase = VyrkanBoss.Phase.FINISH
	arena.boss.finish_triad()
	await tree.process_frame
	TestWorld.rec(out, "TC-053 Necryon: derrota -> sexta semente salva na hora e a reacao de Caeldron toca 1x (sem final nem cutscene)",
			"seed_umbraxis" in SaveService.new(dir + "/slot1.json").load_save()["data"]["world"]["seed_destroyed_ids"] and flow.reaction_plays == 1
			and "CAELDRON" in arena.reaction_message)
	TestWorld.rec(out, "TC-053 Necryon: guardiao libertado, reliquia e memoria de Umbraxis no perfil e bau liberado",
			"necryon" in flow.profile["world"]["boss_freed_ids"] and "relic_umbraxis" in flow.profile["economy"]["owned_items"]
			and "astralis_memory_umbraxis" in flow.profile["story"]["memories"] and not arena.chest.locked)
	# A sexta semente tambem dispara a sequencia final (ver suite_ending): reacao -> morte de Caeldron -> creditos, todos pulaveis.
	flow.get_children().filter(func(n: Node) -> bool: return n is CaeldronReaction)[0].skip()
	await tree.process_frame
	flow.get_children().filter(func(n: Node) -> bool: return n is CaeldronDeath)[0].skip()
	await tree.process_frame
	flow.get_children().filter(func(n: Node) -> bool: return n is CreditsScreen)[0].skip()
	await tree.process_frame
	TestWorld.rec(out, "TC-053 Necryon: a sexta semente toca a sequencia final 1x e o jogo volta a rodar (nao fica pausado)",
			flow.ending_plays == 1 and flow.credits_plays == 1 and not tree.paused)
	flow._back_to_menu()
	await tree.process_frame
	await tree.process_frame
	flow.continue_game(true, "umbraxis_36")
	await tree.process_frame
	var again: UmbraxisLevel36 = flow.level as UmbraxisLevel36
	again.controller._on_life_lost(&"abyss")
	for i in 90:
		await tree.physics_frame
	TestWorld.rec(out, "TC-053 Necryon: recarregar apos a vitoria abre a arena restaurada e o chefe nao ressuscita (nem apos morte)",
			again.boss.is_defeated() and not again.chest.locked and flow.reaction_plays == 1 and flow.ending_plays == 1)
	var p: Dictionary = flow.profile
	TestWorld.rec(out, "TC-053 mapa: Umbraxis Salvo (raiz removida) mas o planeta continua NAO jogavel (em producao) e a ordem principal comeca na fase 31",
			GalaxyState.status(p, 5) == GalaxyState.Status.SAVED and not GalaxyState.root_visible(p, 5) and not GalaxyState.planets()[5].playable
			and not GalaxyState.can_travel(SaveData.new_game(), 5) and LevelCatalog.next_for(SaveData.new_game(), "umbraxis") == "umbraxis_31")
	tree.paused = false
	flow.queue_free()
	await tree.process_frame


func _bot(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel36 = _arena(tree)
	await tree.physics_frame
	var bot := LevelBot36.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: derrota Necryon (combinacao, ilusoes por evidencia, ruptura, Golpe Triade com 3 herois) e abre o bau sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f fase=%d heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.boss.phase, level.rig.body.profile.hero_id])
	if finished:
		TestWorld.rec(out, "bot: sexta semente destruida, reliquia no perfil, 6 moedas e nenhuma vida perdida",
				"seed_umbraxis" in level.save["world"]["seed_destroyed_ids"] and "relic_umbraxis" in level.save["economy"]["owned_items"]
				and c.session.coin_ids.size() == 6 and c.session.lives_lost == 0,
				"(moedas=%d vidas perdidas=%d)" % [c.session.coin_ids.size(), c.session.lives_lost])
	level.queue_free()
