extends RefCounted
## Vyrkan + semente (TC-027, TC-028, TC-029, TC-026 parcial): telegraph, fases, Triade, transacao unica, sem ressurreicao, mapa, bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _design(tree, out)
	await _damage_rules(tree, out)
	await _triad(tree, out)
	_seed_ledger(out)
	await _flow_and_map(tree, out)
	await _camera(tree, out)
	await _bot(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _arena(tree: SceneTree, save: Dictionary = {}) -> SylvaraLevel06:
	var level := SylvaraLevel06.new()
	level.use_input_reader = false
	if not save.is_empty():
		level.save = save
	tree.get_root().add_child(level)
	return level


func _design(tree: SceneTree, out: Array) -> void:
	var tele_ok: bool = true
	var lanes: Array[int] = []
	var cycle: Array[float] = []
	for ph in [1, 2, 3]:
		tele_ok = tele_ok and VyrkanBoss.TIMING[ph].x >= VyrkanBoss.MIN_TELEGRAPH
		var most: int = 0
		for pattern in VyrkanBoss.PATTERNS[ph]:
			most = maxi(most, pattern.size())
		lanes.append(most)
		cycle.append(VyrkanBoss.TIMING[ph].x + VyrkanBoss.TIMING[ph].y + VyrkanBoss.TIMING[ph].z)
	TestWorld.rec(out, "TC-029 Vyrkan: todo aviso (telegraph) dura >= 0,6 s em todas as fases", tele_ok)
	TestWorld.rec(out, "TC-029 Vyrkan: cada fase e mais complexa (mais faixas e ciclo mais curto)",
			lanes[0] < lanes[1] and lanes[1] < lanes[2] and cycle[0] > cycle[1] and cycle[1] > cycle[2], "(faixas=%s ciclos=%s)" % [str(lanes), str(cycle)])
	var level: SylvaraLevel06 = _arena(tree)
	await tree.physics_frame
	var b: VyrkanBoss = level.boss
	TestWorld.rec(out, "TC-029 etapas: so o mecanismo CERTO avanca a fase (ordem Rocco -> Zuri -> Pipa)",
			not b.mechanism_done(&"pipa") and not b.mechanism_done(&"zuri") and b.phase == 1 and b.mechanism_done(&"rocco") and b.phase == 2)
	TestWorld.rec(out, "TC-029 etapas: mecanismos de Zuri e Pipa so ficam habilitados na sua fase",
			level.zuri_mechanism.enabled and not level.pipa_mechanism.enabled)
	b.mechanism_done(&"zuri")
	TestWorld.rec(out, "TC-029 etapas: fase 3 habilita so o mecanismo de Pipa", level.pipa_mechanism.enabled and not level.zuri_mechanism.enabled and b.phase == 3)
	TestWorld.rec(out, "TC-029 Golpe Triade so existe na fase FINISH (antes nao e interagivel)", not level.triad.nodes[0].can_interact())
	level.queue_free()


func _damage_rules(tree: SceneTree, out: Array) -> void:
	var min_tele_frames: Array[int] = []
	for ph in [1, 2, 3]:
		var level: SylvaraLevel06 = _arena(tree)
		await tree.physics_frame
		level.boss.phase = ph
		level.boss.restart_cycle()
		var lane: RootLane = level.boss.lanes[1] if ph != 2 else level.boss.lanes[0]
		var tele_frames: int = 0
		var shortest: int = 1000
		var prev: RootLane.State = lane.state
		var damaged_in_telegraph: bool = false
		var damaged_in_active: bool = false
		var hearts: int = level.rig.vitals.hearts
		for i in 700:
			level.rig.body.global_position = Vector3(lane.position.x, 0.9, 0.0)
			level.rig.body.velocity = Vector3.ZERO
			await tree.physics_frame
			if lane.state == RootLane.State.TELEGRAPH:
				tele_frames += 1
			if prev == RootLane.State.TELEGRAPH and lane.state == RootLane.State.ACTIVE:
				shortest = mini(shortest, tele_frames)
				tele_frames = 0
			if lane.state != RootLane.State.TELEGRAPH and prev != RootLane.State.TELEGRAPH:
				tele_frames = 0
			prev = lane.state
			var now: int = level.rig.vitals.hearts
			if now < hearts:
				damaged_in_active = damaged_in_active or lane.state == RootLane.State.ACTIVE
				damaged_in_telegraph = damaged_in_telegraph or lane.state == RootLane.State.TELEGRAPH
			hearts = now
			level.rig.vitals.tick(2.0)
		min_tele_frames.append(shortest)
		TestWorld.rec(out, "TC-029 fase %d: parado na faixa durante o AVISO nao leva dano; so a erupcao ATIVA fere" % ph,
				not damaged_in_telegraph and damaged_in_active)
		level.queue_free()
	var ok: bool = true
	for f in min_tele_frames:
		ok = ok and f >= 36
	TestWorld.rec(out, "TC-029 todo ataque e precedido de aviso de >= 0,6 s (>= 36 quadros)", ok, "(minimos=%s)" % str(min_tele_frames))


func _triad(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel06 = _arena(tree)
	await tree.physics_frame
	level.boss.phase = VyrkanBoss.Phase.FINISH
	var heard := {"n": 0}
	level.boss.defeated.connect(func() -> void: heard["n"] += 1)
	for n in level.triad.nodes:
		level.triad.press(n)
	TestWorld.rec(out, "TC-029 Triade: o mesmo heroi apertando os tres pontos NAO conclui (so o primeiro conta)",
			level.triad.used_heroes.size() == 1 and heard["n"] == 0 and not level.boss.is_defeated())
	level.rig.request_swap(1)
	level.triad.press(level.triad.nodes[2])
	TestWorld.rec(out, "TC-029 Triade: segundo heroi em outro ponto ainda nao conclui", level.triad.used_heroes.size() == 2 and heard["n"] == 0)
	level.rig.request_swap(2)
	level.triad.press(level.triad.nodes[1])
	TestWorld.rec(out, "TC-029 Triade: tres herois diferentes (ordem livre: Rocco, Zuri, Pipa) derrotam o chefe uma vez",
			heard["n"] == 1 and level.boss.is_defeated())
	level.queue_free()


func _seed_ledger(out: Array) -> void:
	var save: Dictionary = SaveData.new_game()
	var planet: PlanetDefinition = GalaxyState.planets()[0]
	var ledger := ProgressLedger.new()
	var first: Dictionary = ledger.commit_seed(save, planet, "relic_sylvara", "astralis_memory_sylvara")
	TestWorld.rec(out, "TC-027 semente: a primeira transacao e first_time e grava semente, guardiao, reliquia e memoria",
			first["first_time"] and "seed_sylvara" in save["world"]["seed_destroyed_ids"] and "vyrkan" in save["world"]["boss_freed_ids"]
			and "relic_sylvara" in save["economy"]["owned_items"] and "astralis_memory_sylvara" in save["story"]["memories"])
	var second: Dictionary = ledger.commit_seed(save, planet, "relic_sylvara", "astralis_memory_sylvara")
	TestWorld.rec(out, "TC-027 semente: repetir NAO e first_time (Caeldron reage 1x) e nao duplica nada",
			not second["first_time"] and save["world"]["seed_destroyed_ids"].size() == 1 and save["economy"]["owned_items"].count("relic_sylvara") == 1
			and save["economy"]["claimed_transaction_ids"].count("seed:sylvara") == 1)


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
	TestWorld.rec(out, "TC-028 mapa apos a vitoria REAL: Sylvara Salvo, raiz removida, Cristalia Disponivel mas ainda em producao",
			GalaxyState.status(profile, 0) == GalaxyState.Status.SAVED and not GalaxyState.root_visible(profile, 0)
			and GalaxyState.status(profile, 1) == GalaxyState.Status.AVAILABLE and not GalaxyState.can_travel(profile, 1))
	tree.paused = false
	flow.queue_free()
	await tree.process_frame


func _camera(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel06 = _arena(tree)
	await tree.physics_frame
	await tree.physics_frame
	var cam: Camera3D = level.camera
	cam.make_current()
	await tree.physics_frame
	var points: Array[Vector3] = [Vector3(15.0, 3.5, -2.4), Vector3(-2.0, 0.0, 0.0), Vector3(32.0, 0.0, 0.0), Vector3(4.0, 0.9, 0.0), Vector3(33.5, 5.8, 0.0)]
	var inside: int = 0
	for p in points:
		if cam.is_position_in_frustum(p):
			inside += 1
	TestWorld.rec(out, "camera de arena: enquadra o ponto vulneravel, as bordas do campo e as plataformas altas (is_position_in_frustum)",
			inside == points.size(), "(%d de %d)" % [inside, points.size()])
	TestWorld.rec(out, "camera de arena: fixa (nao segue o heroi)", level.camera.target == null and is_equal_approx(cam.global_position.x, 15.0))
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel06 = _arena(tree)
	await tree.physics_frame
	var bot := LevelBot06.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: derrota Vyrkan (3 etapas + Golpe Triade com 3 herois) e abre o bau sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f fase=%d heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.boss.phase, level.rig.body.profile.hero_id])
	if finished:
		TestWorld.rec(out, "bot: semente destruida, reliquia no perfil, 6 moedas e nenhuma vida perdida",
				"seed_sylvara" in level.save["world"]["seed_destroyed_ids"] and "relic_sylvara" in level.save["economy"]["owned_items"]
				and c.session.coin_ids.size() == 6 and c.session.lives_lost == 0,
				"(moedas=%d vidas perdidas=%d)" % [c.session.coin_ids.size(), c.session.lives_lost])
	level.queue_free()
