class_name MainMenu
extends CanvasLayer
## Menu principal navegavel por foco (teclado e gamepad). Itens ainda inexistentes aparecem DESATIVADOS.

signal continue_pressed
signal new_game_pressed
signal settings_pressed
signal quit_pressed

var _continue: Button
var _new_game: Button
var _message: Label
var _has_save: bool = false
var _confirming: bool = false
var _update_box: VBoxContainer
var _update_url: String = ""


func _ready() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(480.0, 180.0)
	box.custom_minimum_size = Vector2(320.0, 0.0)
	add_child(box)
	var title := Label.new()
	title.text = "NEBULANCE\nAs Sementes do Colapso"
	title.add_theme_font_size_override(&"font_size", 34)
	box.add_child(title)
	_continue = _button(box, "Continuar", func() -> void: continue_pressed.emit())
	_new_game = _button(box, "Nova Aventura", _on_new_game)
	_button(box, "Galeria (em breve)", func() -> void: pass).disabled = true
	_button(box, "Configuracoes", func() -> void: settings_pressed.emit())
	_button(box, "Sair", func() -> void: quit_pressed.emit())
	_message = Label.new()
	box.add_child(_message)
	refresh(false, "")


func refresh(has_save: bool, message: String, allow_new_game: bool = true) -> void:
	_has_save = has_save
	_confirming = false
	_continue.disabled = not has_save
	_new_game.disabled = not allow_new_game
	_new_game.text = "Nova Aventura"
	_message.text = message
	_update_focus_modes()
	(_continue if has_save else _new_game).grab_focus()


## Itens desativados nao recebem foco (a navegacao pula direto para o proximo item ativo).
## Faixa de aviso de nova versao. "Baixar" abre a pagina da versao no navegador (nada e baixado pelo jogo); "Depois" dispensa.
func show_update(version: String, url: String) -> void:
	if not url.begins_with(UpdateChecker.TRUSTED_PREFIX):
		return
	_update_url = url
	if _update_box != null:
		_update_box.queue_free()
	_update_box = VBoxContainer.new()
	_update_box.position = Vector2(400.0, 40.0)
	add_child(_update_box)
	var label := Label.new()
	label.text = "Nova versao disponivel: %s (voce tem %s)" % [version, GameVersion.CURRENT]
	_update_box.add_child(label)
	var row := HBoxContainer.new()
	_update_box.add_child(row)
	_button(row, "Baixar atualizacao", open_update_page)
	_button(row, "Depois", func() -> void: _update_box.queue_free())
	_update_focus_modes()


func open_update_page() -> void:
	if _update_url.begins_with(UpdateChecker.TRUSTED_PREFIX):
		OS.shell_open(_update_url)


func _update_focus_modes() -> void:
	for b in find_children("*", "Button", true, false):
		(b as Button).focus_mode = Control.FOCUS_NONE if (b as Button).disabled else Control.FOCUS_ALL


func _on_new_game() -> void:
	if _has_save and not _confirming:
		_confirming = true
		_new_game.text = "Confirmar? (guarda o save atual)"
		return
	new_game_pressed.emit()


func _button(parent: Control, label: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = label
	b.pressed.connect(callback)
	parent.add_child(b)
	return b
