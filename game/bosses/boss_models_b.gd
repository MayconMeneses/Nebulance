class_name BossModelsB
extends RefCounted
## Thalassa (vitoria-regia colossal), Zefrion (dente-de-leao radial) e Necryon (flor-cadaver com fenda dimensional). Ver BossModels.


static func thalassa(model: Dictionary, tint: Color) -> void:
	var root: Node3D = model["root"]
	var teal := Color("2FD2B0")
	var disc: MeshInstance3D = BossModels.part(root, BossModels.pillar(5.0, 5.0, 0.35), Vector3(0.0, 1.3, 0.0), teal.darkened(0.25), 0.3)
	disc.scale = Vector3(1.0, 1.0, 0.8)
	for i in 5:
		BossModels.part(root, BossModels.cone(0.25, 3.0), Vector3(-3.0 + 1.5 * float(i), -0.2, 0.0), Color("167A66"), 0.0, Vector3(180.0, 0.0, 0.0))
	for i in 10:
		var a: float = TAU * float(i) / 10.0
		var base := Node3D.new()
		base.position = Vector3(cos(a) * 3.6, 1.45, sin(a) * 2.8)
		base.rotation = Vector3(0.0, -a, 0.0)
		root.add_child(base)
		var petal: Node3D = BossModels.pivot(model, base, Vector3.ZERO, Vector3(0.0, 0.0, 5.0), Vector3(0.0, 0.0, 62.0))
		BossModels.part(petal, BossModels.box(Vector3(1.5, 0.12, 0.8)), Vector3(0.75, 0.0, 0.0), teal.lightened(0.15), 0.6, Vector3.ZERO, 0.85)
	model["core"] = BossModels.part(root, BossModels.sphere(0.9), Vector3(0.0, 2.0, 0.0), tint, 2.0)


static func zefrion(model: Dictionary, tint: Color) -> void:
	var root: Node3D = model["root"]
	var gold := Color("F2C879")
	BossModels.part(root, BossModels.pillar(0.12, 0.2, 5.0), Vector3(0.0, 2.5, 0.0), Color("8A6A38"))
	var head := Node3D.new()
	head.position = Vector3(0.0, 6.0, 0.0)
	root.add_child(head)
	for i in 14:
		var arm := Node3D.new()
		arm.rotation_degrees = Vector3(0.0, 0.0, 360.0 * float(i) / 14.0)
		head.add_child(arm)
		var spoke: Node3D = BossModels.pivot(model, arm, Vector3.ZERO, Vector3(1.0, 0.55, 1.0), Vector3(1.0, 1.25, 1.0), &"scale")
		BossModels.part(spoke, BossModels.pillar(0.03, 0.03, 3.0), Vector3(0.0, 1.5, 0.0), gold, 0.8)
		BossModels.part(spoke, BossModels.sphere(0.28), Vector3(0.0, 3.0, 0.0), Color("FFF3C4"), 1.8)
	model["core"] = BossModels.part(head, BossModels.sphere(0.8), Vector3.ZERO, tint, 2.0)


static func necryon(model: Dictionary, tint: Color) -> void:
	var root: Node3D = model["root"]
	var magenta := Color("7A1F6B")
	BossModels.part(root, BossModels.pillar(0.8, 1.6, 5.0), Vector3(0.0, 2.5, 0.0), magenta.darkened(0.4))
	var bloom := Node3D.new()
	bloom.position = Vector3(0.0, 6.5, 0.0)
	root.add_child(bloom)
	for i in 10:
		var arm := Node3D.new()
		arm.rotation_degrees = Vector3(0.0, 0.0, 36.0 * float(i))
		bloom.add_child(arm)
		var petal: Node3D = BossModels.pivot(model, arm, Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, 0.0), Vector3(-14.0, 0.0, 0.0))
		BossModels.part(petal, BossModels.cone(0.9, 4.0), Vector3(0.0, 2.0, 0.0), magenta, 0.5, Vector3(180.0, 0.0, 0.0))
	var ring_holder: Node3D = BossModels.pivot(model, bloom, Vector3.ZERO, Vector3(1.0, 1.0, 1.0), Vector3(1.5, 1.5, 1.5), &"scale")
	var torus := TorusMesh.new()
	torus.outer_radius = 2.2
	torus.inner_radius = 2.0
	torus.rings = 24
	torus.ring_segments = 8
	BossModels.part(ring_holder, torus, Vector3.ZERO, Color("FFE14A"), 2.2, Vector3(90.0, 0.0, 0.0))
	model["core"] = BossModels.part(bloom, BossModels.sphere(1.0), Vector3.ZERO, tint, 2.4)
