class_name CaeldronReaction
extends CanvasLayer
## Reacao de Caeldron a destruicao de uma semente (PDF §02: Sylvara = "surpresa e primeira raiz rompida").
## Pulavel; so toca quando a transacao da semente e a PRIMEIRA vez. Pular nao altera nada.

signal finished

const DURATION: float = 3.5

@export var message: String = "CAELDRON\nSurpresa. A primeira raiz se rompe."

var _elapsed: float = 0.0
var _done: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var label := Label.new()
	label.text = message + "\n\n(E ou Espaco para pular)"
	label.add_theme_font_size_override(&"font_size", 28)
	label.position = Vector2(380.0, 160.0)
	add_child(label)


func skip() -> void:
	if not _done:
		_done = true
		finished.emit()
		queue_free()


func _process(delta: float) -> void:
	_elapsed += delta
	if Input.is_action_just_pressed(&"interact") or Input.is_action_just_pressed(&"jump") or _elapsed >= DURATION:
		skip()
