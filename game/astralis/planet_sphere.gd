class_name PlanetSphere
extends Node3D
## Planeta 3D do Mapa Galactico: esfera com shader procedural (`planet_surface`) que GIRA em torno do proprio eixo (inclinado).
## Visual por planeta (cores/nuvens/mar) e por estado (bloqueado escuro, em perigo com veias de corrupcao, salvo brilhante).
## So aparencia: sem colisao. "Reduzir movimento" para o giro e a deriva das nuvens.

const SHADER_PATH: String = "res://game/astralis/shaders/planet_surface.gdshader"
## Por planeta: cor da terra, cor do mar, nivel do mar, nuvens, velocidade de giro (rad/s), inclinacao do eixo (graus).
const LOOKS: Dictionary = {
	&"sylvara": {"land": Color("4FB36B"), "sea": Color("0B3D4A"), "sea_level": 0.5, "clouds": 0.55, "spin": 0.22, "tilt": 12.0},
	&"cristalia": {"land": Color("B79CFF"), "sea": Color("2A1B5E"), "sea_level": 0.42, "clouds": 0.15, "spin": 0.18, "tilt": 24.0},
	&"mecatron": {"land": Color("E0803A"), "sea": Color("3B2A22"), "sea_level": 0.38, "clouds": 0.25, "spin": 0.3, "tilt": 6.0},
	&"aquarys": {"land": Color("49D4E8"), "sea": Color("064A78"), "sea_level": 0.62, "clouds": 0.5, "spin": 0.2, "tilt": 18.0},
	&"aerion": {"land": Color("F2C879"), "sea": Color("8A6A38"), "sea_level": 0.5, "clouds": 0.85, "spin": 0.26, "tilt": 9.0},
	&"umbraxis": {"land": Color("8E2A7D"), "sea": Color("140616"), "sea_level": 0.45, "clouds": 0.1, "spin": 0.14, "tilt": 30.0},
}

var planet_id: StringName = &""
var radius: float = 46.0
var status: int = 0
var spin_speed: float = 0.2

var _mesh_instance: MeshInstance3D
var _material: ShaderMaterial
var _pivot: Node3D


func setup(id: StringName, planet_radius: float) -> void:
	planet_id = id
	radius = planet_radius
	var look: Dictionary = LOOKS.get(id, LOOKS[&"sylvara"])
	spin_speed = look["spin"]
	_pivot = Node3D.new()
	_pivot.rotation_degrees.z = look["tilt"]
	add_child(_pivot)
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = 40
	sphere.rings = 20
	_material = ShaderMaterial.new()
	_material.shader = load(SHADER_PATH) as Shader
	_material.set_shader_parameter("color_land", look["land"])
	_material.set_shader_parameter("color_sea", look["sea"])
	_material.set_shader_parameter("glow_color", (look["land"] as Color).lightened(0.4))
	_material.set_shader_parameter("sea_level", look["sea_level"])
	_material.set_shader_parameter("cloud_amount", look["clouds"])
	_material.set_shader_parameter("seed", float(String(id).hash() % 97) * 0.1)
	sphere.material = _material
	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.mesh = sphere
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_pivot.add_child(_mesh_instance)
	set_status(0)


## 0 bloqueado, 1 disponivel, 2 em perigo, 3 salvo (mesma ordem de GalaxyState.Status).
func set_status(new_status: int) -> void:
	status = new_status
	var dim: float = [0.3, 1.0, 1.0, 1.15][new_status]
	var corruption: float = [0.0, 0.35, 0.8, 0.0][new_status]
	_material.set_shader_parameter("dim", dim)
	_material.set_shader_parameter("corruption", corruption)
	_material.set_shader_parameter("drift", 0.0 if Accessibility.reduce_motion else 1.0)


## Angulo de giro acumulado (radianos); testavel sem esperar quadros.
func spin_angle() -> float:
	return _mesh_instance.rotation.y if _mesh_instance != null else 0.0


func _process(delta: float) -> void:
	if _mesh_instance != null and not Accessibility.reduce_motion:
		_mesh_instance.rotation.y = fmod(_mesh_instance.rotation.y + spin_speed * delta, TAU)
