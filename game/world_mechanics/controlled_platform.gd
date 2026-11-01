class_name ControlledPlatform
extends StaticBody3D
## Plataforma que so existe (visivel e solida) enquanto o mecanismo de controle esta ativo: ilha oculta revelada por um painel.
## Estado derivado do mecanismo (que e capturado no checkpoint): nada a capturar aqui.

@export var size: Vector3 = Vector3(5.0, 0.5, 3.0)
var control: Mechanism

var _mi: MeshInstance3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
	_mi = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("EDB85E")
	mat.emission_enabled = true
	mat.emission = Color("8A6A2A")
	mesh.material = mat
	_mi.mesh = mesh
	add_child(_mi)
	_apply()


func is_solid() -> bool:
	return control != null and control.is_active


func _physics_process(_delta: float) -> void:
	_apply()


func _apply() -> void:
	var on: bool = is_solid()
	collision_layer = PhysicsLayers.WORLD if on else 0
	if _mi != null:
		_mi.visible = on
