extends RefCounted
## Remapeamento de teclado (TC-023): conflito, persistencia, saneamento, gamepad preservado e captura na tela.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	InputMap.load_from_project_settings()
	_sanitize(out)
	_rebind(out)
	await _real_input(tree, out)
	_persistence(out)
	await _menu(tree, out)
	InputMap.load_from_project_settings()
	TmpDir.remove(TmpDir.ROOT)
	return out


func _has_joypad(action: StringName) -> bool:
	for e in InputMap.action_get_events(action):
		if e is InputEventJoypadButton or e is InputEventJoypadMotion:
			return true
	return false


func _sanitize(out: Array) -> void:
	var clean: Dictionary = KeyBindings.sanitize({"jump": KEY_J, "special": KEY_K, "naoexiste": KEY_L, "interact": "x", "pause": -5, "swap_next": KEY_J})
	TestWorld.rec(out, "TC-023 saneamento: mantem so acao conhecida, tipo certo e tecla valida", clean.get("jump") == KEY_J and clean.get("special") == KEY_K
			and not clean.has("naoexiste") and not clean.has("interact") and not clean.has("pause"))
	TestWorld.rec(out, "TC-023 saneamento: tecla repetida entre acoes e descartada", not clean.has("swap_next"))
	TestWorld.rec(out, "saneamento: entrada que nao e dicionario vira vazio", KeyBindings.sanitize("lixo").is_empty() and KeyBindings.sanitize(null).is_empty())


func _rebind(out: Array) -> void:
	var keys: Dictionary = {}
	TestWorld.rec(out, "TC-023 padrao: Pular e Espaco", KeyBindings.key_name(&"jump") == "Space")
	TestWorld.rec(out, "TC-023 remapear Pular para J aplica", KeyBindings.rebind(keys, &"jump", KEY_J).is_empty()
			and KeyBindings.key_name(&"jump") == "J" and keys["jump"] == KEY_J)
	TestWorld.rec(out, "TC-023 a tecla antiga (Espaco) deixa de acionar Pular", not _action_uses(&"jump", KEY_SPACE))
	TestWorld.rec(out, "TC-023 remapear preserva o gamepad da acao", _has_joypad(&"jump"))
	var before: Dictionary = keys.duplicate()
	var msg: String = KeyBindings.rebind(keys, &"special", KEY_J)
	TestWorld.rec(out, "TC-023 conflito: J ja e Pular -> recusa com mensagem e nada muda", not msg.is_empty() and msg.contains("Pular")
			and keys == before and KeyBindings.key_name(&"special") == "Shift")
	TestWorld.rec(out, "TC-023 conflito tambem vale para a tecla alternativa padrao (seta direita)", not KeyBindings.rebind(keys, &"jump", KEY_RIGHT).is_empty())
	TestWorld.rec(out, "TC-023 liberar tecla: depois de mover Pular, Espaco serve a outra acao", KeyBindings.rebind(keys, &"special", KEY_SPACE).is_empty())
	TestWorld.rec(out, "remapear: tecla invalida e recusada", not KeyBindings.rebind(keys, &"interact", 0).is_empty())
	TestWorld.rec(out, "remapear: remapear a mesma tecla da propria acao nao e conflito", KeyBindings.rebind(keys, &"jump", KEY_J).is_empty())
	InputMap.load_from_project_settings()


func _action_uses(action: StringName, keycode: int) -> bool:
	for e in InputMap.action_get_events(action):
		if e is InputEventKey and (e as InputEventKey).physical_keycode == keycode:
			return true
	return false


func _real_input(tree: SceneTree, out: Array) -> void:
	KeyBindings.apply({"jump": KEY_J})
	var down := InputEventKey.new()
	down.physical_keycode = KEY_J
	down.pressed = true
	Input.parse_input_event(down)
	await tree.process_frame
	var pressed_new: bool = Input.is_action_pressed(&"jump")
	var up := InputEventKey.new()
	up.physical_keycode = KEY_J
	up.pressed = false
	Input.parse_input_event(up)
	await tree.process_frame
	var old := InputEventKey.new()
	old.physical_keycode = KEY_SPACE
	old.pressed = true
	Input.parse_input_event(old)
	await tree.process_frame
	var pressed_old: bool = Input.is_action_pressed(&"jump")
	old.pressed = false
	Input.parse_input_event(old)
	await tree.process_frame
	TestWorld.rec(out, "TC-023 entrada real: a tecla nova aciona Pular e a antiga nao", pressed_new and not pressed_old)
	InputMap.load_from_project_settings()


func _persistence(out: Array) -> void:
	var dir: String = TmpDir.fresh("keys")
	var s := SettingsStore.new(dir + "/settings.json")
	s.load_settings()
	KeyBindings.rebind(s.data["keys"], &"interact", KEY_F)
	s.save_settings()
	InputMap.load_from_project_settings()
	var s2 := SettingsStore.new(dir + "/settings.json")
	s2.load_settings()
	KeyBindings.apply(s2.data["keys"])
	TestWorld.rec(out, "TC-023 persistencia: a tecla escolhida sobrevive a recarregar o arquivo e reaplicar", KeyBindings.key_name(&"interact") == "F")
	var f := FileAccess.open(dir + "/settings.json", FileAccess.WRITE)
	f.store_string('{"version":1,"graphics_profile":"low","keys":{"jump":"lixo","special":99999999,"swap_next":70,"swap_prev":70}}')
	f.close()
	var s3 := SettingsStore.new(dir + "/settings.json")
	s3.load_settings()
	TestWorld.rec(out, "persistencia: teclas corrompidas/duplicadas no arquivo sao saneadas e o resto das configuracoes permanece",
			s3.data["graphics_profile"] == "low" and not s3.data["keys"].has("jump") and not s3.data["keys"].has("special")
			and s3.data["keys"].get("swap_prev") == 70 and not s3.data["keys"].has("swap_next"))
	TestWorld.rec(out, "persistencia: configuracoes antigas sem 'keys' carregam com o padrao", SettingsStore.defaults()["keys"] == {})
	InputMap.load_from_project_settings()


func _menu(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("keysmenu")
	var store := SettingsStore.new(dir + "/settings.json")
	store.load_settings()
	var menu := SettingsMenu.new()
	menu.setup(store)
	tree.get_root().add_child(menu)
	await tree.process_frame
	menu._begin_capture(&"jump")
	TestWorld.rec(out, "menu: ao iniciar a captura o botao mostra '...'", (menu._key_buttons[&"jump"] as Button).text == "...")
	menu._input(_key_event(KEY_J))
	TestWorld.rec(out, "menu: capturar J remapeia, mostra no botao e grava no arquivo", KeyBindings.key_name(&"jump") == "J"
			and (menu._key_buttons[&"jump"] as Button).text == "J" and SettingsStore.new(dir + "/settings.json").load_settings())
	var saved := SettingsStore.new(dir + "/settings.json")
	saved.load_settings()
	TestWorld.rec(out, "menu: o arquivo guarda a tecla escolhida", saved.data["keys"].get("jump") == KEY_J)
	menu._begin_capture(&"special")
	menu._input(_key_event(KEY_J))
	TestWorld.rec(out, "menu: tecla em conflito mostra mensagem e mantem a tecla anterior", menu._message.text.contains("Pular")
			and KeyBindings.key_name(&"special") == "Shift")
	menu._begin_capture(&"special")
	menu._input(_key_event(KEY_ESCAPE))
	TestWorld.rec(out, "menu: Esc cancela a captura sem alterar nada", KeyBindings.key_name(&"special") == "Shift" and menu._message.text.is_empty())
	menu._input(_key_event(KEY_K))
	TestWorld.rec(out, "menu: tecla fora de uma captura e ignorada", KeyBindings.key_name(&"special") == "Shift")
	menu._reset_keys()
	TestWorld.rec(out, "menu: restaurar devolve Espaco e zera o arquivo", KeyBindings.key_name(&"jump") == "Space"
			and (menu._key_buttons[&"jump"] as Button).text == "Space" and store.data["keys"].is_empty())
	menu.queue_free()
	await tree.process_frame


func _key_event(code: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code as Key
	e.pressed = true
	return e
