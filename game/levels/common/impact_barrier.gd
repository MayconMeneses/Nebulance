class_name ImpactBarrier
extends StaticBody3D
## Barreira marcada: so cede ao impacto da investida de Rocco.

signal broken

var is_broken: bool = false


func _ready() -> void:
	add_to_group(&"impact_target")
	add_to_group(&"snapshotable")
	collision_layer = PhysicsLayers.WORLD | PhysicsLayers.IMPACT_TARGET


func on_impacted() -> void:
	if is_broken:
		return
	is_broken = true
	set_deferred(&"collision_layer", 0)
	visible = false
	broken.emit()


func capture() -> Variant:
	return is_broken


func restore(state: Variant) -> void:
	is_broken = bool(state)
	visible = not is_broken
	collision_layer = 0 if is_broken else PhysicsLayers.WORLD | PhysicsLayers.IMPACT_TARGET
