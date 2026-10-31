class_name Accessibility
extends RefCounted
## Opcoes de acessibilidade em vigor (lidas pelos efeitos). Atualizadas pelo GraphicsApplier a partir de settings.json.
## Reduzir movimento: menos particulas e sem pulsos continuos. Reduzir flashes: nada alterna cor/brilho rapidamente.

const MOTION_PARTICLE_FACTOR: float = 0.25

static var reduce_motion: bool = false
static var reduce_flashing: bool = false


static func set_from(settings: Dictionary) -> void:
	reduce_motion = settings.get("reduce_motion", false) == true
	reduce_flashing = settings.get("reduce_flashing", false) == true


static func particle_factor() -> float:
	return MOTION_PARTICLE_FACTOR if reduce_motion else 1.0
