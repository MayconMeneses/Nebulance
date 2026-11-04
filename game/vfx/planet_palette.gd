class_name PlanetPalette
extends RefCounted
## Paleta visual por planeta e por estado: CORROMPIDO por Caeldron (ceu roxo escuro, nevoa magenta) ou RESTAURADO (ceu e friso na cor do
## planeta, mais claro). So aparencia (ceu, nevoa, brilho, luz e friso das pecas): nada aqui toca colisao, fisica ou regras.
## Cores base = `tint` dos recursos em game/astralis/data (conferido por `suite_visual_look`).

const CORRUPTION: Color = Color(0.55, 0.14, 0.48)
const DEFAULT_TINT: Color = Color(0.5, 0.84, 0.78)
const TINTS: Dictionary = {
	&"sylvara": Color(0.3686, 0.7608, 0.4784), &"cristalia": Color(0.6549, 0.5451, 0.9804), &"mecatron": Color(0.9412, 0.5412, 0.2314),
	&"aquarys": Color(0.1373, 0.8118, 0.9608), &"aerion": Color(0.9294, 0.7216, 0.3686), &"umbraxis": Color(0.7529, 0.2353, 0.6588),
}


## O planeta esta restaurado no save? (a semente dele foi destruida; `seed_<planeta>` como em game/astralis/data)
static func restored(save: Dictionary, planet_id: StringName) -> bool:
	return "seed_%s" % planet_id in save["world"]["seed_destroyed_ids"]


static func tint_of(planet_id: StringName) -> Color:
	return TINTS.get(planet_id, DEFAULT_TINT)


## Chaves: sky_top, sky_horizon, ground, fog, fog_density, trim, ambient, ambient_energy, sun, sun_energy, glow.
static func of(planet_id: StringName, restored: bool) -> Dictionary:
	var t: Color = tint_of(planet_id)
	if restored:
		return {"sky_top": t.darkened(0.6).lerp(Color(0.04, 0.12, 0.29), 0.4), "sky_horizon": t.lightened(0.3), "ground": t.darkened(0.7),
				"fog": t.darkened(0.3), "fog_density": 0.010, "trim": t.lightened(0.15), "ambient": t.lerp(Color.WHITE, 0.55),
				"ambient_energy": 0.8, "sun": Color("FFE9C4"), "sun_energy": 1.1, "glow": 0.9}
	return {"sky_top": Color(0.04, 0.02, 0.125).lerp(t, 0.12), "sky_horizon": CORRUPTION.lerp(t, 0.25).darkened(0.25), "ground": Color(0.03, 0.02, 0.1),
			"fog": CORRUPTION.darkened(0.55), "fog_density": 0.018, "trim": t.lerp(CORRUPTION, 0.3), "ambient": t.lerp(Color(0.54, 0.5, 0.69), 0.5),
			"ambient_energy": 0.65, "sun": Color(0.85, 0.82, 1.0), "sun_energy": 0.95, "glow": 1.0}
