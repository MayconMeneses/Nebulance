class_name SettingsMenu
extends CanvasLayer
## Tela de configuracoes graficas: perfil, limite de FPS e vsync. Salva ao alterar.

signal back_pressed
signal changed(settings: Dictionary)

var _store: SettingsStore
var _profile: OptionButton
var _fps: OptionButton
var _vsync: CheckBox
var _auto: CheckBox
var _back: Button
var _key_buttons: Dictionary = {}
var _message: Label
var _motion: CheckBox
var _flashing: CheckBox
var _updates: CheckBox
var _touch_mode: OptionButton
var _touch_size: OptionButton
var _touch_opacity: OptionButton
var _touch_mirror: CheckBox
var _capturing: StringName = &""


func setup(store: SettingsStore) -> void:
	_store = store


func _ready() -> void:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(400.0, 0.0)
	var scroll := ScrollContainer.new()
	scroll.size = Vector2(1280.0, 720.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override(&"margin_left", 440)
	pad.add_theme_constant_override(&"margin_top", 16)
	pad.add_child(box)
	scroll.add_child(pad)
	var title := Label.new()
	title.text = "CONFIGURACOES GRAFICAS"
	title.add_theme_font_size_override(&"font_size", 30)
	box.add_child(title)
	_profile = _option(box, "Perfil", PackedStringArray(["Baixo", "Medio", "Alto"]))
	_fps = _option(box, "Limite de FPS", PackedStringArray(["Sem limite", "30", "60", "120"]))
	_vsync = CheckBox.new()
	_vsync.text = "Sincronia vertical (vsync)"
	box.add_child(_vsync)
	_auto = _flag(box, "Qualidade automatica (reduz os efeitos se o jogo ficar lento; F3 mostra o FPS)", "auto_quality")
	_motion = _flag(box, "Reduzir movimento (menos particulas, sem pulsos)", "reduce_motion")
	_flashing = _flag(box, "Reduzir flashes (sem cores alternando)", "reduce_flashing")
	_updates = _flag(box, "Avisar de atualizacoes ao abrir (usa a internet)", "check_updates")
	var touch_title := Label.new()
	touch_title.text = "CONTROLES DE TOQUE"
	touch_title.add_theme_font_size_override(&"font_size", 22)
	box.add_child(touch_title)
	_touch_mode = _touch_option(box, "Mostrar", PackedStringArray(["Automatico", "Sempre", "Nunca"]), "touch_mode", TouchLayout.MODES)
	_touch_size = _touch_option(box, "Tamanho", PackedStringArray(["Pequeno", "Medio", "Grande"]), "touch_size", [0, 1, 2])
	_touch_opacity = _touch_option(box, "Opacidade", PackedStringArray(["Baixa", "Media", "Alta"]), "touch_opacity", [0, 1, 2])
	_touch_mirror = _flag(box, "Inverter lados (modo canhoto)", "touch_mirror")
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


func _touch_option(parent: Control, label: String, items: PackedStringArray, key: String, values: Array) -> OptionButton:
	var ob: OptionButton = _option(parent, label, items)
	ob.select(maxi(values.find(_store.data[key]), 0))
	ob.item_selected.connect(func(i: int) -> void: _commit(key, values[i]))
	return ob
