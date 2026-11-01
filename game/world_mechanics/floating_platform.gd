class_name FloatingPlatform
extends AnimatableBody3D
## Plataforma que boia: a altura acompanha a superficie do WaterBody (`water.height + offset`), carregando o heroi.

@export var size: Vector3 = Vector3(4.0, 0.4, 3.0)
@export var offset: float = 0.0
var water: WaterBody


func _ready() -> void:
	sync_to_physics = true
	collision_layer = PhysicsLayers.WORLD
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("2FD2B0")
	mat.emission_enabled = true
	mat.emission = Color("167A66")
	mesh.material = mat
	mi.mesh = mesh
	add_child(mi)
	_apply()


func _physics_process(_delta: float) -> void:
	_apply()


func _apply() -> void:
	if water != null:
		position.y = water.height + offset
