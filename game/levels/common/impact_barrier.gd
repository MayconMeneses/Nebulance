class_name ImpactBarrier
extends StaticBody3D
## Barreira marcada: so cede ao impacto da investida de Rocco.

signal broken

var is_broken: bool = false


func _ready() -> void:
	add_to_group(&"impact_target")
	collision_layer = PhysicsLayers.WORLD | PhysicsLayers.IMPACT_TARGET


func on_impacted() -> void:
	if is_broken:
		return
	is_broken = true
	set_deferred(&"collision_layer", 0)
	visible = false
	broken.emit()
