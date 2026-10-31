class_name ArrivalIntro
extends CanvasLayer
## Chegada curta da Astralis (PLACEHOLDER: texto e fade). Pulavel; pular nao altera progresso nem recompensas.

signal finished

@export var duration: float = 4.0

var _elapsed: float = 0.0
var _done: bool = false


func _ready() -> void:
	var fade := ColorRect.new()
	fade.color = Color(0.02, 0.06, 0.1, 0.85)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fade)
	var label := Label.new()
	label.text = "SYLVARA\nA Astralis pousa. O trio desembarca.\n\n(E ou Espaco para pular)"
	label.add_theme_font_size_override(&"font_size", 30)
	label.position = Vector2(360.0, 240.0)
	add_child(label)


func skip() -> void:
	if not _done:
		_done = true
		finished.emit()
		queue_free()


func _process(delta: float) -> void:
	_elapsed += delta
	if Input.is_action_just_pressed(&"interact") or Input.is_action_just_pressed(&"jump") or _elapsed >= duration:
		skip()
