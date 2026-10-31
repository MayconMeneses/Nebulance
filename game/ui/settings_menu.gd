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


func setup(store: SettingsStore) -> void:
	_store = store


func _ready() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(440.0, 180.0)
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
