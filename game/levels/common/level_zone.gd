class_name LevelZone
extends Area3D
## Zona retangular de nivel: perigo, abismo, escalavel, vento ou checkpoint (definida pela camada).

@export var zone_layer: int = PhysicsLayers.HAZARD
@export var size: Vector3 = Vector3(2.0, 2.0, 2.0)
## Aceleracao aplicada a quem planar na zona (so camada WIND).
@export var wind_push: Vector3 = Vector3.ZERO


func _ready() -> void:
	collision_layer = zone_layer
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
