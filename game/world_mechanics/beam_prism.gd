class_name BeamPrism
extends Area3D
## Prisma girateis: interagir (E) alterna '/' e '\'. Orientacao capturavel pelo checkpoint (volta ao estado inicial).

signal rotated(prism: BeamPrism)

var cell: Vector2i = Vector2i.ZERO
var orientation: int = 0
var field: BeamField

var _mesh: MeshInstance3D


func _ready() -> void:
	add_to_group(&"snapshotable")
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.4, 1.6, 1.6)
	shape.shape = box
	add_child(shape)
	_mesh = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.18, 1.1, 0.5)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("9FD8E8")
	mat.emission_enabled = true
	mat.emission = Color("9FD8E8")
	mesh.material = mat
	_mesh.mesh = mesh
	add_child(_mesh)
	_apply()


func can_interact() -> bool:
	return true


func prompt() -> String:
	return "Pressione E para girar o prisma"


func interact() -> void:
	orientation = 1 - orientation
	_apply()
	rotated.emit(self)


func capture() -> Variant:
	return orientation


func restore(state: Variant) -> void:
	orientation = int(state)
	_apply()


func _apply() -> void:
	if _mesh != null:
		_mesh.rotation_degrees = Vector3(0.0, 0.0, -45.0 if orientation == 0 else 45.0)
	if field != null:
		field.mark_dirty()
