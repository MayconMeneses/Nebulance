class_name BossAvatar
extends Node3D
## Corpo 3D animado do guardiao (BossModels) preso a um chefe: LE o estado do ciclo de ataques e reage de forma legivel, sem decidir nada.
## TELEGRAPH = "junta forca" (abre a boca/petalas/espinhos, nucleo brilha); ACTIVE = golpe (fecha de uma vez e avanca); RECOVER = relaxa;
## derrota = forma calma (encolhe e acalma o brilho). Mudar de fase solta um pulso. "Reduzir movimento" tira o balanco e o pulso continuo.

enum Mood { IDLE, GATHER, STRIKE, RECOVER, DEFEATED }

const OPEN_TARGET: Array[float] = [0.25, 1.0, 0.0, 0.4, 0.1]

var kind: StringName = &"bite"
var mood: int = Mood.IDLE
var open: float = 0.25
var core: MeshInstance3D

var _boss: VyrkanBoss
var _root: Node3D
var _moves: Array = []
var _roar: float = 0.0
var _time: float = 0.0
var _core_color: Color = Color.WHITE


func setup(boss_kind: StringName, boss: VyrkanBoss) -> void:
	kind = boss_kind
	_boss = boss
	_core_color = PlanetPalette.tint_of(BossModels.PLANET_OF.get(kind, &"sylvara"))
	var model: Dictionary = BossModels.build(kind, _core_color)
	_root = model["root"]
	core = model["core"]
	_moves = model["moves"]
	add_child(_root)
	position = BossModels.POSITIONS.get(kind, Vector3(15.0, 0.0, -3.5))
	scale = Vector3.ONE * float(BossModels.SCALES.get(kind, 1.3))
	boss.phase_changed.connect(func(_p: int) -> void: _roar = 1.0)


func _process(delta: float) -> void:
	if _boss == null:
		return
	_time += delta
	mood = _mood_of(_boss)
	var speed: float = 9.0 if mood == Mood.STRIKE else 2.4
	open = move_toward(open, OPEN_TARGET[mood], speed * delta)
	_roar = move_toward(_roar, 0.0, delta * 1.6)
	for move in _moves:
		var node: Node3D = move["node"]
		var value: Vector3 = (move["from"] as Vector3).lerp(move["to"], open)
		if move["mode"] == &"scale":
			node.scale = value
		else:
			node.rotation_degrees = value
	var calm: bool = Accessibility.reduce_motion
	_root.rotation.z = 0.0 if calm else sin(_time * 0.8) * 0.03
	var pulse: float = 0.0 if calm else sin(_time * 3.0) * 0.05
	var lunge: float = 0.9 if mood == Mood.STRIKE else 0.0
	_root.position.z = lerpf(_root.position.z, lunge, clampf(8.0 * delta, 0.0, 1.0))
	var shrink: float = 0.88 if mood == Mood.DEFEATED else 1.0
	_root.scale = _root.scale.lerp(Vector3.ONE * shrink * (1.0 + pulse + _roar * 0.15), clampf(6.0 * delta, 0.0, 1.0))
	var material := core.mesh.material as StandardMaterial3D
	material.emission_energy_multiplier = (0.5 if mood == Mood.DEFEATED else 1.6 + open * 2.0 + _roar * 2.0)
	material.emission = _core_color.lightened(0.35) if mood == Mood.DEFEATED else _core_color


static func _mood_of(boss: VyrkanBoss) -> int:
	if boss.is_defeated():
		return Mood.DEFEATED
	match boss.attack_state():
		RootLane.State.TELEGRAPH: return Mood.GATHER
		RootLane.State.ACTIVE: return Mood.STRIKE
		RootLane.State.RECOVER: return Mood.RECOVER
	return Mood.IDLE
