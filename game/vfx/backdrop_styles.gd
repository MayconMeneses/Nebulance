class_name BackdropStyles
extends RefCounted
## Silhuetas do fundo por planeta (so primitivas baratas, sem colisao): cada planeta tem uma "cidade/paisagem" distinta ao longe.
## `make` devolve os nos de UM elemento na posicao x (profundidade e altura sorteadas pelo RNG com semente). So decoracao.

const STYLE_OF: Dictionary = {
	&"sylvara": &"bio", &"cristalia": &"crystal", &"mecatron": &"industrial", &"aquarys": &"islands", &"aerion": &"sky", &"umbraxis": &"shards",
}


static func style_of(planet_id: StringName) -> StringName:
	return STYLE_OF.get(planet_id, &"industrial")


static func make(style: StringName, rng: RandomNumberGenerator, palette: Dictionary, x: float, far_z: float) -> Array[Node3D]:
	var dark: Color = (palette["ground"] as Color).lerp(palette["sky_horizon"], 0.25)
	var trim: Color = palette["trim"]
	var z: float = far_z - rng.randf_range(0.0, 12.0)
	match style:
		&"bio": return _bio(rng, dark, trim, x, z)
		&"crystal": return _crystal(rng, dark, trim, x, z)
		&"islands": return _islands(rng, dark, trim, x, z)
		&"sky": return _sky(rng, dark, trim, x, z)
		&"shards": return _shards(rng, dark, trim, x, z)
	return _industrial(rng, dark, trim, x, z)


static func _instance(mesh: Mesh, size_hint: Vector3, base: Color, trim: Color, glowing: bool = false) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mesh.material = FuturisticLook.panel(size_hint, base, trim, glowing)
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


static func _glow(color: Color, energy: float = 1.6) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color.lightened(0.3)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = energy
	return mat


## Sylvara: torres organicas finas (cone) com bulbos luminosos.
static func _bio(rng: RandomNumberGenerator, dark: Color, trim: Color, x: float, z: float) -> Array[Node3D]:
	var h: float = rng.randf_range(34.0, 60.0)
	var cone := CylinderMesh.new()
	cone.top_radius = 0.15
	cone.bottom_radius = rng.randf_range(1.2, 2.2)
	cone.height = h
	cone.radial_segments = 8
	cone.rings = 1
	var tower: MeshInstance3D = _instance(cone, Vector3(2.0, h, 2.0), dark, trim)
	tower.position = Vector3(x, h * 0.5 - 40.0, z)
	var bulb := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = rng.randf_range(0.9, 1.6)
	sphere.height = sphere.radius * 2.0
	sphere.radial_segments = 10
	sphere.rings = 6
	sphere.material = _glow(trim)
	bulb.mesh = sphere
	bulb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bulb.position = Vector3(x, h - 40.0, z)
	return [tower, bulb]


## Cristalia: espetos de cristal (prismas) inclinados, translucidos.
static func _crystal(rng: RandomNumberGenerator, dark: Color, trim: Color, x: float, z: float) -> Array[Node3D]:
	var out: Array[Node3D] = []
	for i in 3:
		var prism := PrismMesh.new()
		prism.size = Vector3(rng.randf_range(2.0, 4.0), rng.randf_range(22.0, 48.0), rng.randf_range(2.0, 4.0))
		var mi: MeshInstance3D = _instance(prism, prism.size, dark.lightened(0.1), trim, true)
		mi.position = Vector3(x + float(i) * rng.randf_range(2.0, 4.5), prism.size.y * 0.5 - 40.0, z + float(i) * 1.5)
		mi.rotation_degrees = Vector3(0.0, rng.randf_range(0.0, 60.0), rng.randf_range(-8.0, 8.0))
		out.append(mi)
	return out


## Mecatron: chamines largas e um engrenagem-anel gigante.
static func _industrial(rng: RandomNumberGenerator, dark: Color, trim: Color, x: float, z: float) -> Array[Node3D]:
	var h: float = rng.randf_range(50.0, 70.0)
	var box := BoxMesh.new()
	box.size = Vector3(rng.randf_range(1.6, 3.2), h, rng.randf_range(1.6, 3.2))
	var tower: MeshInstance3D = _instance(box, box.size, dark, trim)
	tower.position = Vector3(x, h * 0.5 - 44.0, z)
	var out: Array[Node3D] = [tower]
	if rng.randf() < 0.6:
		out.append(_ring(Vector3(x + rng.randf_range(6.0, 12.0), rng.randf_range(10.0, 26.0), z - rng.randf_range(8.0, 18.0)), rng, trim))
	return out


## Aquarys: ilhas flutuantes (discos) em varias alturas com uma coluna de luz.
static func _islands(rng: RandomNumberGenerator, dark: Color, trim: Color, x: float, z: float) -> Array[Node3D]:
	var disc := CylinderMesh.new()
	disc.top_radius = rng.randf_range(4.0, 8.0)
	disc.bottom_radius = disc.top_radius * 0.55
	disc.height = rng.randf_range(2.0, 3.5)
	disc.radial_segments = 14
	disc.rings = 1
	var island: MeshInstance3D = _instance(disc, Vector3(disc.top_radius * 2.0, disc.height, disc.top_radius * 2.0), dark, trim, true)
	island.position = Vector3(x, rng.randf_range(2.0, 22.0), z)
	var beam := MeshInstance3D.new()
	var col := CylinderMesh.new()
	col.top_radius = 0.18
	col.bottom_radius = 0.18
	col.height = 60.0
	col.radial_segments = 6
	col.rings = 1
	col.material = _glow(trim, 1.2)
	beam.mesh = col
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	beam.position = Vector3(x, island.position.y - 28.0, z)
	return [island, beam]


## Aerion: faixas de nuvem (lajes largas e finas) e aneis de vento.
static func _sky(rng: RandomNumberGenerator, dark: Color, trim: Color, x: float, z: float) -> Array[Node3D]:
	var out: Array[Node3D] = []
	for i in 2:
		var slab := BoxMesh.new()
		slab.size = Vector3(rng.randf_range(14.0, 28.0), rng.randf_range(0.8, 1.6), rng.randf_range(5.0, 9.0))
		var mi: MeshInstance3D = _instance(slab, slab.size, dark.lightened(0.15), trim, true)
		mi.position = Vector3(x + float(i) * 9.0, rng.randf_range(0.0, 30.0), z - float(i) * 6.0)
		out.append(mi)
	out.append(_ring(Vector3(x + rng.randf_range(0.0, 10.0), rng.randf_range(12.0, 30.0), z - 10.0), rng, trim))
	return out


## Umbraxis: fragmentos de mundo (caixas inclinadas) flutuando e pilones quebrados.
static func _shards(rng: RandomNumberGenerator, dark: Color, trim: Color, x: float, z: float) -> Array[Node3D]:
	var out: Array[Node3D] = []
	for i in 3:
		var box := BoxMesh.new()
		box.size = Vector3(rng.randf_range(2.0, 7.0), rng.randf_range(2.0, 9.0), rng.randf_range(2.0, 5.0))
		var mi: MeshInstance3D = _instance(box, box.size, dark, trim, true)
		mi.position = Vector3(x + float(i) * rng.randf_range(3.0, 7.0), rng.randf_range(0.0, 32.0), z - float(i) * 3.0)
		mi.rotation_degrees = Vector3(rng.randf_range(-25.0, 25.0), rng.randf_range(0.0, 90.0), rng.randf_range(-25.0, 25.0))
		out.append(mi)
	return out


static func _ring(at: Vector3, rng: RandomNumberGenerator, trim: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.outer_radius = rng.randf_range(5.0, 9.0)
	torus.inner_radius = torus.outer_radius - 0.35
	torus.rings = 28
	torus.ring_segments = 8
	torus.material = _glow(trim.darkened(0.2), 0.9)
	mi.mesh = torus
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = at
	mi.rotation_degrees = Vector3(rng.randf_range(55.0, 85.0), rng.randf_range(-25.0, 25.0), 0.0)
	return mi
