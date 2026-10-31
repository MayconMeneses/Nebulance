class_name TriadNode
extends Area3D
## Um dos tres pontos do Golpe Triade. A regra (heroi diferente por ponto) mora no TriadFinisher.

var finisher: TriadFinisher
var index: int = 0
var is_active: bool = false

var _material: StandardMaterial3D


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
	mesh.bottom_radius = 0.4
	mesh.height = 1.0
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material = _material
	mi.mesh = mesh
	add_child(mi)
	set_active(false)


func can_interact() -> bool:
	return finisher != null and finisher.can_press(self)


func prompt() -> String:
	return "Pressione E: Golpe Triade (cada heroi usa um ponto)"


func interact() -> void:
	finisher.press(self)


func set_active(on: bool) -> void:
	is_active = on
	if _material != null:
		var c: Color = Color("56DDB5") if on else Color("C03CA8")
		_material.albedo_color = c
		_material.emission = c
