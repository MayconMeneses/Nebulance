class_name ChaseWave
extends Area3D
## Onda de raizes (perseguicao curta): comeca a avancar quando o heroi passa de `trigger_x`; fere ao tocar.
## Reinicia previsivelmente no checkpoint (volta ao inicio e desarmada; o heroi reaparece antes do gatilho).

@export var trigger_x: float = 64.0
@export var speed: float = 3.0
@export var stop_x: float = 112.0
@export var start_x: float = 54.0

var target: Node3D
var running: bool = false


func _ready() -> void:
	add_to_group(&"snapshotable")
	collision_layer = PhysicsLayers.HAZARD
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.0, 8.0, 4.0)
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.0, 8.0, 3.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("7A1F5C")
	mat.emission_enabled = true
	mat.emission = Color("C03CA8")
	mesh.material = mat
	mi.mesh = mesh
	add_child(mi)
	position.x = start_x


func _physics_process(delta: float) -> void:
	if not running and target != null and target.global_position.x >= trigger_x:
		running = true
	if running and position.x < stop_x:
		position.x += speed * delta


func capture() -> Variant:
	return null


func restore(_state: Variant) -> void:
	running = false
	position.x = start_x
