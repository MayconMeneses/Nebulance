extends RefCounted
## Aquecimento de shaders: tela de carregamento, controle travado durante e liberado depois, sem vazar objetos temporarios.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	var dir: String = TmpDir.fresh("warmup")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	flow.warmup_frames = 12
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	var body: ActorController = flow.level.rig.body
	var visuals_before: int = flow.level.find_children("*", "HeroVisual", true, false).size()
	TestWorld.rec(out, "aquecimento: durante o carregamento o heroi fica travado (CUTSCENE)", body.state == MovementState.State.CUTSCENE
			and flow.find_children("*", "ShaderWarmup", false, false).size() == 1)
	TestWorld.rec(out, "aquecimento: instancia temporaria dos 3 herois alem do heroi ativo", visuals_before >= 4, "(visuais=%d)" % visuals_before)
	for i in 20:
		await tree.process_frame
	await tree.physics_frame
	await tree.physics_frame
	TestWorld.rec(out, "aquecimento: termina, a tela some e o controle volta", flow.find_children("*", "ShaderWarmup", false, false).is_empty()
			and body.state != MovementState.State.CUTSCENE)
	TestWorld.rec(out, "aquecimento: os objetos temporarios sao liberados (so resta o visual do heroi ativo)",
			flow.level.find_children("*", "HeroVisual", true, false).size() == 1)
	TestWorld.rec(out, "aquecimento: nao altera o estado de jogo (nenhuma moeda, vidas intactas)",
			flow.level.controller.session.coin_ids.is_empty() and flow.level.rig.vitals.lives == 5 and flow.profile["economy"]["coin_balance"] == 0)
	tree.paused = false
	flow.queue_free()
	await tree.process_frame
	TmpDir.remove(TmpDir.ROOT)
	return out
