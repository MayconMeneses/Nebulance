class_name FuturisticBackdrop
extends Node3D
## Fundo de profundidade da fase: silhuetas ao longe no ESTILO DO PLANETA (BackdropStyles: torres organicas, cristais, chamines, ilhas
## flutuantes, nuvens, fragmentos), campo de estrelas (um unico MultiMesh) e piso holografico no abismo (grade que some com a distancia).
## So decoracao: sem colisao, sem fisica, sem estado. Posicoes DETERMINISTICAS (semente da fase), espalhadas pelo comprimento da fase.

const STAR_COUNT: int = 110
const FAR_Z: float = -26.0
const GRID_SHADER: String = "res://game/vfx/shaders/grid_floor.gdshader"

var style: StringName = &"industrial"


func build(min_x: float, max_x: float, palette: Dictionary, seed_text: String) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(seed_text)
	var x: float = min_x - 24.0
	while x < max_x + 40.0:
		for node in BackdropStyles.make(style, rng, palette, x, FAR_Z):
			add_child(node)
		x += rng.randf_range(20.0, 30.0)
	add_child(_stars(min_x, max_x, rng, palette["sky_horizon"]))
	add_child(_grid_floor(min_x, max_x, palette["trim"]))


## Piso holografico bem abaixo da fase: o abismo deixa de ser preto vazio e ganha profundidade.
func _grid_floor(min_x: float, max_x: float, trim: Color) -> MeshInstance3D:
	var plane := PlaneMesh.new()
	plane.size = Vector2(max_x - min_x + 240.0, 150.0)
	var mat := ShaderMaterial.new()
	mat.shader = load(GRID_SHADER) as Shader
	mat.set_shader_parameter("line_color", trim.lightened(0.1))
	mat.set_shader_parameter("scroll", 0.0 if Accessibility.reduce_motion else 0.6)
	plane.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = Vector3((min_x + max_x) * 0.5, -18.0, -34.0)
	return mi


func _stars(min_x: float, max_x: float, rng: RandomNumberGenerator, tint: Color) -> MultiMeshInstance3D:
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	var quad := BoxMesh.new()
	quad.size = Vector3(0.18, 0.18, 0.18)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color.WHITE.lerp(tint, 0.3)
	quad.material = mat
	multi.mesh = quad
	multi.instance_count = STAR_COUNT
	for i in STAR_COUNT:
		var pos := Vector3(rng.randf_range(min_x - 30.0, max_x + 50.0), rng.randf_range(8.0, 55.0), rng.randf_range(-70.0, -48.0))
		multi.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * rng.randf_range(0.6, 1.8)), pos))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = multi
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mmi
