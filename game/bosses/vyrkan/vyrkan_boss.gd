class_name VyrkanBoss
extends Node3D
## Vyrkan, o Guardiao das Raizes (Sylvara). Maquina de estados deterministica em 3 fases de complexidade crescente:
## cada fase repete TELEGRAPH (>= 0,6 s) -> ACTIVE -> RECOVER sobre faixas fixas de raizes. A fase so avanca por um MECANISMO
## (Rocco: apoio marcado; Zuri: mecanismo alto; Pipa: mecanismo alto com vento); depois vem o Golpe Triade (ver TriadFinisher).
## O dano vem so das faixas ativas (eventos discretos), nunca de sobreposicao com o corpo do chefe.

signal phase_changed(phase: int)
signal defeated

enum Phase { ONE = 1, TWO = 2, THREE = 3, FINISH = 4, DEFEATED = 5 }

const LANE_X: Array[float] = [4.0, 9.0, 14.0, 19.0, 24.0]
## Faixas por padrao (cada fase tem 2 padroes que se alternam): mais faixas e janelas menores a cada fase.
const PATTERNS: Dictionary = {1: [[1, 3], [0, 2]], 2: [[0, 2, 4], [1, 3]], 3: [[0, 1, 3, 4], [0, 2, 4, 1]]}
## (aviso, ativo, recuperacao) em segundos por fase; todos os avisos >= 0,6 s.
const TIMING: Dictionary = {1: Vector3(1.0, 0.5, 1.2), 2: Vector3(0.85, 0.5, 1.0), 3: Vector3(0.7, 0.5, 0.9)}
const MIN_TELEGRAPH: float = 0.6
## Ataque de ASSINATURA: a partir da fase 2 as faixas `signature_lanes` usam o perfil proprio do chefe (altura/alcance do golpe).
## So as faixas 0 e 1: nenhuma plataforma alta das arenas cruza essas colunas, entao os refugios continuam validos.
const SIGNATURE_FROM_PHASE: int = 2

## Chave do mecanismo esperado em cada fase (outros chefes sobrescrevem).
var stage_keys: Dictionary = {1: &"rocco", 2: &"zuri", 3: &"pipa"}
var signature: StringName = &"bite"
var signature_lanes: Array[int] = [0, 1]
## Corpo 3D do guardiao (so aparencia; le o ciclo de ataques).
var avatar: BossAvatar
var phase: int = Phase.ONE
var lanes: Array[RootLane] = []
## Ligados pela fase de arena.
var save: Dictionary = {}
var seed_id: StringName = &""
var started: bool = true

var _pattern: int = 0
var _state: RootLane.State = RootLane.State.RECOVER
var _timer: float = 1.2
var _active_set: Array = []


func _ready() -> void:
	add_to_group(&"snapshotable")
	for i in LANE_X.size():
		var lane := RootLane.new()
		lane.lane_index = i
		lane.position = Vector3(LANE_X[i], 0.0, 0.0)
		add_child(lane)
		lanes.append(lane)
	_apply_profiles()
	avatar = BossAvatar.new()
	add_child(avatar)
	avatar.setup(signature, self)


func is_defeated() -> bool:
	return phase == Phase.DEFEATED


## Avanca a fase quando o mecanismo CERTO e ativado (ordem rocco -> zuri -> pipa); mecanismos fora de hora nao fazem nada.
func mechanism_done(which: StringName) -> bool:
	var expected: StringName = stage_keys.get(phase, &"")
	if which != expected:
		return false
	phase += 1
	_pattern = 0
	_apply_profiles()
	phase_changed.emit(phase)
	return true


func finish_triad() -> void:
	if phase == Phase.FINISH:
		_enter_defeated()
		defeated.emit()


## Seguro para cruzar a faixa `index` durante `seconds`? (aviso longo o bastante, ou recuperando, ou fora do padrao atual)
func lane_safe(index: int, seconds: float) -> bool:
	if is_defeated() or not index in _active_set:
		return true
	match _state:
		RootLane.State.ACTIVE: return false
		RootLane.State.TELEGRAPH: return _timer >= seconds
	return true


## Estado atual do ciclo de ataques (RootLane.State), para o corpo 3D reagir.
func attack_state() -> int:
	return _state


func current_timing() -> Vector3:
	return TIMING[mini(phase, 3)]


func _physics_process(delta: float) -> void:
	if is_defeated() or not started:
		return
	_timer -= delta
	if _timer > 0.0:
		for i in _active_set:
			lanes[i].remaining = _timer
		return
	var t: Vector3 = current_timing()
	match _state:
		RootLane.State.RECOVER:
			var patterns: Array = PATTERNS[mini(phase, 3)]
			_active_set = patterns[_pattern % patterns.size()]
			_pattern += 1
			_enter(RootLane.State.TELEGRAPH, t.x)
		RootLane.State.TELEGRAPH:
			_enter(RootLane.State.ACTIVE, t.y)
		_:
			_enter(RootLane.State.RECOVER, t.z)


func capture() -> Variant:
	return null


## Reinicio no checkpoint: volta a fase 1... EXCETO se o save ja registra a semente destruida (o chefe nao ressuscita).
func restore(_state_value: Variant) -> void:
	if not save.is_empty() and String(seed_id) in save["world"]["seed_destroyed_ids"]:
		_enter_defeated()
		return
	phase = Phase.ONE
	restart_cycle()


## Reinicia so o ciclo de ataques da fase atual (padrao 0, faixas ociosas).
func restart_cycle() -> void:
	_pattern = 0
	_active_set = []
	_apply_profiles()
	for lane in lanes:
		lane.set_state(RootLane.State.IDLE, 0.0)
	_state = RootLane.State.RECOVER
	_timer = 0.3


## Perfil de cada faixa conforme a fase: assinatura nas faixas escolhidas da fase 2 em diante; o resto continua erupcao de raiz.
func _apply_profiles() -> void:
	var armed: bool = phase >= SIGNATURE_FROM_PHASE and phase < Phase.DEFEATED
	for i in lanes.size():
		lanes[i].set_profile(signature if armed and i in signature_lanes else &"root")


func _enter(new_state: RootLane.State, time: float) -> void:
	_state = new_state
	_timer = time
	for i in lanes.size():
		lanes[i].set_state(new_state if i in _active_set else RootLane.State.IDLE, time)


func _enter_defeated() -> void:
	phase = Phase.DEFEATED
	for lane in lanes:
		lane.set_state(RootLane.State.IDLE, 0.0)
