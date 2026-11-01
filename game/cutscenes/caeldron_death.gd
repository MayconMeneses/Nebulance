class_name CaeldronDeath
extends CanvasLayer
## Morte definitiva de Caeldron (sexta semente destruida). Sequencia CURTA em texto (PROVISORIA, sem arte nem animacao), sem batalha extra.
## Pulavel (E, Espaco ou toque) depois de uma pequena guarda inicial; pular nao altera nada. Quem decide se toca (uma unica vez) e o
## ProgressLedger.claim_campaign_end; este no so apresenta.

signal finished

const BEAT_TIME: float = 3.0
## Evita que o mesmo toque que pulou a reacao anterior pule esta no mesmo instante.
const INPUT_GUARD: float = 0.5
const BEATS: Array[String] = [
	"CAELDRON\nA sexta raiz, a do coracao, se rompe.",
	"As seis conexoes se apagam. A arvore cosmica se desfaz em luz.",
	"Os seis mundos respiram de novo. Os guardioes voltam a sua forma natural.",
	"ASTRALIS\nOs seis simbolos do compartimento selado se acendem. A mensagem final antiga se abre.",
]

var _elapsed: float = 0.0
var _label: Label
var _done: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_label = Label.new()
	_label.add_theme_font_size_override(&"font_size", 28)
	_label.position = Vector2(220.0, 240.0)
	_label.custom_minimum_size = Vector2(840.0, 0.0)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_label)
	_show_beat()


func total_time() -> float:
	return BEAT_TIME * BEATS.size()


func is_done() -> bool:
	return _done


func current_beat() -> int:
	return mini(int(_elapsed / BEAT_TIME), BEATS.size() - 1)


func skip() -> void:
	if not _done:
		_done = true
		finished.emit()
		queue_free()


func _show_beat() -> void:
	_label.text = BEATS[current_beat()] + "\n\n(E ou Espaco para pular)"


func _process(delta: float) -> void:
	if _done:
		return
	_elapsed += delta
	_show_beat()
	var pressed: bool = Input.is_action_just_pressed(&"interact") or Input.is_action_just_pressed(&"jump")
	if _elapsed >= total_time() or (pressed and _elapsed >= INPUT_GUARD):
		skip()
