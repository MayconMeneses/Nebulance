extends RefCounted
## Fluxo: menu, nova aventura/continuar, introducao pulavel, conclusao com save, pausa, save invalido.

const S := SaveService.Status


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _menu(tree, out)
	await _full_cycle(tree, out)
	await _intro(tree, out)
	await _pause(tree, out)
	await _bad_saves(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _flow(tree: SceneTree, case_name: String, intro: bool = false) -> GameFlow:
	var flow := GameFlow.new()
	flow.save_path = TmpDir.fresh(case_name) + "/slot1.json"
	flow.settings_path = TmpDir.fresh(case_name + "_cfg") + "/settings.json"
	flow.play_intro = intro
	tree.get_root().add_child(flow)
	return flow


func _finish(tree: SceneTree, flow: GameFlow) -> void:
	tree.paused = false
	flow.queue_free()
	await tree.process_frame


func _tp(flow: GameFlow, tree: SceneTree, pos: Vector3, frames: int = 3) -> void:
	flow.level.rig.body.global_position = pos
	flow.level.rig.body.velocity = Vector3.ZERO
	for i in frames:
		await tree.physics_frame


func _menu(tree: SceneTree, out: Array) -> void:
	var flow: GameFlow = _flow(tree, "menu")
	await tree.process_frame
	var m: MainMenu = flow.menu
	TestWorld.rec(out, "TC-002 menu: abre no estado MAIN_MENU", flow.state == GameFlow.State.MAIN_MENU and m != null)
	TestWorld.rec(out, "TC-002 menu: sem save, Continuar fica desativado", m._continue.disabled)
	var disabled: int = 0
	for b in m.find_children("*", "Button", true, false):
		if (b as Button).disabled:
			disabled += 1
	TestWorld.rec(out, "menu: Continuar (sem save) e Galeria aparecem desativados (nao fingem funcionar)", disabled == 2, "(desativados=%d)" % disabled)
	TestWorld.rec(out, "TC-002 menu: foco inicial no primeiro item ativo (Nova Aventura)", m._new_game.has_focus())
	var ev := InputEventAction.new()
	ev.action = &"ui_down"
	ev.pressed = true
	Input.parse_input_event(ev)
	await tree.process_frame
	await tree.process_frame
	var focus: Control = m.get_viewport().gui_get_focus_owner()
	TestWorld.rec(out, "TC-002 menu: seta para baixo move o foco pulando itens desativados",
			focus is Button and (focus as Button).text == "Configuracoes", "(foco=%s)" % (focus as Button).text if focus is Button else "(nenhum)")
	await _finish(tree, flow)


func _full_cycle(tree: SceneTree, out: Array) -> void:
	var flow: GameFlow = _flow(tree, "cycle")
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	TestWorld.rec(out, "fluxo: Nova Aventura cria o save e abre a fase", flow.state == GameFlow.State.LEVEL
			and FileAccess.file_exists(flow.service.path) and flow.level != null)
	TestWorld.rec(out, "fluxo: HUD e musica ativos", flow.hud != null and flow.audio.is_music_playing())
	var input := ScriptedInput.new()
	flow.level.rig.body.intent_provider = input.read
	await _tp(flow, tree, Vector3(4, 1, 0))
	await _tp(flow, tree, Vector3(102, 0.6, 0))
	input.press_interact()
	await tree.physics_frame
	await tree.process_frame
	TestWorld.rec(out, "TC-015 fluxo: abrir o bau mostra a tela de resultado", flow.state == GameFlow.State.RESULTS and flow.results != null)
	TestWorld.rec(out, "fluxo: conclusao grava o save (sem erro)", flow.last_save_error == OK)
	var saved: Dictionary = SaveService.new(flow.service.path).load_save()
	TestWorld.rec(out, "TC-020 fluxo: save em disco tem 81 moedas e Bronze",
			saved["data"]["economy"]["coin_balance"] == 81 and saved["data"]["economy"]["best_grade_by_level"]["sylvara_01"] == 1)
	TestWorld.rec(out, "TC-020 DOIS PROCESSOS: um segundo processo reabre o save e le 81 moedas", _second_process(flow.service.path, 81))
	flow.results.continue_pressed.emit()
	await tree.process_frame
	await tree.process_frame
	TestWorld.rec(out, "fluxo: depois dos resultados volta ao Mapa Galactico", flow.state == GameFlow.State.MAP and flow.map != null)
	flow.map.back_pressed.emit()
	await tree.process_frame
	await tree.process_frame
	TestWorld.rec(out, "fluxo: Voltar do mapa leva ao menu com Continuar ativo", flow.state == GameFlow.State.MAIN_MENU and not flow.menu._continue.disabled)
	flow.continue_game(true)
	await tree.process_frame
	TestWorld.rec(out, "TC-020 fluxo: continuar recupera as moedas do perfil", flow.profile["economy"]["coin_balance"] == 81)
	var input2 := ScriptedInput.new()
	flow.level.rig.body.intent_provider = input2.read
	await _tp(flow, tree, Vector3(4, 1, 0))
	await _tp(flow, tree, Vector3(102, 0.6, 0))
	input2.press_interact()
	await tree.physics_frame
	await tree.process_frame
	TestWorld.rec(out, "TC-016 fluxo: repetir a fase com o mesmo resultado nao duplica o saldo", flow.profile["economy"]["coin_balance"] == 81)
	flow.results.continue_pressed.emit()
	await tree.process_frame
	await tree.process_frame
	flow.map.back_pressed.emit()
	await tree.process_frame
	await tree.process_frame
	flow.menu.new_game_pressed.emit()
	await tree.process_frame
	flow.map.travel_requested.emit(&"sylvara")
	await tree.process_frame
	var archived: bool = FileAccess.file_exists(flow.service.path + ".old-1")
	var old: Dictionary = SaveService.new(flow.service.path + ".old-1").load_save()
	TestWorld.rec(out, "fluxo: Nova Aventura guarda o save anterior (nao apaga em silencio)",
			archived and old["data"]["economy"]["coin_balance"] == 81 and flow.profile["economy"]["coin_balance"] == 0)
	await _finish(tree, flow)


func _second_process(save_path: String, expected_balance: int) -> bool:
	var lines: Array = []
	var absolute: String = ProjectSettings.globalize_path(save_path)
	var code: int = OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"),
			"--script", "res://tests/support/reopen_probe.gd", "--", absolute], lines, true)
	var text: String = "".join(lines)
	return code == 0 and ("balance=%d" % expected_balance) in text and "status=0" in text


func _intro(tree: SceneTree, out: Array) -> void:
	var flow: GameFlow = _flow(tree, "intro", true)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	await tree.physics_frame
	var body: ActorController = flow.level.rig.body
	TestWorld.rec(out, "TC-025 introducao: o heroi fica travado (CUTSCENE) durante a chegada",
			body.state == MovementState.State.CUTSCENE and flow.intro != null)
	flow.intro.skip()
	await tree.physics_frame
	await tree.physics_frame
	await tree.physics_frame
	TestWorld.rec(out, "TC-025 introducao: pular libera o controle", body.state != MovementState.State.CUTSCENE)
	TestWorld.rec(out, "TC-025 introducao: pular nao concede nada nem altera o save",
			flow.profile["economy"]["coin_balance"] == 0 and flow.level.controller.session.coin_ids.is_empty())
	await _finish(tree, flow)


func _pause(tree: SceneTree, out: Array) -> void:
	var flow: GameFlow = _flow(tree, "pause")
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	var input := ScriptedInput.new()
	flow.level.rig.body.intent_provider = input.read
	await tree.physics_frame
	await tree.physics_frame
	input.move_axis = 1.0
	flow.toggle_pause()
	await tree.process_frame
	var x0: float = flow.level.rig.body.global_position.x
	for i in 30:
		await tree.process_frame
	TestWorld.rec(out, "pausa: a pausa bloqueia o movimento do jogo", flow.is_paused() and absf(flow.level.rig.body.global_position.x - x0) < 0.001)
	flow.toggle_pause()
	for i in 30:
		await tree.physics_frame
	TestWorld.rec(out, "pausa: ao retomar o jogo volta a se mover", not flow.is_paused() and flow.level.rig.body.global_position.x > x0 + 1.0)
	await _finish(tree, flow)


func _bad_saves(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("corrupt")
	TmpDir.write(dir + "/slot1.json", "{ nao e json")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	TestWorld.rec(out, "TC-021 fluxo: save invalido -> menu avisa e Continuar desativado",
			flow.menu._continue.disabled and flow.menu._message.text != "")
	flow.start_new_game(true)
	await tree.process_frame
	TestWorld.rec(out, "TC-021 fluxo: Nova Aventura preserva o save invalido (.old-1) em vez de apagar",
			TmpDir.read(dir + "/slot1.json.old-1") == "{ nao e json")
	await _finish(tree, flow)

	var fdir: String = TmpDir.fresh("future")
	var fut: Dictionary = SaveData.new_game()
	fut["schema_version"] = 9
	TmpDir.write(fdir + "/slot1.json", JSON.stringify(fut))
	var raw: String = TmpDir.read(fdir + "/slot1.json")
	var f2 := GameFlow.new()
	f2.save_path = fdir + "/slot1.json"
	f2.play_intro = false
	tree.get_root().add_child(f2)
	await tree.process_frame
	TestWorld.rec(out, "save de versao futura: Nova Aventura fica desativada e o arquivo intacto",
			f2.menu._new_game.disabled and TmpDir.read(fdir + "/slot1.json") == raw)
	await _finish(tree, f2)
