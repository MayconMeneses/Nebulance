class_name Rescue
extends Area3D
## Habitante de Sylvara em perigo: interagir (E) o resgata. Conta como segredo; o ledger registra em story.rescued_creatures.

signal rescued(rescue: Rescue)

@export var rescue_id: StringName = &""

var is_rescued: bool = false
var _material: StandardMaterial3D


func _ready() -> void:
	add_to_group(&"snapshotable")
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 1.4, 1.6)
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.4
	mesh.height = 0.8
	_material = StandardMaterial3D.new()
	mesh.material = _material
	mi.mesh = mesh
	add_child(mi)
	_paint()


func can_interact() -> bool:
	return not is_rescued


func prompt() -> String:
	return "Pressione E para ajudar a criatura"


func interact() -> void:
	is_rescued = true
	_paint()
	rescued.emit(self)


func capture() -> Variant:
	return is_rescued


func restore(state: Variant) -> void:
	is_rescued = bool(state)
	_paint()


func _paint() -> void:
	if _material != null:
		_material.albedo_color = Color("56DDB5") if is_rescued else Color("B03A8C")
