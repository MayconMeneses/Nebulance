class_name SequenceCrystal
extends Area3D
## Cristal musical da S02: interagir (E) o aciona na fechadura de sequencia.

var lock: SequenceLock
var index: int = 0

var _material: StandardMaterial3D


func _ready() -> void:
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 1.8, 1.6)
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := PrismMesh.new()
	mesh.size = Vector3(0.9, 1.4, 0.9)
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material = _material
	mi.mesh = mesh
	add_child(mi)
	paint(false)


func can_interact() -> bool:
	return lock != null and not lock.is_unlocked


func prompt() -> String:
	return "Pressione E para tocar o cristal"


func interact() -> void:
	lock.press(index)


func paint(lit: bool) -> void:
	if _material != null:
		var c: Color = Color("FFE14A") if lit else [Color("A78BFA"), Color("56DDB5"), Color("23CFF5"), Color("F08A3B")][index % 4]
		_material.albedo_color = c
		_material.emission = c if lit else c * 0.3
