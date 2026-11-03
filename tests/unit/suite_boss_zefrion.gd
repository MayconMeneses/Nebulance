extends RefCounted
## Zefrion (fase 30): etapas proprias (controles de vento, farol, corrente e nucleo), Triade, semente de Aerion, reinicio e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _stages(tree, out)
	await _sync_and_reset(tree, out)
	await _flow_and_map(tree, out)
	await _bot(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _arena(tree: SceneTree) -> AerionLevel30:
	var level := AerionLevel30.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _stages(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel30 = _arena(tree)
	await _settle(tree, 3)
	var b: ZefrionBoss = level.boss
	TestWorld.rec(out, "TC-055 Zefrion: etapas fora de ordem NAO avancam a fase (farol e nucleo antes dos controles de vento)",
			not b.mechanism_done(&"climb") and not b.mechanism_done(&"glide") and b.phase == 1)
	TestWorld.rec(out, "TC-055 Zefrion: na fase 1 so os controles de vento sao interagiveis",
			level.anchor_a.can_interact() and level.anchor_b.can_interact() and not level.beacon.can_interact() and not level.shield.can_interact())
	TestWorld.rec(out, "TC-055 Zefrion: a corrente do nucleo comeca parada (depende do farol)", not level.updraft.is_blowing())
	level.anchor_a.interact()
	level.anchor_b.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-055 Zefrion etapa 1: os dois controles ancorados juntos avancam para a fase 2", b.phase == 2)
	TestWorld.rec(out, "TC-055 Zefrion fase 2: so o farol responde", level.beacon.can_interact() and not level.anchor_a.can_interact() and not level.shield.can_interact())
	level.beacon.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-055 Zefrion etapa 2: acender o farol liga a corrente e avanca para a fase 3", level.updraft.is_blowing() and b.phase == 3)
	TestWorld.rec(out, "TC-055 Zefrion etapa 3: so a protecao responde, e o Triade so na FINISH", level.shield.can_interact() and not level.triad.nodes[0].can_interact())
	level.rig.body.global_position = Vector3(43.0, 8.0, 0.0)
	await _settle(tree, 1)
	TestWorld.rec(out, "TC-055 Zefrion: em volta do nucleo a gravidade e reduzida (escala 0,6)", is_equal_approx(ZoneEffects.gravity_scale(level.rig.body), 0.6))
	level.shield.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-055 Zefrion: desativar a protecao libera o Golpe Triade (fase FINISH)", b.phase == VyrkanBoss.Phase.FINISH and level.triad.nodes[0].can_interact())
	level.queue_free()
	await _settle(tree, 3)


func _sync_and_reset(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel30 = _arena(tree)
	await _settle(tree, 3)
	level.anchor_a.interact()
	await _settle(tree, int((level.anchor_a.hold_time + 0.5) * 60.0))
	TestWorld.rec(out, "TC-055 Zefrion: um controle sozinho se desliga depois do tempo (sincronizacao exigida)", not level.anchor_a.is_active and level.boss.phase == 1)
	level.anchor_a.interact()
	await _settle(tree, 60)
	level.anchor_b.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-055 Zefrion: ligar o segundo ainda dentro da janela avanca a fase", level.boss.phase == 2)
	level.beacon.interact()
	await _settle(tree, 3)
	level.rig.body.global_position = Vector3(0.0, 1.0, 0.0)
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-055 Zefrion: reaparecer reinicia controles, farol, corrente e chefe (idempotente)",
			level.boss.phase == 1 and not level.anchor_a.is_active and not level.anchor_b.is_active and not level.beacon.is_active
			and not level.updraft.is_blowing() and level.anchor_a.can_interact())
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-055 Zefrion: reiniciar de novo e idempotente", level.boss.phase == 1 and not level.beacon.is_active)
	level.queue_free()
	await _settle(tree, 3)


func _flow_and_map(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("zefrion")
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
	ledger.commit_seed(flow.profile, GalaxyState.planets()[3], "relic_aquarys", "astralis_memory_aquarys")
	flow.level.queue_free()
	flow.level = null
	flow._start_level("aerion_30")
	await tree.process_frame
	var arena: AerionLevel30 = flow.level as AerionLevel30
	arena.boss.phase = VyrkanBoss.Phase.FINISH
	arena.boss.finish_triad()
	await tree.process_frame
	TestWorld.rec(out, "TC-056 Zefrion: derrota -> semente de Aerion salva na hora e a reacao de Caeldron (DESESPERO, quinta raiz) toca 1x",
			"seed_aerion" in SaveService.new(dir + "/slot1.json").load_save()["data"]["world"]["seed_destroyed_ids"] and flow.reaction_plays == 1
			and "DESESPERO" in arena.reaction_message)
	TestWorld.rec(out, "TC-056 Zefrion: guardiao libertado, reliquia e memoria de Aerion no perfil e bau liberado",
			"zefrion" in flow.profile["world"]["boss_freed_ids"] and "relic_aerion" in flow.profile["economy"]["owned_items"]
			and "astralis_memory_aerion" in flow.profile["story"]["memories"] and not arena.chest.locked)
	flow._back_to_menu()
	await tree.process_frame
	await tree.process_frame
	flow.continue_game(true, "aerion_30")
	await tree.process_frame
	var again: AerionLevel30 = flow.level as AerionLevel30
	again.controller._on_life_lost(&"abyss")
	for i in 90:
		await tree.physics_frame
	TestWorld.rec(out, "TC-056 Zefrion: recarregar apos a vitoria abre a arena restaurada e o chefe nao ressuscita (nem apos morte)",
			again.boss.is_defeated() and not again.chest.locked and flow.reaction_plays == 1)
	var p: Dictionary = flow.profile
	TestWorld.rec(out, "TC-056 mapa: Aerion Salva (raiz removida), Aquarys Salva e Umbraxis Disponivel e viajavel (jogavel)",
			GalaxyState.status(p, 4) == GalaxyState.Status.SAVED and not GalaxyState.root_visible(p, 4)
			and GalaxyState.status(p, 5) == GalaxyState.Status.AVAILABLE and GalaxyState.can_travel(p, 5))
	TestWorld.rec(out, "mapa: viajar para Aerion abre a primeira fase principal do planeta (fase 25) e Aerion e jogavel",
			LevelCatalog.next_for(SaveData.new_game(), "aerion") == "aerion_25" and GalaxyState.planets()[4].playable)
	tree.paused = false
	flow.queue_free()
	await tree.process_frame


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel30 = _arena(tree)
	await tree.physics_frame
	var bot := LevelBot30.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: derrota Zefrion (controles de vento, escalada, planeio ate o nucleo, Golpe Triade com 3 herois) e abre o bau sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f fase=%d heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.boss.phase, level.rig.body.profile.hero_id])
	if finished:
		TestWorld.rec(out, "bot: semente de Aerion destruida, reliquia no perfil, 6 moedas e nenhuma vida perdida",
				"seed_aerion" in level.save["world"]["seed_destroyed_ids"] and "relic_aerion" in level.save["economy"]["owned_items"]
				and c.session.coin_ids.size() == 6 and c.session.lives_lost == 0,
				"(moedas=%d vidas perdidas=%d)" % [c.session.coin_ids.size(), c.session.lives_lost])
	level.queue_free()
