class_name BossModelsA
extends RefCounted
## Vyrkan (planta carnivora de maxilas), Zythra (orquidea de cristal) e Ferrorraiz (cacto mecanico). Ver BossModels.


static func vyrkan(model: Dictionary, tint: Color) -> void:
	var root: Node3D = model["root"]
	var green := Color("245A33")
	var red := Color("B02A2A")
	BossModels.part(root, BossModels.pillar(0.6, 1.2, 3.4), Vector3(0.0, 1.7, 0.0), green)
	for i in 5:
		var a: float = deg_to_rad(-70.0 + 35.0 * float(i))
		BossModels.part(root, BossModels.cone(0.35, 2.6), Vector3(sin(a) * 1.8, 0.35, 0.0), green, 0.0, Vector3(0.0, 0.0, -rad_to_deg(a) + 90.0 * signf(a) if a != 0.0 else 0.0))
	var head := Node3D.new()
	head.position = Vector3(0.0, 3.6, 0.0)
	root.add_child(head)
	var upper: Node3D = BossModels.pivot(model, head, Vector3.ZERO, Vector3.ZERO, Vector3(-40.0, 0.0, 0.0))
	BossModels.part(upper, BossModels.sphere(1.0), Vector3(0.0, 0.55, 0.7), red).scale = Vector3(1.9, 0.6, 1.2)
	var lower: Node3D = BossModels.pivot(model, head, Vector3.ZERO, Vector3.ZERO, Vector3(26.0, 0.0, 0.0))
	BossModels.part(lower, BossModels.sphere(1.0), Vector3(0.0, -0.5, 0.7), red.darkened(0.2)).scale = Vector3(1.8, 0.5, 1.1)
	for i in 6:
		var x: float = -1.5 + 0.6 * float(i)
		BossModels.part(upper, BossModels.cone(0.13, 0.55), Vector3(x, 0.1, 1.55), Color("F2EEDC"), 0.0, Vector3(180.0, 0.0, 0.0))
		BossModels.part(lower, BossModels.cone(0.13, 0.5), Vector3(x + 0.3, -0.15, 1.5), Color("F2EEDC"))
	for x in [-0.8, 0.8]:
		BossModels.part(upper, BossModels.sphere(0.24), Vector3(x, 1.0, 1.35), Color("FFE14A"), 2.0)
	model["core"] = BossModels.part(head, BossModels.sphere(0.6), Vector3(0.0, 0.0, 0.8), tint, 1.6)


static func zythra(model: Dictionary, tint: Color) -> void:
	var root: Node3D = model["root"]
	var violet := Color("8B5CF6")
	for i in 3:
		BossModels.part(root, BossModels.cone(0.4, 2.8), Vector3(-1.2 + 1.2 * float(i), 1.0, 0.0), violet.darkened(0.3), 0.4, Vector3(0.0, 0.0, 10.0 - 10.0 * float(i)), 0.8)
	var bloom := Node3D.new()
	bloom.position = Vector3(0.0, 4.2, 0.0)
	root.add_child(bloom)
	for i in 8:
		var arm := Node3D.new()
		arm.rotation_degrees = Vector3(0.0, 0.0, 45.0 * float(i))
		bloom.add_child(arm)
		var p: Node3D = BossModels.pivot(model, arm, Vector3(0.0, 1.2, 0.0), Vector3(1.0, 0.6, 1.0), Vector3(1.0, 1.25, 1.0), &"scale")
		BossModels.part(p, BossModels.box(Vector3(0.7, 2.4, 0.14)), Vector3(0.0, 1.2, 0.0), violet.lightened(0.2), 0.8, Vector3.ZERO, 0.6)
	model["core"] = BossModels.part(bloom, BossModels.sphere(0.9), Vector3.ZERO, tint, 2.0)


static func ferrorraiz(model: Dictionary, tint: Color) -> void:
	var root: Node3D = model["root"]
	var steel := Color("5B6470")
	for i in 4:
		BossModels.part(root, BossModels.box(Vector3(1.7, 1.15, 1.7)), Vector3(0.0, 0.6 + 1.2 * float(i), 0.0), steel.darkened(0.1 * float(i)))
		BossModels.part(root, BossModels.box(Vector3(1.78, 0.12, 1.78)), Vector3(0.0, 1.2 + 1.2 * float(i), 0.0), Color("F08A3B"), 1.4)
	for side in [-1.0, 1.0]:
		BossModels.part(root, BossModels.box(Vector3(1.6, 0.6, 0.6)), Vector3(side * 1.6, 2.4, 0.0), steel)
		BossModels.part(root, BossModels.box(Vector3(0.6, 1.8, 0.6)), Vector3(side * 2.2, 3.1, 0.0), steel)
	for i in 14:
		var a: float = TAU * float(i) / 14.0
		var holder := Node3D.new()
		holder.position = Vector3(cos(a) * 0.95, 0.6 + 0.3 * float(i % 4) * 1.1, sin(a) * 0.95)
		holder.rotation = Vector3(0.0, -a, deg_to_rad(-90.0))
		root.add_child(holder)
		var spike: Node3D = BossModels.pivot(model, holder, Vector3.ZERO, Vector3(1.0, 0.25, 1.0), Vector3(1.0, 1.3, 1.0), &"scale")
		BossModels.part(spike, BossModels.cone(0.14, 0.9), Vector3(0.0, 0.45, 0.0), Color("D9DEE5"))
	model["core"] = BossModels.part(root, BossModels.sphere(0.55), Vector3(0.0, 3.4, 0.9), tint, 2.2)
