class_name Pickup
extends Area3D
## Coletavel com ID estavel (moeda, item unico ou memoria). Visual provisorio.

enum Kind { COIN, ITEM, MEMORY }

signal collected(pickup: Pickup)

@export var pickup_id: StringName = &""
@export var kind: Kind = Kind.COIN

var is_collected: bool = false


func _ready() -> void:
	add_to_group(&"snapshotable")
	collision_layer = PhysicsLayers.PICKUP
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.45
	shape.shape = sphere
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var visual := SphereMesh.new()
	visual.radius = 0.22 if kind == Kind.COIN else 0.32
	visual.height = visual.radius * 2.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = [Color("EDB85E"), Color("56DDB5"), Color("23CFF5")][kind]
	mat.emission_enabled = true
	mat.emission = mat.albedo_color
	visual.material = mat
	mesh.mesh = visual
	add_child(mesh)


func collect() -> bool:
	if is_collected:
		return false
	is_collected = true
	visible = false
	collision_layer = 0
	collected.emit(self)
	return true


func capture() -> Variant:
	return is_collected


func restore(state: Variant) -> void:
	is_collected = bool(state)
	visible = not is_collected
	collision_layer = 0 if is_collected else PhysicsLayers.PICKUP
