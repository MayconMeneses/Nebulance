extends RefCounted
## Final e pos-jogo: campanha concluida derivada das seis sementes, morte de Caeldron (sequencia pulavel, uma unica vez, idempotente ao
## recarregar), creditos, mapa com seis sementes e planetas salvos visitaveis sem reviver Caeldron nem resetar a vitoria.

const RELICS: Array[String] = ["sylvara", "cristalia", "mecatron", "aquarys", "aerion", "umbraxis"]


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_state_and_ledger(out)
	_unlock_chain(out)
	await _skippable(tree, out)
	await _map(tree, out)
	await _flow(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _save_with(seeds: int) -> Dictionary:
	var save: Dictionary = SaveData.new_game()
	var ledger := ProgressLedger.new()
	for i in seeds:
		ledger.commit_seed(save, GalaxyState.planets()[i], "relic_%s" % RELICS[i], "astralis_memory_%s" % RELICS[i])
	return save


func _count(list: Array, id: String) -> int:
	return list.count(id)


func _state_and_ledger(out: Array) -> void:
	var five: Dictionary = _save_with(5)
	var six: Dictionary = _save_with(6)
	TestWorld.rec(out, "TC-063 final: a campanha so e concluida com as SEIS sementes (derivado do save; cinco nao bastam) e Caeldron vive ate la",
			not GalaxyState.campaign_complete(SaveData.new_game()) and not GalaxyState.campaign_complete(five) and GalaxyState.campaign_complete(six)
			and GalaxyState.caeldron_alive(five) and not GalaxyState.caeldron_alive(six) and GalaxyState.seeds_destroyed_count(five) == 5
			and GalaxyState.campaign_complete(GalaxyState.qa_save(6)) and not GalaxyState.campaign_complete(GalaxyState.qa_save(5)))
	var ledger := ProgressLedger.new()
	TestWorld.rec(out, "TC-063 final: com cinco sementes a transacao do fim NAO e concedida e nada e gravado",
			not ledger.claim_campaign_end(five)["first_time"] and not ProgressLedger.ENDING_TX in five["economy"]["claimed_transaction_ids"]
			and not ProgressLedger.FINAL_MESSAGE_ID in five["story"]["memories"])
	var first: bool = ledger.claim_campaign_end(six)["first_time"]
	var second: bool = ledger.claim_campaign_end(six)["first_time"]
	TestWorld.rec(out, "TC-063 final: com seis sementes a transacao do fim e concedida UMA vez (mensagem final e trofeu gravados sem duplicar)",
			first and not second and _count(six["economy"]["claimed_transaction_ids"], ProgressLedger.ENDING_TX) == 1
			and _count(six["story"]["memories"], ProgressLedger.FINAL_MESSAGE_ID) == 1 and _count(six["story"]["trophies"], ProgressLedger.CAMPAIGN_TROPHY_ID) == 1)


func _unlock_chain(out: Array) -> void:
	var four: Dictionary = _save_with(4)
	var five: Dictionary = _save_with(5)
	TestWorld.rec(out, "TC-063 encadeamento: Umbraxis so abre depois da semente de Aerion (Sylvara>Cristalia>Mecatron>Aquarys>Aerion>Umbraxis)",
			GalaxyState.status(four, 5) == GalaxyState.Status.LOCKED and not GalaxyState.can_travel(four, 5)
			and GalaxyState.status(five, 5) == GalaxyState.Status.AVAILABLE and GalaxyState.status(five, 4) == GalaxyState.Status.SAVED)
	TestWorld.rec(out, "TC-063 encadeamento: Umbraxis e jogavel, viajavel com a semente de Aerion e nunca abre sem ela",
			GalaxyState.planets()[5].playable and GalaxyState.can_travel(five, 5) and not GalaxyState.can_travel(four, 5))


func _skippable(tree: SceneTree, out: Array) -> void:
	var death := CaeldronDeath.new()
	tree.get_root().add_child(death)
	var emitted: Array[int] = [0]
	death.finished.connect(func() -> void: emitted[0] += 1)
	await tree.process_frame
	death.skip()
	death.skip()
	TestWorld.rec(out, "TC-063 final: a morte de Caeldron e pulavel e emite 'finished' uma unica vez", emitted[0] == 1 and death.is_done())
	var auto := CaeldronDeath.new()
	tree.get_root().add_child(auto)
	var auto_count: Array[int] = [0]
	auto.finished.connect(func() -> void: auto_count[0] += 1)
	await tree.process_frame
	auto._process(auto.total_time() + 0.1)
	TestWorld.rec(out, "TC-063 final: sem input a sequencia termina sozinha e e curta (<= 15 s, sem batalha extra)", auto_count[0] == 1 and auto.total_time() <= 15.0)
	var credits := CreditsScreen.new()
	tree.get_root().add_child(credits)
	var credits_count: Array[int] = [0]
	credits.finished.connect(func() -> void: credits_count[0] += 1)
	await tree.process_frame
	credits.skip()
	credits.skip()
	TestWorld.rec(out, "TC-063 final: os creditos sao pulaveis e fecham uma unica vez", credits_count[0] == 1 and credits.is_done())
	await tree.process_frame


func _map(tree: SceneTree, out: Array) -> void:
	var map := GalaxyMap.new()
	tree.get_root().add_child(map)
	await tree.process_frame
	map.show_state(_save_with(5))
	TestWorld.rec(out, "TC-063 mapa: com cinco sementes mostra 5 de 6, uma raiz restante e nenhum botao de creditos",
			"5 de 6" in map.banner_text() and not map._credits.visible and GalaxyState.root_visible(_save_with(5), 5))
	var six: Dictionary = _save_with(6)
	map.show_state(six)
	var roots_left: int = 0
	var all_saved: bool = true
	for i in 6:
		if GalaxyState.root_visible(six, i):
			roots_left += 1
		all_saved = all_saved and GalaxyState.status(six, i) == GalaxyState.Status.SAVED
	TestWorld.rec(out, "TC-063 mapa: com seis sementes os seis planetas estao Salvos, nenhuma raiz resta e o mapa anuncia o fim de Caeldron com botao de creditos",
			roots_left == 0 and all_saved and "concluida" in map.banner_text() and map._credits.visible)
	map.queue_free()
	await tree.process_frame


func _children_of(flow: Node, script: GDScript) -> Array:
	return flow.get_children().filter(func(n: Node) -> bool: return is_instance_of(n, script))


func _flow(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("ending")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	var ledger := ProgressLedger.new()
	for i in 5:
		ledger.commit_seed(flow.profile, GalaxyState.planets()[i], "relic_%s" % RELICS[i], "astralis_memory_%s" % RELICS[i])
	flow.level.queue_free()
	flow.level = null
	flow._start_level("umbraxis_36")
	await tree.process_frame
	var arena: UmbraxisLevel36 = flow.level as UmbraxisLevel36
	TestWorld.rec(out, "TC-063 fluxo: antes da sexta semente nao ha sequencia final", flow.ending_plays == 0 and _children_of(flow, CaeldronDeath).is_empty())
	arena.boss.phase = VyrkanBoss.Phase.FINISH
	arena.boss.finish_triad()
	await tree.process_frame
	TestWorld.rec(out, "TC-063 fluxo: destruir a sexta semente toca primeiro a reacao de Caeldron e so depois a morte (encadeadas), sem pausar ainda",
			flow.reaction_plays == 1 and _children_of(flow, CaeldronReaction).size() == 1 and _children_of(flow, CaeldronDeath).is_empty()
			and flow.ending_plays == 0 and not tree.paused)
	_children_of(flow, CaeldronReaction)[0].skip()
	await tree.process_frame
	TestWorld.rec(out, "TC-063 fluxo: pular a reacao inicia a morte de Caeldron (jogo pausado) e a pausa do jogador fica desligada durante o fim",
			flow.ending_plays == 1 and _children_of(flow, CaeldronDeath).size() == 1 and tree.paused)
	flow.toggle_pause()
	TestWorld.rec(out, "TC-063 fluxo: durante o fim o botao de pausa nao abre o menu de pausa", not flow.is_paused())
	var saved: Dictionary = SaveService.new(dir + "/slot1.json").load_save()["data"]
	TestWorld.rec(out, "TC-063 fluxo: o fim e salvo ANTES de a cutscene terminar (transacao, mensagem final e trofeu no disco)",
			ProgressLedger.ENDING_TX in saved["economy"]["claimed_transaction_ids"] and ProgressLedger.FINAL_MESSAGE_ID in saved["story"]["memories"]
			and ProgressLedger.CAMPAIGN_TROPHY_ID in saved["story"]["trophies"] and "seed_umbraxis" in saved["world"]["seed_destroyed_ids"])
	_children_of(flow, CaeldronDeath)[0].skip()
	await tree.process_frame
	TestWorld.rec(out, "TC-063 fluxo: pular a morte abre os creditos; pular os creditos devolve o jogo (despausa)",
			flow.credits_plays == 1 and _children_of(flow, CreditsScreen).size() == 1 and tree.paused)
	_children_of(flow, CreditsScreen)[0].skip()
	await tree.process_frame
	TestWorld.rec(out, "TC-063 fluxo: depois dos creditos o jogo roda de novo e a sequencia contou 1x", not tree.paused and flow.ending_plays == 1)
	# Idempotencia: recarregar, morrer e re-emitir a semente nao repete nada.
	flow._back_to_menu()
	await tree.process_frame
	await tree.process_frame
	flow.continue_game(true, "umbraxis_36")
	await tree.process_frame
	var again: UmbraxisLevel36 = flow.level as UmbraxisLevel36
	again.controller._on_life_lost(&"abyss")
	for i in 60:
		await tree.physics_frame
	again.seed_destroyed.emit(false)
	await tree.process_frame
	TestWorld.rec(out, "TC-063 fluxo: recarregar, morrer e re-emitir a semente NAO repete reacao, morte nem creditos (idempotente)",
			flow.ending_plays == 1 and flow.reaction_plays == 1 and flow.credits_plays == 1 and _children_of(flow, CaeldronDeath).is_empty()
			and _children_of(flow, CreditsScreen).is_empty() and _children_of(flow, CaeldronReaction).is_empty() and not tree.paused)
	# Pos-jogo: mapa, revisita e Caeldron morto.
	flow._back_to_menu()
	await tree.process_frame
	await tree.process_frame
	flow.continue_game(false)
	await tree.process_frame
	var p: Dictionary = flow.profile
	TestWorld.rec(out, "TC-063 pos-jogo: o mapa carregado do save mostra a campanha concluida e os creditos disponiveis",
			flow.map != null and "concluida" in flow.map.banner_text() and flow.map._credits.visible)
	var revisit_ok: bool = true
	for i in 6:
		revisit_ok = revisit_ok and GalaxyState.status(p, i) == GalaxyState.Status.SAVED and GalaxyState.can_travel(p, i) == GalaxyState.planets()[i].playable
	TestWorld.rec(out, "TC-063 pos-jogo: os seis planetas continuam Salvos e visitaveis (viagem segue a flag jogavel; os produzidos viajam)",
			revisit_ok and GalaxyState.planets().all(func(pl: PlanetDefinition) -> bool: return pl.playable))
	flow.map.credits_requested.emit()
	await tree.process_frame
	TestWorld.rec(out, "TC-063 pos-jogo: rever os creditos pelo mapa nao pausa nem conta como fim", flow.credits_plays == 2 and flow.ending_plays == 1 and not tree.paused
			and _children_of(flow, CreditsScreen).size() == 1)
	_children_of(flow, CreditsScreen)[0].skip()
	await tree.process_frame
	var seeds_before: Array = p["world"]["seed_destroyed_ids"].duplicate()
	var tx_before: Array = p["economy"]["claimed_transaction_ids"].duplicate()
	flow._start_level(LevelCatalog.next_for(p, "sylvara"))
	await tree.process_frame
	for i in 30:
		await tree.physics_frame
	TestWorld.rec(out, "TC-063 pos-jogo: revisitar um planeta salvo nao revive Caeldron nem reseta a vitoria (sementes, transacoes e fim intactos)",
			flow.level != null and p["world"]["seed_destroyed_ids"] == seeds_before and p["economy"]["claimed_transaction_ids"] == tx_before
			and GalaxyState.campaign_complete(p) and not GalaxyState.caeldron_alive(p) and flow.ending_plays == 1 and _children_of(flow, CaeldronDeath).is_empty())
	tree.paused = false
	flow.queue_free()
	await tree.process_frame
