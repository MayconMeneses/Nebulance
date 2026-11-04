class_name FuturisticBackdrop
extends Node3D
## Fundo de profundidade da fase: pilones e aneis gigantes ao longe (atras da nevoa) e um campo de estrelas (um unico MultiMesh).
## So decoracao: sem colisao, sem fisica, sem estado. Posicoes DETERMINISTICAS (semente do planeta), espalhadas pelo comprimento da fase.

const STAR_COUNT: int = 110
const FAR_Z: float = -26.0


func build(min_x: float, max_x: float, palette: Dictionary, seed_text: String) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(seed_text)
	var trim: Color = palette["trim"]
	var dark: Color = (palette["ground"] as Color).lerp(palette["sky_horizon"], 0.25)
	var x: float = min_x - 24.0
	while x < max_x + 40.0:
		var h: float = rng.randf_range(50.0, 70.0)
		var size := Vector3(rng.randf_range(1.2, 2.4), h, rng.randf_range(1.2, 2.4))
		var pylon := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = size
		box.material = FuturisticLook.panel(size, dark, trim)
		pylon.mesh = box
		pylon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pylon.position = Vector3(x, h * 0.5 - 44.0, FAR_Z - rng.randf_range(0.0, 10.0))
		add_child(pylon)
		if rng.randf() < 0.55:
			add_child(_ring(Vector3(x + rng.randf_range(6.0, 12.0), rng.randf_range(10.0, 26.0), FAR_Z - rng.randf_range(10.0, 22.0)), rng, trim))
		x += rng.randf_range(20.0, 30.0)
	add_child(_stars(min_x, max_x, rng, palette["sky_horizon"]))


func _ring(at: Vector3, rng: RandomNumberGenerator, trim: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.outer_radius = rng.randf_range(5.0, 9.0)
	torus.inner_radius = torus.outer_radius - 0.35
	var mat := StandardMaterial3D.new()
	mat.albedo_color = trim.darkened(0.4)
	mat.emission_enabled = true
	mat.emission = trim
	mat.emission_energy_multiplier = 0.9
	torus.material = mat
	mi.mesh = torus
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = at
	mi.rotation_degrees = Vector3(rng.randf_range(55.0, 85.0), rng.randf_range(-25.0, 25.0), 0.0)
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
