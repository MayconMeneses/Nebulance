class_name LevelAtmosphere
extends RefCounted
## Ambiente da fase a partir da paleta do planeta: ceu procedural, nevoa de profundidade, brilho (glow) e curva de cores. So aparencia.
## O brilho acompanha o perfil grafico (Baixo = sem brilho); o grupo `level_environment` deixa o GraphicsApplier religar/desligar em jogo.

const GROUP: StringName = &"level_environment"


static func environment(palette: Dictionary) -> Environment:
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = palette["sky_top"]
	sky_material.sky_horizon_color = palette["sky_horizon"]
	sky_material.ground_horizon_color = (palette["sky_horizon"] as Color).darkened(0.3)
	sky_material.ground_bottom_color = (palette["sky_horizon"] as Color).darkened(0.75)
	sky_material.sky_curve = 0.25
	sky_material.ground_curve = 0.06
	var sky := Sky.new()
	sky.sky_material = sky_material
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = palette["ambient"]
	env.ambient_light_energy = palette["ambient_energy"]
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = palette["fog"]
	env.fog_density = palette["fog_density"]
	env.fog_sky_affect = 0.0
	env.adjustment_enabled = true
	env.adjustment_contrast = 1.06
	env.adjustment_saturation = 1.12
	env.glow_intensity = palette["glow"]
	env.glow_bloom = 0.06
	env.glow_hdr_threshold = 0.85
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	apply_glow(env, GraphicsProfile.glow_on)
	return env


static func apply_glow(env: Environment, on: bool) -> void:
	env.glow_enabled = on
