class_name AdaptiveQuality
extends Node
## Qualidade automatica: se o jogo ficar LENTO por um tempo seguido (media abaixo de 85% da taxa alvo em duas janelas de 150 quadros),
## desce UM perfil grafico (Alto -> Medio -> Baixo) sem mexer no que o jogador escolheu salvo. Nunca sobe sozinho e nunca grava nada:
## se o jogador trocar o perfil nas configuracoes, a contagem recomeca. Ignora pausa, carregamentos (quadro > 0,25 s) e a opcao desligada.

signal stepped_down(profile_id: String)

const WINDOW_FRAMES: int = 150
const FPS_RATIO: float = 0.85
const BAD_WINDOWS: int = 2
const MAX_FRAME: float = 0.25

## Referencia a SettingsStore.data (so leitura; as chaves usadas: graphics_profile e auto_quality).
var settings: Dictionary = {}
var current: String = ""
var steps: int = 0

var _requested: String = ""
var _frames: int = 0
var _sum: float = 0.0
var _bad: int = 0


## Taxa alvo: o limite de FPS escolhido ou a do monitor, no maximo 60.
static func target_fps() -> float:
	var cap: float = float(Engine.max_fps)
	var display: float = DisplayServer.screen_get_refresh_rate()
	var target: float = cap if cap > 0.0 else (display if display > 0.0 else 60.0)
	return minf(target, 60.0)


func _process(delta: float) -> void:
	if get_tree().paused or delta > MAX_FRAME:
		return
	feed(delta, target_fps())


## Conta um quadro (separado de `_process` para testar sem esperar o tempo real).
func feed(delta: float, target: float) -> void:
	if settings.is_empty() or not bool(settings.get("auto_quality", true)):
		return
	var requested: String = String(settings["graphics_profile"])
	if requested != _requested:
		_requested = requested
		current = requested
		steps = 0
		_frames = 0
		_sum = 0.0
		_bad = 0
	_frames += 1
	_sum += delta
	if _frames < WINDOW_FRAMES:
		return
	var fps: float = float(_frames) / _sum
	_frames = 0
	_sum = 0.0
	_bad = _bad + 1 if fps < target * FPS_RATIO else 0
	if _bad >= BAD_WINDOWS:
		_bad = 0
		_step_down()


func _step_down() -> void:
	var index: int = GraphicsProfile.IDS.find(current)
	if index <= 0:
		return
	current = GraphicsProfile.IDS[index - 1]
	steps += 1
	var applied: Dictionary = settings.duplicate()
	applied["graphics_profile"] = current
	GraphicsApplier.apply(get_viewport(), applied, get_tree())
	stepped_down.emit(current)
