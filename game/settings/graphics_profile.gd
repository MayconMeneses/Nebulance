class_name GraphicsProfile
extends RefCounted
## Perfis Baixo/Medio/Alto. So controles que EXISTEM no renderizador Compatibility (ADR-0007).

const IDS: Array[String] = ["low", "medium", "high"]
const FPS_OPTIONS: Array[int] = [0, 30, 60, 120]

const PROFILES: Dictionary = {
	"low": {"msaa": 0, "render_scale": 0.75, "shadows": false, "particle_scale": 0.3},
	"medium": {"msaa": 1, "render_scale": 1.0, "shadows": true, "particle_scale": 0.6},
	"high": {"msaa": 2, "render_scale": 1.0, "shadows": true, "particle_scale": 1.0},
}
## Escala de particulas em vigor (lida pelos efeitos; atualizada pelo GraphicsApplier).
static var particle_scale: float = 1.0


static func values(profile_id: String) -> Dictionary:
	return PROFILES.get(profile_id, PROFILES["medium"])


static func label(profile_id: String) -> String:
	return {"low": "Baixo", "medium": "Medio", "high": "Alto"}.get(profile_id, "Medio")
