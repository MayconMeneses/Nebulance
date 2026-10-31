class_name HydraulicPress
extends Area3D
## Prensa hidraulica deterministica. Ciclo fixo: IDLE -> TELEGRAPH (aviso amarelo, >= 0,6 s) -> DOWN (fere) -> RECOVER (sobe, seguro).
## So FERE em DOWN. O estado e funcao do tempo acumulado (`elapsed + phase`), entao e capturavel e reinicia idempotente.

enum State { IDLE, TELEGRAPH, DOWN, RECOVER }

const IDLE_TIME: float = 2.0
const TELEGRAPH_TIME: float = 0.8
const DOWN_TIME: float = 0.6
const RECOVER_TIME: float = 0.6
const PERIOD: float = IDLE_TIME + TELEGRAPH_TIME + DOWN_TIME + RECOVER_TIME

@export var width: float = 3.0
@export var phase: float = 0.0

var elapsed: float = 0.0
var state: State = State.IDLE

var _head: MeshInstance3D
var _material: StandardMaterial3D


func _ready() -> void:
	add_to_group(&"snapshotable")
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(width, 3.0, 3.0)
	shape.shape = box
	shape.position.y = 1.5
	add_child(shape)
	_head = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, 1.0, 3.0)
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material = _material
	_head.mesh = mesh
	add_child(_head)
	_apply()


static func state_at(t: float) -> State:
	var p: float = fposmod(t, PERIOD)
	if p < IDLE_TIME:
		return State.IDLE
	if p < IDLE_TIME + TELEGRAPH_TIME:
		return State.TELEGRAPH
	if p < IDLE_TIME + TELEGRAPH_TIME + DOWN_TIME:
		return State.DOWN
	return State.RECOVER


## Segundos ate o proximo DOWN (0 se ja esta em DOWN).
func time_to_down() -> float:
	var p: float = fposmod(elapsed + phase, PERIOD)
	var start: float = IDLE_TIME + TELEGRAPH_TIME
	if p < start + DOWN_TIME and p >= start:
		return 0.0
	return fposmod(start - p, PERIOD)


func _physics_process(delta: float) -> void:
	elapsed += delta
	_apply()


func capture() -> Variant:
	return elapsed


func restore(saved: Variant) -> void:
	elapsed = float(saved)
	_apply()


func _apply() -> void:
	state = state_at(elapsed + phase)
	collision_layer = PhysicsLayers.HAZARD if state == State.DOWN else 0
	var c: Color = [Color(0.35, 0.37, 0.42), Color("FFE14A"), Color("E0302C"), Color("5E5A70")][state]
	_material.albedo_color = c
	_material.emission = c if state != State.IDLE else Color.BLACK
	_head.position.y = [4.5, 3.4, 0.5, 2.5][state]
