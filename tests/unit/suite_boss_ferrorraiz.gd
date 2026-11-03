extends RefCounted
## Ferrorraiz (TC-027..029, TC-035): etapas proprias, sincronizacao dos interruptores, ancora, Triade, semente de Mecatron, reinicio e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _stages(tree, out)
	await _sync(tree, out)
	await _flow_and_map(tree, out)
	await _bot(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _arena(tree: SceneTree) -> MecatronLevel18:
	var level := MecatronLevel18.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _stages(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel18 = _arena(tree)
	await _settle(tree, 3)
	var b: FerrorraizBoss = level.boss
	TestWorld.rec(out, "TC-029 Ferrorraiz: mecanismos fora de ordem NAO avancam a fase (ancora e protecao antes da energia)",
			not b.mechanism_done(&"anchors") and not b.mechanism_done(&"shield") and b.phase == 1)
	TestWorld.rec(out, "TC-029 Ferrorraiz: na fase 1 so os interruptores de energia sao interagiveis",
			level.power_a.can_interact() and level.power_b.can_interact() and not level.anchor.control.can_interact() and not level.shield.can_interact())
	level.power_a.interact()
	level.power_b.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-029 Ferrorraiz etapa 1: os dois interruptores ligados juntos avancam para a fase 2", b.phase == 2)
	TestWorld.rec(out, "TC-029 Ferrorraiz fase 2: so a ancora responde", level.anchor.control.can_interact() and not level.power_a.can_interact() and not level.shield.can_interact())
	level.anchor.control.interact()
	await _settle(tree, 200)
	TestWorld.rec(out, "TC-029 Ferrorraiz etapa 2: a ancora no polo oposto (4 m acima) avanca para a fase 3", level.anchor.progress == 1.0 and b.phase == 3)
	TestWorld.rec(out, "TC-029 Ferrorraiz etapa 3: so a protecao responde, e o Triade so na FINISH", level.shield.can_interact() and not level.triad.nodes[0].can_interact())
	level.shield.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-029 Ferrorraiz: abrir a protecao libera o Golpe Triade (fase FINISH)", b.phase == VyrkanBoss.Phase.FINISH and level.triad.nodes[0].can_interact())
	level.queue_free()


func _sync(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel18 = _arena(tree)
	await _settle(tree, 3)
	level.power_a.interact()
	await _settle(tree, int((level.power_a.hold_time + 0.5) * 60.0))
	TestWorld.rec(out, "TC-035 Ferrorraiz: um interruptor sozinho se desliga depois do tempo (sincronizacao exigida)", not level.power_a.is_active and level.boss.phase == 1)
	level.power_a.interact()
	await _settle(tree, 60)
	level.power_b.interact()
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-035 Ferrorraiz: ligar o segundo ainda dentro da janela avanca a fase", level.boss.phase == 2)
	level.anchor.control.interact()
	await _settle(tree, 30)
	var mid: float = level.anchor.progress
	level.rig.body.global_position = Vector3(0.0, 1.0, 0.0)
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-035 Ferrorraiz: reaparecer reinicia energia, ancora e chefe (idempotente)", mid > 0.0 and level.boss.phase == 1
			and not level.power_a.is_active and not level.power_b.is_active and level.anchor.progress == 0.0 and not level.anchor.control.is_active)
	level.queue_free()


func _flow_and_map(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("ferrorraiz")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	ProgressLedger.new().commit_seed(flow.profile, GalaxyState.planets()[0], "relic_sylvara", "astralis_memory_sylvara")
	ProgressLedger.new().commit_seed(flow.profile, GalaxyState.planets()[1], "relic_cristalia", "astralis_memory_cristalia")
	flow.level.queue_free()
	flow.level = null
	flow._start_level("mecatron_18")
	await tree.process_frame
	var arena: MecatronLevel18 = flow.level as MecatronLevel18
	arena.boss.phase = VyrkanBoss.Phase.FINISH
	arena.boss.finish_triad()
	await tree.process_frame
	TestWorld.rec(out, "TC-027 Ferrorraiz: derrota -> semente de Mecatron salva na hora e a reacao de Caeldron (terceira raiz) toca 1x",
			"seed_mecatron" in SaveService.new(dir + "/slot1.json").load_save()["data"]["world"]["seed_destroyed_ids"] and flow.reaction_plays == 1
			and "tripulacao" in arena.reaction_message)
	TestWorld.rec(out, "TC-028 Ferrorraiz: guardiao libertado, reliquia e memoria de Mecatron no perfil e bau liberado",
			"ferrorraiz" in flow.profile["world"]["boss_freed_ids"] and "relic_mecatron" in flow.profile["economy"]["owned_items"]
			and "astralis_memory_mecatron" in flow.profile["story"]["memories"] and not arena.chest.locked)
	flow._back_to_menu()
	await tree.process_frame
	await tree.process_frame
	flow.continue_game(true, "mecatron_18")
	await tree.process_frame
	var again: MecatronLevel18 = flow.level as MecatronLevel18
	again.controller._on_life_lost(&"abyss")
	for i in 90:
		await tree.physics_frame
	TestWorld.rec(out, "TC-028 Ferrorraiz: recarregar apos a vitoria abre a arena restaurada e o chefe nao ressuscita (nem apos morte)",
			again.boss.is_defeated() and not again.chest.locked and flow.reaction_plays == 1)
	var p: Dictionary = flow.profile
	TestWorld.rec(out, "TC-028 mapa: Mecatron Salva (raiz removida) e Aquarys Disponivel e viajavel (jogavel); Aerion ainda bloqueado (depende de Aquarys)",
			GalaxyState.status(p, 2) == GalaxyState.Status.SAVED and not GalaxyState.root_visible(p, 2)
			and GalaxyState.status(p, 3) == GalaxyState.Status.AVAILABLE and GalaxyState.can_travel(p, 3)
			and GalaxyState.status(p, 4) == GalaxyState.Status.LOCKED and not GalaxyState.can_travel(p, 4))
	TestWorld.rec(out, "mapa: viajar para Mecatron abre a primeira fase principal do planeta (fase 13)",
			LevelCatalog.next_for(SaveData.new_game(), "mecatron") == "mecatron_13")
	tree.paused = false
	flow.queue_free()
	await tree.process_frame


func _bot(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel18 = _arena(tree)
	await tree.physics_frame
	var bot := LevelBot18.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: derrota Ferrorraiz (energia, ancora, protecao, Golpe Triade com 3 herois) e abre o bau sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f fase=%d heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.boss.phase, level.rig.body.profile.hero_id])
	if finished:
		TestWorld.rec(out, "bot: semente de Mecatron destruida, reliquia no perfil, 6 moedas e nenhuma vida perdida",
				"seed_mecatron" in level.save["world"]["seed_destroyed_ids"] and "relic_mecatron" in level.save["economy"]["owned_items"]
				and c.session.coin_ids.size() == 6 and c.session.lives_lost == 0,
				"(moedas=%d vidas perdidas=%d)" % [c.session.coin_ids.size(), c.session.lives_lost])
	level.queue_free()
