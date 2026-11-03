extends RefCounted
## Cutscene de libertacao do guardiao: toca 1x ao destruir a semente pela primeira vez (com o nome do guardiao), e pulavel; sobreposta a
## reacao de Caeldron sem bloquear; nao toca ao recarregar nem altera o save.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_text(out)
	await _flow(tree, out)
	return out


func _text(out: Array) -> void:
	var scene := GuardianLiberation.new()
	scene.guardian_name = "Zefrion"
	scene.planet_name = "Aerion"
	TestWorld.rec(out, "libertacao: as tres falas em sequencia, a do meio com o nome do guardiao e a ultima com a dica de pular",
			scene.lines_at(0.5) == "A corrupcao se desfaz..." and scene.lines_at(2.0) == "Zefrion esta livre."
			and scene.lines_at(4.0).contains("Aerion") and scene.lines_at(4.0).contains("pular"))
	scene.free()


func _flow(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("liberation")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	var ledger := ProgressLedger.new()
	for i in 4:
		var planet: PlanetDefinition = GalaxyState.planets()[i]
		ledger.commit_seed(flow.profile, planet, "relic_%s" % planet.planet_id, "astralis_memory_%s" % planet.planet_id)
	flow.level.queue_free()
	flow.level = null
	flow._start_level("aerion_30")
	await tree.process_frame
	var arena: AerionLevel30 = flow.level as AerionLevel30
	var before: Dictionary = flow.profile.duplicate(true)
	arena.boss.phase = VyrkanBoss.Phase.FINISH
	arena.boss.finish_triad()
	await tree.process_frame
	var scenes: Array = flow.get_children().filter(func(n: Node) -> bool: return n is GuardianLiberation)
	var reactions: Array = flow.get_children().filter(func(n: Node) -> bool: return n is CaeldronReaction)
	TestWorld.rec(out, "libertacao: ao destruir a semente pela 1a vez toca a cutscene do guardiao (Zefrion), sobreposta a reacao de Caeldron",
			scenes.size() == 1 and flow.liberation_plays == 1 and reactions.size() == 1 and (scenes[0] as GuardianLiberation).guardian_name == "Zefrion"
			and (scenes[0] as GuardianLiberation).planet_name == arena.planet.display_name)
	var skipped: Array[bool] = [false]
	(scenes[0] as GuardianLiberation).finished.connect(func() -> void: skipped[0] = true)
	(scenes[0] as GuardianLiberation).skip()
	await tree.process_frame
	TestWorld.rec(out, "libertacao: pular encerra so a cutscene (a reacao de Caeldron segue) e nao altera o perfil alem da vitoria",
			skipped[0] and flow.get_children().filter(func(n: Node) -> bool: return n is GuardianLiberation).is_empty()
			and flow.get_children().filter(func(n: Node) -> bool: return n is CaeldronReaction).size() == 1
			and flow.profile["economy"]["coin_balance"] == before["economy"]["coin_balance"] and "zefrion" in flow.profile["world"]["boss_freed_ids"])
	flow._back_to_menu()
	await tree.process_frame
	await tree.process_frame
	flow.continue_game(true, "aerion_30")
	await tree.process_frame
	var again: AerionLevel30 = flow.level as AerionLevel30
	await tree.process_frame
	TestWorld.rec(out, "libertacao: recarregar a arena restaurada NAO repete a cutscene",
			again.boss.is_defeated() and flow.liberation_plays == 1
			and flow.get_children().filter(func(n: Node) -> bool: return n is GuardianLiberation).is_empty())
	tree.paused = false
	flow.queue_free()
	await tree.process_frame
