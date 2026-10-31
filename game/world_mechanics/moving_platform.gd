class_name MovingPlatform
extends AnimatableBody3D
## Plataforma movel deterministica (vai e volta senoidal pelo eixo X) que carrega o heroi. Estado capturavel.

@export var size: Vector3 = Vector3(3.0, 0.4, 3.0)
@export var amplitude: float = 2.0
@export var period: float = 6.0
@export var phase: float = 0.0

var elapsed: float = 0.0
var origin_x: float = 0.0


func _ready() -> void:
	add_to_group(&"snapshotable")
	sync_to_physics = true
	collision_layer = PhysicsLayers.WORLD
	collision_mask = 0
	origin_x = position.x
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("2FA8C8")
	mat.emission_enabled = true
	mat.emission = Color("2FA8C8")
	mesh.material = mat
	mi.mesh = mesh
	add_child(mi)
	_apply()


func current_x() -> float:
	return origin_x + amplitude * sin(TAU * (elapsed + phase) / period)


func _physics_process(delta: float) -> void:
	elapsed += delta
	_apply()


func capture() -> Variant:
	return elapsed


func restore(state: Variant) -> void:
	elapsed = float(state)
	_apply()


func _apply() -> void:
	position.x = current_x()
