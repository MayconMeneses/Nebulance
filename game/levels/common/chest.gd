class_name Chest
extends Area3D
## Bau de conclusao: abre uma vez por tentativa; a recompensa e decidida pelo RewardLedger.

signal opened(chest: Chest)

@export var chest_id: StringName = &""

## Trancado ate algo (ex.: derrotar o chefe) liberar.
var locked: bool = false
var is_open: bool = false
var _material: StandardMaterial3D


func _ready() -> void:
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 1.2, 1.6)
	shape.shape = box
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var visual := BoxMesh.new()
	visual.size = Vector3(1.2, 0.8, 0.8)
	_material = StandardMaterial3D.new()
	_material.albedo_color = Color("EDB85E")
	visual.material = _material
	mesh.mesh = visual
	mesh.position.y = -0.2
	add_child(mesh)


func can_interact() -> bool:
	return not is_open and not locked


func prompt() -> String:
	return "Pressione E para abrir"


func interact() -> void:
	open()


func open() -> bool:
	if is_open:
		return false
	is_open = true
	_material.albedo_color = Color("56DDB5")
	opened.emit(self)
	return true
