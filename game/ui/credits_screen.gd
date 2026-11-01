class_name CreditsScreen
extends CanvasLayer
## Tela de fim/creditos SIMPLES e pulavel (PROVISORIA: texto estatico, sem rolagem nem musica propria). Pode ser revista a partir do Mapa
## Galactico depois da campanha. Pular (E, Espaco ou Esc) so fecha a tela; nao altera o save.

signal finished

const DURATION: float = 12.0
const INPUT_GUARD: float = 0.5
const LINES: Array[String] = [
	"NEBULANCE - AS SEMENTES DO COLAPSO",
	"",
	"Rocco, Zuri e Pipa salvaram os seis mundos.",
	"Sylvara · Cristalia · Mecatron · Aquarys · Aerion · Umbraxis",
	"Caeldron foi destruido definitivamente.",
	"",
	"Os planetas salvos continuam visitaveis.",
	"",
	"(Creditos provisorios: a lista completa sera preenchida na versao final)",
	"",
	"E ou Espaco para continuar",
]

var _elapsed: float = 0.0
var _done: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 50
	var label := Label.new()
	label.text = "\n".join(LINES)
	label.add_theme_font_size_override(&"font_size", 26)
	label.position = Vector2(240.0, 140.0)
	add_child(label)


func is_done() -> bool:
	return _done


func skip() -> void:
	if not _done:
		_done = true
		finished.emit()
		queue_free()


func _process(delta: float) -> void:
	if _done:
		return
	_elapsed += delta
	var pressed: bool = Input.is_action_just_pressed(&"interact") or Input.is_action_just_pressed(&"jump") or Input.is_action_just_pressed(&"pause")
	if _elapsed >= DURATION or (pressed and _elapsed >= INPUT_GUARD):
		skip()
