extends RefCounted
## Vyrkan no fluxo do jogo (TC-027, TC-028, TC-026 parcial): semente salva na hora, reacao 1x, chefe nao ressuscita, mapa. Separada de suite_boss (limite de linhas).


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _flow_and_map(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _flow_and_map(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("boss")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	flow.level.queue_free()
	flow.level = null
	flow._start_level("sylvara_06")
	await tree.process_frame
	var arena: SylvaraLevel06 = flow.level as SylvaraLevel06
	arena.boss.phase = VyrkanBoss.Phase.FINISH
	arena.boss.finish_triad()
	await tree.process_frame
	TestWorld.rec(out, "TC-027 fluxo: derrota -> semente salva NA HORA (antes de abrir o bau) e a reacao de Caeldron toca 1x",
			SaveService.new(dir + "/slot1.json").load_save()["data"]["world"]["seed_destroyed_ids"] == ["seed_sylvara"] and flow.reaction_plays == 1)
	TestWorld.rec(out, "TC-028 fluxo: derrota libera o bau e a reliquia/memoria entram no perfil",
			not arena.chest.locked and "relic_sylvara" in flow.profile["economy"]["owned_items"] and "astralis_memory_sylvara" in flow.profile["story"]["memories"])
	# Voltar ao menu SEM abrir o bau e recarregar: a vitoria persiste; o chefe nao ressuscita; nada duplica.
	flow._back_to_menu()
	await tree.process_frame
	await tree.process_frame
	flow.continue_game(true, "sylvara_06")
	await tree.process_frame
	var again: SylvaraLevel06 = flow.level as SylvaraLevel06
	TestWorld.rec(out, "TC-028 recarregar depois da vitoria: arena restaurada, sem luta, chefe derrotado e bau liberado",
			again.boss.is_defeated() and not again.chest.locked and flow.reaction_plays == 1)
	again.rig.body.global_position = Vector3(20, 1, 0)
	again.controller._on_life_lost(&"abyss")
	for i in 120:
		await tree.physics_frame
	TestWorld.rec(out, "TC-028 o chefe nunca ressuscita (nem depois de uma morte do heroi)", again.boss.is_defeated()
			and again.boss.lanes[0].collision_layer == 0 and again.boss.lanes[1].collision_layer == 0)
	var profile: Dictionary = flow.profile
	TestWorld.rec(out, "TC-028 mapa apos a vitoria REAL: Sylvara Salvo, raiz removida, Cristalia Disponivel e viajavel",
			GalaxyState.status(profile, 0) == GalaxyState.Status.SAVED and not GalaxyState.root_visible(profile, 0)
			and GalaxyState.status(profile, 1) == GalaxyState.Status.AVAILABLE and GalaxyState.can_travel(profile, 1))
	tree.paused = false
	flow.queue_free()
	await tree.process_frame
