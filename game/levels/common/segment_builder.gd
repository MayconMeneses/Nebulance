class_name SegmentBuilder
extends RefCounted
## Monta pecas de nivel em graybox colorido (visual provisorio). Reutilizavel por todas as fases.

var parent: Node3D
## Cor do friso emissivo das pecas (vem da paleta do planeta) e extensao em x das pecas solidas (para o fundo de profundidade).
var trim_color: Color = Color(0.5, 0.84, 0.78)
var min_x: float = INF
var max_x: float = -INF


func _init(level_root: Node3D) -> void:
	parent = level_root


func solid(center: Vector3, size: Vector3, color: Color, emissive: bool = false) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = PhysicsLayers.WORLD
	body.collision_mask = 0
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	cs.shape = box
	body.add_child(cs)
	body.add_child(_panel(size, color, emissive))
	body.position = center
	min_x = minf(min_x, center.x - size.x * 0.5)
	max_x = maxf(max_x, center.x + size.x * 0.5)
	parent.add_child(body)
	return body


func decor(center: Vector3, size: Vector3, color: Color, emissive: bool = false) -> MeshInstance3D:
	var mi: MeshInstance3D = _panel(size, color, emissive)
	mi.position = center
	parent.add_child(mi)
	return mi


func zone(layer: int, zone_id: String, center: Vector3, size: Vector3, tint: Color, wind: Vector3 = Vector3.ZERO, gravity: float = 1.0) -> LevelZone:
	var z := LevelZone.new()
	z.zone_layer = layer
	z.zone_id = StringName(zone_id)
	z.size = size
	z.wind_push = wind
	z.gravity_scale = gravity
	z.position = center
	parent.add_child(z)
	if tint.a > 0.0:
		var mi: MeshInstance3D = _mesh(size, tint, true)
		(mi.mesh.material as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		z.add_child(mi)
	return z


func pickup(id: String, kind: Pickup.Kind, pos: Vector3) -> Pickup:
	var p := Pickup.new()
	p.pickup_id = StringName(id)
	p.kind = kind
	p.position = pos
	parent.add_child(p)
	return p


func barrier(center: Vector3, size: Vector3) -> ImpactBarrier:
	var b := ImpactBarrier.new()
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	cs.shape = box
	b.add_child(cs)
	b.add_child(_panel(size, Color("F08A3B"), true))
	b.position = center
	parent.add_child(b)
	return b


func chest(id: String, pos: Vector3) -> Chest:
	var c := Chest.new()
	c.chest_id = StringName(id)
	c.position = pos
	parent.add_child(c)
	return c


func enemy(pos: Vector3, min_x: float, max_x: float) -> PatrolEnemy:
	var e := PatrolEnemy.new()
	e.position = pos
	e.patrol_min_x = min_x
	e.patrol_max_x = max_x
	parent.add_child(e)
	return e


func tree(x: float, height: float) -> void:
	decor(Vector3(x, height * 0.5, -4.0), Vector3(0.5, height, 0.5), Color("5B3A29"))
	decor(Vector3(x, height + 0.6, -4.0), Vector3(2.6, 1.8, 2.6), Color("1E7A5C"), true)


## Peca solida/decorativa no visual futurista (shader de painel); as zonas translucidas continuam com `_mesh`.
func _panel(size: Vector3, color: Color, emissive: bool) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = FuturisticLook.panel(size, color, trim_color, emissive)
	mi.mesh = mesh
	return mi


func _mesh(size: Vector3, color: Color, emissive: bool) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	if emissive:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 0.6
	mesh.material = mat
	mi.mesh = mesh
	return mi
