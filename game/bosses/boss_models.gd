class_name BossModels
extends RefCounted
## Modelos 3D PROCEDURAIS dos guardioes (so primitivas: sem arquivo de arte). `build` devolve {"root", "core", "moves"}: `moves` e a lista de
## pecas que se abrem/fecham ({"node", "from", "to", "mode": &"rot" | &"scale"}); o BossAvatar anima `open` de 0 a 1 por cima delas.
## Cada guardiao tem silhueta propria (PDF secao 08). So aparencia: sem colisao; o dano continua vindo das faixas do chefe.

const POSITIONS: Dictionary = {
	&"bite": Vector3(15.0, 0.0, -3.5), &"petal": Vector3(15.0, 0.0, -3.5), &"spike": Vector3(15.0, 0.0, -3.5),
	&"wave": Vector3(15.0, 0.0, -5.0), &"gust": Vector3(15.0, 0.0, -4.5), &"rift": Vector3(30.0, 0.0, -6.5),
}
## Escala por guardiao (presenca em cena).
const SCALES: Dictionary = {&"bite": 1.5, &"petal": 1.3, &"spike": 1.3, &"wave": 1.0, &"gust": 1.1, &"rift": 1.0}
const PLANET_OF: Dictionary = {&"bite": &"sylvara", &"petal": &"cristalia", &"spike": &"mecatron", &"wave": &"aquarys", &"gust": &"aerion", &"rift": &"umbraxis"}


static func build(kind: StringName, tint: Color) -> Dictionary:
	var model: Dictionary = {"root": Node3D.new(), "core": null, "moves": []}
	match kind:
		&"bite": BossModelsA.vyrkan(model, tint)
		&"petal": BossModelsA.zythra(model, tint)
		&"spike": BossModelsA.ferrorraiz(model, tint)
		&"wave": BossModelsB.thalassa(model, tint)
		&"gust": BossModelsB.zefrion(model, tint)
		_: BossModelsB.necryon(model, tint)
	return model


static func part(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color, glow: float = 0.0, rot: Vector3 = Vector3.ZERO, alpha: float = 1.0) -> MeshInstance3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(color.r, color.g, color.b, alpha)
	mat.roughness = 0.55
	mat.metallic = 0.2
	if alpha < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if glow > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = glow
	mesh.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


static func sphere(radius: float) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = radius
	s.height = radius * 2.0
	s.radial_segments = 12
	s.rings = 6
	return s


static func cone(radius: float, height: float) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = 0.0
	c.bottom_radius = radius
	c.height = height
	c.radial_segments = 8
	c.rings = 1
	return c


static func pillar(top: float, bottom: float, height: float) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = top
	c.bottom_radius = bottom
	c.height = height
	c.radial_segments = 10
	c.rings = 1
	return c


static func box(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b


## Pivo que se abre: cria um Node3D filho de `parent` em `pos` e registra o movimento.
static func pivot(model: Dictionary, parent: Node3D, pos: Vector3, from: Vector3, to: Vector3, mode: StringName = &"rot") -> Node3D:
	var node := Node3D.new()
	node.position = pos
	parent.add_child(node)
	(model["moves"] as Array).append({"node": node, "from": from, "to": to, "mode": mode})
	return node
