class_name AmbientWeather
extends CPUParticles3D
## Clima/atmosfera de cada planeta: particulas suaves que flutuam ao redor da camera (esporos, poeira de cristal, faiscas, bolhas, vento,
## cinzas). Quantidade escalada pelo perfil grafico e por "reduzir movimento" (0 = nada). So aparencia: sem colisao e sem estado.

## Por planeta: cor, quantidade base, direcao, velocidade, tamanho, vida (s), gravidade y.
const KINDS: Dictionary = {
	&"sylvara": {"color": Color(0.7, 1.0, 0.5), "amount": 34, "dir": Vector3(0.0, 1.0, 0.0), "speed": 0.5, "size": 0.09, "life": 7.0, "gravity": 0.05},
	&"cristalia": {"color": Color(0.85, 0.75, 1.0), "amount": 40, "dir": Vector3(1.0, 0.2, 0.0), "speed": 0.6, "size": 0.07, "life": 6.0, "gravity": 0.0},
	&"mecatron": {"color": Color(1.0, 0.6, 0.2), "amount": 26, "dir": Vector3(0.0, 1.0, 0.0), "speed": 2.2, "size": 0.07, "life": 2.5, "gravity": -2.0},
	&"aquarys": {"color": Color(0.6, 0.95, 1.0), "amount": 30, "dir": Vector3(0.0, 1.0, 0.0), "speed": 0.9, "size": 0.14, "life": 6.0, "gravity": 0.2},
	&"aerion": {"color": Color(1.0, 0.95, 0.8), "amount": 22, "dir": Vector3(-1.0, 0.05, 0.0), "speed": 7.0, "size": 0.06, "life": 2.4, "gravity": 0.0},
	&"umbraxis": {"color": Color(0.95, 0.3, 0.85), "amount": 32, "dir": Vector3(0.1, -1.0, 0.0), "speed": 0.7, "size": 0.1, "life": 7.0, "gravity": -0.1},
}

var kind: StringName = &""


func setup(planet_id: StringName) -> void:
	kind = planet_id if KINDS.has(planet_id) else &"sylvara"
	var spec: Dictionary = KINDS[kind]
	var scale: float = GraphicsProfile.particle_scale
	amount = maxi(int(float(spec["amount"]) * scale), 1)
	emitting = scale > 0.0
	lifetime = spec["life"]
	preprocess = spec["life"]
	explosiveness = 0.0
	emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	emission_box_extents = Vector3(24.0, 9.0, 6.0)
	direction = spec["dir"]
	spread = 25.0
	initial_velocity_min = float(spec["speed"]) * 0.6
	initial_velocity_max = float(spec["speed"]) * 1.2
	gravity = Vector3(0.0, spec["gravity"], 0.0)
	var sphere := SphereMesh.new()
	sphere.radius = spec["size"]
	sphere.height = sphere.radius * 2.0
	sphere.radial_segments = 6
	sphere.rings = 3
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = (spec["color"] as Color)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.8
	mat.disable_fog = true
	sphere.material = mat
	mesh = sphere
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Acompanha a camera: a caixa fica a ~12 m a frente dela (no plano do jogo).
	position = Vector3(0.0, 0.0, -12.0)
