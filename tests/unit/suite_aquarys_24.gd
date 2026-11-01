extends RefCounted
## Thalassa (fase 24): etapas proprias, combinacao do fluxo, folha flutuante, Triade, semente de Aquarys, reinicio das aguas e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _stages(tree, out)
	await _reset(tree, out)
	await _flow_and_map(tree, out)
	await _bot(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _arena(tree: SceneTree) -> AquarysLevel24:
	var level := AquarysLevel24.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _stages(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel24 = _arena(tree)
	await _settle(tree, 3)
	var b: ThalassaBoss = level.boss
	TestWorld.rec(out, "TC-048 Thalassa: etapas fora de ordem NAO avancam a fase (folhas e protecao antes do fluxo)",
			not b.mechanism_done(&"leaves") and not b.mechanism_done(&"shield") and b.phase == 1)
	TestWorld.rec(out, "TC-048 Thalassa: na fase 1 so as comportas do fluxo sao interagiveis",
			level.west_gate.can_interact() and level.east_gate.can_interact() and not level.wave_gate.can_interact() and not level.shield.can_interact())
	level.east_decoy.interact()
	level.west_gate.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-048 Thalassa: nivel errado no Leste (isca) nao estabiliza o fluxo e a fase nao avanca",
			level.west.level == 2 and level.east.level == 2 and not level.flux.is_lit() and b.phase == 1)
	level.east_gate.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-048 Thalassa etapa 1: Oeste 2 + Leste 1 acendem o fluxo e avancam para a fase 2", level.flux.is_lit() and b.phase == 2)
	TestWorld.rec(out, "TC-048 Thalassa fase 2: so a onda responde (comportas do fluxo bloqueadas)",
			level.wave_gate.can_interact() and not level.west_gate.can_interact() and not level.east_decoy.can_interact() and not level.shield.can_interact())
	TestWorld.rec(out, "TC-048 Thalassa fase 2: a folha esta rente ao chao antes da onda (topo em y=0)", is_equal_approx(level.leaf.position.y + 0.2, 0.0))
	level.wave_gate.interact()
	await _settle(tree, 200)
	TestWorld.rec(out, "TC-048 Thalassa etapa 2: a onda ergue a folha 4 m (topo em y=4) e avanca para a fase 3",
			level.wave.level == 2 and is_equal_approx(level.leaf.position.y + 0.2, 4.0) and b.phase == 3)
	TestWorld.rec(out, "TC-048 Thalassa etapa 3: so a protecao responde, e o Triade so na FINISH", level.shield.can_interact() and not level.triad.nodes[0].can_interact())
	level.shield.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-048 Thalassa: desativar a protecao libera o Golpe Triade (fase FINISH)", b.phase == VyrkanBoss.Phase.FINISH and level.triad.nodes[0].can_interact())
	level.queue_free()
	await _settle(tree, 3)


func _reset(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel24 = _arena(tree)
	await _settle(tree, 3)
	level.west_gate.interact()
	level.east_gate.interact()
	await _settle(tree, 3)
	level.wave_gate.interact()
	await _settle(tree, 30)
	var mid: float = level.leaf.position.y
	level.rig.body.global_position = Vector3(0.0, 1.0, 0.0)
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-048 Thalassa: reaparecer reinicia as tres aguas, a folha e o chefe de forma deterministica (idempotente)",
			mid > -0.2 and level.boss.phase == 1 and level.west.level == 0 and level.east.level == 0 and level.wave.level == 0
			and level.west.is_settled() and level.wave.is_settled() and is_equal_approx(level.leaf.position.y, -0.2) and not level.flux.is_lit())
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-048 Thalassa: reiniciar de novo e idempotente", level.boss.phase == 1 and level.west.level == 0 and level.wave.level == 0
			and level.west_gate.can_interact())
	level.queue_free()
	await _settle(tree, 3)


func _flow_and_map(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("thalassa")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	var ledger := ProgressLedger.new()
	ledger.commit_seed(flow.profile, GalaxyState.planets()[0], "relic_sylvara", "astralis_memory_sylvara")
	ledger.commit_seed(flow.profile, GalaxyState.planets()[1], "relic_cristalia", "astralis_memory_cristalia")
	ledger.commit_seed(flow.profile, GalaxyState.planets()[2], "relic_mecatron", "astralis_memory_mecatron")
	flow.level.queue_free()
	flow.level = null
	flow._start_level("aquarys_24")
	await tree.process_frame
	var arena: AquarysLevel24 = flow.level as AquarysLevel24
	arena.boss.phase = VyrkanBoss.Phase.FINISH
	arena.boss.finish_triad()
	await tree.process_frame
	TestWorld.rec(out, "TC-049 Thalassa: derrota -> semente de Aquarys salva na hora e a reacao de Caeldron (MEDO, quarta raiz) toca 1x",
			"seed_aquarys" in SaveService.new(dir + "/slot1.json").load_save()["data"]["world"]["seed_destroyed_ids"] and flow.reaction_plays == 1
			and "MEDO" in arena.reaction_message)
	TestWorld.rec(out, "TC-049 Thalassa: guardiao libertado, reliquia e memoria de Aquarys no perfil e bau liberado",
			"thalassa" in flow.profile["world"]["boss_freed_ids"] and "relic_aquarys" in flow.profile["economy"]["owned_items"]
			and "astralis_memory_aquarys" in flow.profile["story"]["memories"] and not arena.chest.locked)
	flow._back_to_menu()
	await tree.process_frame
	await tree.process_frame
	flow.continue_game(true, "aquarys_24")
	await tree.process_frame
	var again: AquarysLevel24 = flow.level as AquarysLevel24
	again.controller._on_life_lost(&"abyss")
	for i in 90:
		await tree.physics_frame
	TestWorld.rec(out, "TC-049 Thalassa: recarregar apos a vitoria abre a arena restaurada e o chefe nao ressuscita (nem apos morte)",
			again.boss.is_defeated() and not again.chest.locked and flow.reaction_plays == 1)
	var p: Dictionary = flow.profile
	TestWorld.rec(out, "TC-049 mapa: Aquarys Salva (raiz removida), Aerion Disponivel e viajavel (jogavel)",
			GalaxyState.status(p, 3) == GalaxyState.Status.SAVED and not GalaxyState.root_visible(p, 3)
			and GalaxyState.status(p, 4) == GalaxyState.Status.AVAILABLE and GalaxyState.can_travel(p, 4))
	TestWorld.rec(out, "mapa: viajar para Aquarys abre a primeira fase principal do planeta (fase 19) e Aquarys e jogavel",
			LevelCatalog.next_for(SaveData.new_game(), "aquarys") == "aquarys_19" and GalaxyState.planets()[3].playable)
	tree.paused = false
	flow.queue_free()
	await tree.process_frame


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel24 = _arena(tree)
	await tree.physics_frame
	var bot := LevelBot24.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: derrota Thalassa (fluxo, onda e folha, protecao, Golpe Triade com 3 herois) e abre o bau sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f fase=%d heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.boss.phase, level.rig.body.profile.hero_id])
	if finished:
		TestWorld.rec(out, "bot: semente de Aquarys destruida, reliquia no perfil, 6 moedas e nenhuma vida perdida",
				"seed_aquarys" in level.save["world"]["seed_destroyed_ids"] and "relic_aquarys" in level.save["economy"]["owned_items"]
				and c.session.coin_ids.size() == 6 and c.session.lives_lost == 0,
				"(moedas=%d vidas perdidas=%d)" % [c.session.coin_ids.size(), c.session.lives_lost])
	level.queue_free()
