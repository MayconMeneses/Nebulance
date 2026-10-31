class_name ResultsScreen
extends CanvasLayer
## Tela de resultado da fase (classificacao, moedas e itens). Nao concede nada: so apresenta o recibo.

signal continue_pressed

const GRADE_NAMES: Array[String] = ["-", "Bronze", "Prata", "Ouro"]

var _body: Label
var _button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var panel := PanelContainer.new()
	panel.position = Vector2(380.0, 160.0)
	panel.custom_minimum_size = Vector2(520.0, 360.0)
	add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	var title := Label.new()
	title.text = "FASE CONCLUIDA"
	title.add_theme_font_size_override(&"font_size", 32)
	box.add_child(title)
	_body = Label.new()
	_body.add_theme_font_size_override(&"font_size", 22)
	box.add_child(_body)
	_button = Button.new()
	_button.text = "Continuar"
	_button.pressed.connect(func() -> void: continue_pressed.emit())
	box.add_child(_button)


func show_receipt(level_name: String, receipt: Dictionary, balance: int, save_ok: bool) -> void:
	var lines: PackedStringArray = [level_name, "",
			"Classificacao: %s" % GRADE_NAMES[receipt["grade"]],
			"Moedas coletadas: +%d" % receipt["pickup_coins"],
			"Bau: +%d%s" % [receipt["chest_coins"], " (melhoria)" if receipt["upgraded"] else ""],
			"Saldo: %d moedas" % balance]
	for item in receipt["new_items"]:
		lines.append("Novo item: %s" % item)
	for memory in receipt["new_memories"]:
		lines.append("Novo registro de arquivo: %s" % memory)
	if not save_ok:
		lines.append("ATENCAO: nao foi possivel salvar o progresso.")
	_body.text = "\n".join(lines)
	_button.grab_focus()
