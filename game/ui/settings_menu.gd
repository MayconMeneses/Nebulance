class_name SettingsMenu
extends CanvasLayer
## Tela de configuracoes graficas: perfil, limite de FPS e vsync. Salva ao alterar.

signal back_pressed
signal changed(settings: Dictionary)

var _store: SettingsStore
var _profile: OptionButton
var _fps: OptionButton
var _vsync: CheckBox
var _back: Button
var _key_buttons: Dictionary = {}
var _message: Label
var _motion: CheckBox
var _flashing: CheckBox
var _capturing: StringName = &""


func setup(store: SettingsStore) -> void:
	_store = store


func _ready() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(440.0, 16.0)
	box.custom_minimum_size = Vector2(400.0, 0.0)
	add_child(box)
	var title := Label.new()
	title.text = "CONFIGURACOES GRAFICAS"
	title.add_theme_font_size_override(&"font_size", 30)
	box.add_child(title)
	_profile = _option(box, "Perfil", PackedStringArray(["Baixo", "Medio", "Alto"]))
	_fps = _option(box, "Limite de FPS", PackedStringArray(["Sem limite", "30", "60", "120"]))
	_vsync = CheckBox.new()
	_vsync.text = "Sincronia vertical (vsync)"
	box.add_child(_vsync)
	_motion = _flag(box, "Reduzir movimento (menos particulas, sem pulsos)", "reduce_motion")
	_flashing = _flag(box, "Reduzir flashes (sem cores alternando)", "reduce_flashing")
	var keys_title := Label.new()
	keys_title.text = "TECLAS"
	keys_title.add_theme_font_size_override(&"font_size", 22)
	box.add_child(keys_title)
	for action in KeyBindings.ACTIONS:
		_key_row(box, action)
	_message = Label.new()
	box.add_child(_message)
	var reset := Button.new()
	reset.text = "Restaurar teclas padrao"
	reset.pressed.connect(_reset_keys)
	box.add_child(reset)
	_back = Button.new()
	_back.text = "Voltar"
	_back.pressed.connect(func() -> void: back_pressed.emit())
	box.add_child(_back)
	_profile.select(GraphicsProfile.IDS.find(_store.data["graphics_profile"]))
	_fps.select(GraphicsProfile.FPS_OPTIONS.find(_store.data["max_fps"]))
	_vsync.button_pressed = _store.data["vsync"]
	_profile.item_selected.connect(func(i: int) -> void: _commit("graphics_profile", GraphicsProfile.IDS[i]))
	_fps.item_selected.connect(func(i: int) -> void: _commit("max_fps", GraphicsProfile.FPS_OPTIONS[i]))
	_vsync.toggled.connect(func(on: bool) -> void: _commit("vsync", on))
	_profile.grab_focus()


func _commit(key: String, value: Variant) -> void:
	_store.data[key] = value
	_store.save_settings()
	changed.emit(_store.data)


func _option(parent: Control, label: String, items: PackedStringArray) -> OptionButton:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(160.0, 0.0)
	row.add_child(l)
	var ob := OptionButton.new()
	for item in items:
		ob.add_item(item)
	row.add_child(ob)
	parent.add_child(row)
	return ob


func _key_row(parent: Control, action: StringName) -> void:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = KeyBindings.LABELS[action]
	l.custom_minimum_size = Vector2(240.0, 0.0)
	row.add_child(l)
	var b := Button.new()
	b.custom_minimum_size = Vector2(160.0, 0.0)
	b.text = KeyBindings.key_name(action)
	b.pressed.connect(func() -> void: _begin_capture(action))
	row.add_child(b)
	parent.add_child(row)
	_key_buttons[action] = b


func _begin_capture(action: StringName) -> void:
	_capturing = action
	_message.text = "Pressione a nova tecla (Esc cancela)."
	(_key_buttons[action] as Button).text = "..."


## Captura a proxima tecla fisica enquanto uma acao espera remapeamento; consome o evento para nao acionar o menu.
func _input(event: InputEvent) -> void:
	if _capturing == &"" or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	get_viewport().set_input_as_handled()
	var action: StringName = _capturing
	_capturing = &""
	var code: int = (event as InputEventKey).physical_keycode
	if code == KEY_ESCAPE:
		_message.text = ""
	else:
		var error: String = KeyBindings.rebind(_store.data["keys"], action, code)
		_message.text = error
		if error.is_empty():
			_store.save_settings()
			changed.emit(_store.data)
	_refresh_keys()


func _reset_keys() -> void:
	_store.data["keys"] = {}
	InputMap.load_from_project_settings()
	_store.save_settings()
	_message.text = "Teclas restauradas."
	_refresh_keys()


func _refresh_keys() -> void:
	for action in _key_buttons:
		(_key_buttons[action] as Button).text = KeyBindings.key_name(action)


func _flag(parent: Control, text: String, key: String) -> CheckBox:
	var c := CheckBox.new()
	c.text = text
	c.button_pressed = _store.data[key]
	c.toggled.connect(func(on: bool) -> void: _commit(key, on))
	parent.add_child(c)
	return c
