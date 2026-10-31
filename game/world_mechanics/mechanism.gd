class_name Mechanism
extends Area3D
## Mecanismo interativo (E): estabilizador de pontes, mecanismos antigos, simbolos. Ativa uma unica vez por tentativa
## e avisa os alvos ligados pelo `link_id` (plataformas de ruptura ou portoes). Estado capturavel (checkpoint).

signal activated(mechanism: Mechanism)

@export var mechanism_id: StringName = &""
@export var link_id: StringName = &""
@export var prompt_text: String = "Pressione E para ativar"
@export var tint: Color = Color("23CFF5")

var is_active: bool = false
var _material: StandardMaterial3D


func _ready() -> void:
	add_to_group(&"snapshotable")
	add_to_group(&"mechanisms")
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.4, 1.6, 1.6)
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.5, 1.0, 0.5)
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material = _material
	mi.mesh = mesh
	add_child(mi)
	_paint()


func can_interact() -> bool:
	return not is_active


func prompt() -> String:
	return prompt_text


func interact() -> void:
	activate()


func activate() -> void:
	if is_active:
		return
	is_active = true
	_paint()
	for platform in get_tree().get_nodes_in_group(&"rupture_platforms"):
		if platform.link_id == link_id and link_id != &"":
			platform.stabilize()
	activated.emit(self)


func capture() -> Variant:
	return is_active


func restore(state: Variant) -> void:
	is_active = bool(state)
	_paint()


func _paint() -> void:
	if _material != null:
		var c: Color = tint if is_active else Color("7A6A8A")
		_material.albedo_color = c
		_material.emission = c if is_active else Color.BLACK
