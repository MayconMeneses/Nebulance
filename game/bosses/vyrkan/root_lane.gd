class_name RootLane
extends Area3D
## Faixa de erupcao de raizes de Vyrkan. So FERE no estado ACTIVE; no TELEGRAPH e so um aviso visual (amarelo).
## Volume baixo (3 m): plataformas altas sao refugio.

enum State { IDLE, TELEGRAPH, ACTIVE, RECOVER }

@export var lane_index: int = 0
@export var width: float = 3.0

var state: State = State.IDLE
var remaining: float = 0.0

var _material: StandardMaterial3D


func _ready() -> void:
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(width, 3.0, 3.0)
	shape.shape = box
	shape.position.y = 1.5
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, 0.2, 3.0)
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material = _material
	mi.mesh = mesh
	mi.position.y = 0.1
	add_child(mi)
	set_state(State.IDLE, 0.0)


func set_state(new_state: State, time: float) -> void:
	state = new_state
	remaining = time
	collision_layer = PhysicsLayers.HAZARD if state == State.ACTIVE else 0
	var c: Color = [Color(0.3, 0.2, 0.35), Color("FFE14A"), Color("E0302C"), Color("5E5A70")][state]
	_material.albedo_color = c
	_material.emission = c if state != State.IDLE else Color.BLACK
