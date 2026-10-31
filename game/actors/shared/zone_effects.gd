class_name ZoneEffects
extends RefCounted
## Efeitos de zonas locais (camada WIND) sobre um ActorController: vento e gravidade localizada.


static func wind_push(body: ActorController) -> Vector3:
	var push := Vector3.ZERO
	for zone in body.overlaps(PhysicsLayers.WIND):
		var value: Variant = zone.get("wind_push")
		if value is Vector3:
			push += value
	return push


## O menor multiplicador de gravidade entre as zonas sobrepostas (1.0 fora delas).
static func gravity_scale(body: ActorController) -> float:
	var scale: float = 1.0
	for zone in body.overlaps(PhysicsLayers.WIND):
		var value: Variant = zone.get("gravity_scale")
		if value is float:
			scale = minf(scale, value)
	return scale
