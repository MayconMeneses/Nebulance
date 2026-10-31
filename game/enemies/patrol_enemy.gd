class_name PatrolEnemy
extends Area3D
## Criatura vegetal contaminada (sem armas): patrulha, AVISA (telegraph) e investe.
## So fere nos estados PATROL e LUNGE; em TELEGRAPH e COOLDOWN e inofensiva. Deterministica; reinicia no checkpoint.

enum State { PATROL, TELEGRAPH, LUNGE, COOLDOWN }

@export var patrol_min_x: float = 0.0
@export var patrol_max_x: float = 6.0
@export var speed: float = 1.5
@export var detect_range: float = 3.5
@export var telegraph_time: float = 0.7
@export var lunge_time: float = 0.35
@export var lunge_speed: float = 6.0
@export var cooldown_time: float = 1.0

var state: State = State.PATROL
var target: Node3D

var _dir: float = 1.0
var _timer: float = 0.0
var _start_x: float = 0.0
var _mesh: MeshInstance3D
var _material: StandardMaterial3D


func _ready() -> void:
	add_to_group(&"snapshotable")
	add_to_group(&"enemies")
	collision_mask = 0
	_start_x = position.x
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.0, 0.8, 1.5)
	shape.shape = box
	add_child(shape)
	_mesh = MeshInstance3D.new()
	var visual := SphereMesh.new()
	visual.radius = 0.45
	visual.height = 0.8
	_material = StandardMaterial3D.new()
	visual.material = _material
	_mesh.mesh = visual
	add_child(_mesh)
	_apply_state_look()


func is_harmful() -> bool:
	return state == State.PATROL or state == State.LUNGE


func _physics_process(delta: float) -> void:
	match state:
		State.PATROL:
			position.x += _dir * speed * delta
			if position.x >= patrol_max_x:
				_dir = -1.0
			elif position.x <= patrol_min_x:
				_dir = 1.0
			if _sees_target():
				_dir = signf(target.global_position.x - global_position.x)
				_enter(State.TELEGRAPH, telegraph_time)
		State.TELEGRAPH:
			_tick(delta, State.LUNGE, lunge_time)
		State.LUNGE:
			position.x = clampf(position.x + _dir * lunge_speed * delta, patrol_min_x, patrol_max_x)
			_tick(delta, State.COOLDOWN, cooldown_time)
		State.COOLDOWN:
			_tick(delta, State.PATROL, 0.0)


func capture() -> Variant:
	return null


## Reinicio previsivel: volta a posicao inicial e ao estado de patrulha.
func restore(_state: Variant) -> void:
	position.x = _start_x
	_dir = 1.0
	_enter(State.PATROL, 0.0)


func _sees_target() -> bool:
	if target == null:
		return false
	var d: Vector3 = target.global_position - global_position
	return absf(d.x) <= detect_range and absf(d.y) <= 2.0


func _tick(delta: float, next: State, next_time: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_enter(next, next_time)


func _enter(new_state: State, time: float) -> void:
	state = new_state
	_timer = time
	_apply_state_look()


func _apply_state_look() -> void:
	collision_layer = PhysicsLayers.HAZARD if is_harmful() else 0
	if _material == null:
		return
	match state:
		State.PATROL: _material.albedo_color = Color("B03A8C")
		State.TELEGRAPH: _material.albedo_color = Color("FFE14A")
		State.LUNGE: _material.albedo_color = Color("E0302C")
		State.COOLDOWN: _material.albedo_color = Color("5E5A70")
	_mesh.scale = Vector3(1.0, 1.35, 1.0) if state == State.TELEGRAPH else Vector3.ONE
