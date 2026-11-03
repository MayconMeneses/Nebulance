class_name GuardianLiberation
extends CanvasLayer
## Cutscene de libertacao do guardiao: ao destruir a semente pela PRIMEIRA vez, o guardiao se liberta da corrupcao (um brilho se abre sobre
## a tela e as palavras aparecem em sequencia). Sobrepoe-se a reacao de Caeldron, mas nao a bloqueia; pulavel (E, Espaco ou toque); nao
## altera o save (a libertacao ja foi gravada pela transacao da semente).

signal finished

const DURATION: float = 4.5
const SKIP_ACTIONS: Array[StringName] = [&"interact", &"jump"]

var guardian_name: String = "O guardiao"
var planet_name: String = "o planeta"

var _elapsed: float = 0.0
var _done: bool = false
var _glow: GuardianGlow
var _label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 12
	_glow = GuardianGlow.new()
	_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_glow)
	_label = Label.new()
	_label.add_theme_font_size_override(&"font_size", 26)
	_label.position = Vector2(300.0, 470.0)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
	_update_text()


## Linhas da cutscene por instante (segundos): a ultima inclui a dica de pular.
func lines_at(seconds: float) -> String:
	if seconds < 1.2:
		return "A corrupcao se desfaz..."
	if seconds < 2.8:
		return "%s esta livre." % guardian_name
	return "%s volta a respirar. (E ou Espaco para pular)" % planet_name.capitalize()


func skip() -> void:
	if not _done:
		_done = true
		finished.emit()
		queue_free()


func _process(delta: float) -> void:
	_elapsed += delta
	_glow.progress = clampf(_elapsed / DURATION, 0.0, 1.0)
	_glow.queue_redraw()
	_update_text()
	for action in SKIP_ACTIONS:
		if Input.is_action_just_pressed(action):
			skip()
			return
	if _elapsed >= DURATION:
		skip()


func _update_text() -> void:
	if _label != null:
		_label.text = lines_at(_elapsed)


## Brilho que cresce do centro (um disco translucido sobre um veu escuro suave). So desenho; sem fisica nem entrada.
class GuardianGlow extends Control:
	var progress: float = 0.0

	func _draw() -> void:
		var size_px: Vector2 = get_viewport_rect().size
		var veil: float = sin(progress * PI) * 0.45
		draw_rect(Rect2(Vector2.ZERO, size_px), Color(0.0, 0.0, 0.05, veil))
		var radius: float = lerpf(20.0, size_px.y * 0.45, progress)
		draw_circle(size_px * 0.5 + Vector2(0.0, -40.0), radius, Color(0.55, 0.95, 0.85, 0.35 * (1.0 - progress * 0.6)))
