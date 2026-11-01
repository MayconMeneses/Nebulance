class_name TideWalkway
extends StaticBody3D
## Passarela que so existe (solida) quando o nivel da agua esta em `solid_up_to` ou abaixo (maré baixa). Com a maré alta fica submersa
## e atravessavel (o heroi cai). Estado derivado do nivel do WaterBody: nada a capturar.

@export var size: Vector3 = Vector3(8.0, 0.4, 3.0)
@export var solid_up_to: int = 0
var water: WaterBody

var _mat: StandardMaterial3D


func _ready() -> void:
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
	_mat = StandardMaterial3D.new()
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = _mat
	mi.mesh = mesh
	add_child(mi)
	_apply()


func is_solid() -> bool:
	return water != null and water.level <= solid_up_to


func _physics_process(_delta: float) -> void:
	_apply()


func _apply() -> void:
	collision_layer = PhysicsLayers.WORLD if is_solid() else 0
	if _mat != null:
		_mat.albedo_color = Color(0.82, 0.76, 0.55, 1.0) if is_solid() else Color(0.35, 0.45, 0.6, 0.3)
