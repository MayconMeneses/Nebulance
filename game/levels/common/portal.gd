class_name Portal
extends Area3D
## Portal para uma fase secreta (origem/destino/retorno). Interagir (E) entra; so abre se `requires_open` for atendido.

signal entered(portal: Portal)

@export var portal_id: StringName = &""
@export var destination_level_id: StringName = &""
## Se verdadeiro, so funciona depois de `open()` (ex.: mecanismos ativos); capturavel pelo checkpoint.
@export var requires_open: bool = false

var is_open: bool = true
var _material: StandardMaterial3D


func _ready() -> void:
	add_to_group(&"snapshotable")
	is_open = not requires_open
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 2.4, 1.6)
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.7
	mesh.outer_radius = 0.95
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material = _material
	mi.mesh = mesh
	mi.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	add_child(mi)
	_paint()


func open() -> void:
	is_open = true
	_paint()


func can_interact() -> bool:
	return is_open


func prompt() -> String:
	return "Pressione E para entrar no portal"


func interact() -> void:
	entered.emit(self)


func capture() -> Variant:
	return is_open


func restore(state: Variant) -> void:
	is_open = bool(state)
	_paint()


func _paint() -> void:
	if _material != null:
		var c: Color = Color("56DDB5") if is_open else Color(0.3, 0.3, 0.4)
		_material.albedo_color = c
		_material.emission = c if is_open else Color.BLACK
