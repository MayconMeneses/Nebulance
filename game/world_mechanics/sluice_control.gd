class_name SluiceControl
extends Area3D
## Comporta (E): leva o reservatorio ao nivel `target_level`. Repetir e inofensivo. O estado vive no WaterBody (capturavel).

@export var target_level: int = 0
@export var prompt_text: String = "Pressione E para operar a comporta"
## Desabilitada ate algo liberar (ex.: a etapa do chefe); o padrao e sempre disponivel.
var enabled: bool = true
var water: WaterBody

var _mat: StandardMaterial3D


func _ready() -> void:
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.4, 1.6, 1.6)
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.3
	mesh.bottom_radius = 0.3
	mesh.height = 1.0
	_mat = StandardMaterial3D.new()
	_mat.emission_enabled = true
	mesh.material = _mat
	mi.mesh = mesh
	add_child(mi)
	_paint()


func can_interact() -> bool:
	return water != null and enabled_for_use()


func enabled_for_use() -> bool:
	return enabled and water.level != target_level


func prompt() -> String:
	return prompt_text


func interact() -> void:
	if water != null:
		water.set_level(target_level)


func _physics_process(_delta: float) -> void:
	_paint()


func _paint() -> void:
	if _mat != null:
		var on: bool = water != null and water.level == target_level
		var c: Color = Color("23CFF5") if on else Color("7A6A8A")
		_mat.albedo_color = c
		_mat.emission = c if on else Color.BLACK
