class_name FuturisticLook
extends RefCounted
## Fabrica do material "painel futurista" (shader futuristic_panel): chanfro simulado, friso emissivo, costuras e brilho de contorno.
## Um unico recurso de shader compartilhado (compila uma vez no Compatibility; o ShaderWarmup/primeiro desenho cobre o resto).

const SHADER_PATH: String = "res://game/vfx/shaders/futuristic_panel.gdshader"

static var _shader: Shader


static func panel(size: Vector3, base: Color, trim: Color, glowing: bool = false) -> ShaderMaterial:
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	var mat := ShaderMaterial.new()
	mat.shader = _shader
	var thin: float = minf(size.x, minf(size.y, size.z))
	mat.set_shader_parameter("base_color", base)
	mat.set_shader_parameter("trim_color", trim.lerp(base.lightened(0.35), 0.35) if glowing else trim)
	mat.set_shader_parameter("half_size", size * 0.5)
	mat.set_shader_parameter("bevel", clampf(thin * 0.3, 0.04, 0.22))
	mat.set_shader_parameter("trim_width", clampf(thin * 0.12, 0.02, 0.06))
	mat.set_shader_parameter("fill_glow", 0.55 if glowing else 0.0)
	return mat
