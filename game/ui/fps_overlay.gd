class_name FpsOverlay
extends CanvasLayer
## Medidor de quadros (F3 liga/desliga): FPS, tempo medio e o PIOR quadro dos ultimos 2 s, para medir o jogo de verdade no seu computador.
## So leitura: nao altera nada. Escondido por padrao.

const KEY: Key = KEY_F3
const HISTORY: int = 120

var _label: Label
var _times: Array[float] = []


func _ready() -> void:
	layer = 99
	process_mode = Node.PROCESS_MODE_ALWAYS
	_label = Label.new()
	_label.position = Vector2(1020.0, 8.0)
	_label.add_theme_font_size_override(&"font_size", 16)
	_label.add_theme_color_override(&"font_color", Color(0.6, 1.0, 0.85))
	_label.add_theme_color_override(&"font_outline_color", Color.BLACK)
	_label.add_theme_constant_override(&"outline_size", 4)
	_label.visible = false
	add_child(_label)


func toggle() -> void:
	_label.visible = not _label.visible


func is_shown() -> bool:
	return _label != null and _label.visible


## Resumo dos ultimos quadros: {"fps", "avg_ms", "worst_ms"}.
func stats() -> Dictionary:
	if _times.is_empty():
		return {"fps": 0.0, "avg_ms": 0.0, "worst_ms": 0.0}
	var sum: float = 0.0
	var worst: float = 0.0
	for t in _times:
		sum += t
		worst = maxf(worst, t)
	var avg: float = sum / _times.size()
	return {"fps": 1000.0 / avg, "avg_ms": avg, "worst_ms": worst}


func _process(delta: float) -> void:
	_times.append(delta * 1000.0)
	if _times.size() > HISTORY:
		_times.pop_front()
	if _label.visible:
		var s: Dictionary = stats()
		_label.text = "%.0f FPS  |  %.1f ms  |  pior %.1f ms" % [s["fps"], s["avg_ms"], s["worst_ms"]]


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY:
		toggle()
