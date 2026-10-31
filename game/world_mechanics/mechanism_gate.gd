class_name MechanismGate
extends StaticBody3D
## Portao que abre quando TODOS os mecanismos com o mesmo `link_id` estao ativos. Estado capturavel.

signal opened

@export var link_id: StringName = &""
@export var size: Vector3 = Vector3(1.2, 4.0, 3.0)

var is_open: bool = false


func _ready() -> void:
	add_to_group(&"snapshotable")
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
	mat.albedo_color = Color("52368A")
	mat.emission_enabled = true
	mat.emission = Color("52368A")
	mesh.material = mat
	mi.mesh = mesh
	add_child(mi)
	_apply()
	for m in get_tree().get_nodes_in_group(&"mechanisms"):
		if m.link_id == link_id:
			m.activated.connect(_check)


func _check(_m: Mechanism) -> void:
	if is_open:
		return
	var total: int = 0
	var active: int = 0
	for m in get_tree().get_nodes_in_group(&"mechanisms"):
		if m.link_id == link_id:
			total += 1
			active += 1 if m.is_active else 0
	if total > 0 and active == total:
		is_open = true
		_apply()
		opened.emit()


func capture() -> Variant:
	return is_open


func restore(state: Variant) -> void:
	is_open = bool(state)
	_apply()


func _apply() -> void:
	visible = not is_open
	collision_layer = 0 if is_open else PhysicsLayers.WORLD
