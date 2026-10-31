extends RefCounted
## Astralis: modelo, apresentacao (chegada) e "pular a qualquer momento" sem efeitos colaterais.

const MAX_TRIANGLES: int = 5000


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _model(tree, out)
	await _arrival(tree, out)
	return out


func _model(tree: SceneTree, out: Array) -> void:
	var packed: PackedScene = load("res://assets/models/astralis.glb")
	TestWorld.rec(out, "astralis: modelo .glb importa", packed != null)
	var holder := Node3D.new()
	tree.get_root().add_child(holder)
	var model: Node3D = packed.instantiate()
	holder.add_child(model)
	await tree.process_frame
	var tris: int = 0
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh: Mesh = (node as MeshInstance3D).mesh
		for s in mesh.get_surface_count():
			tris += mesh.surface_get_arrays(s)[Mesh.ARRAY_INDEX].size() / 3
	TestWorld.rec(out, "astralis: orcamento de triangulos (<= %d)" % MAX_TRIANGLES, tris <= MAX_TRIANGLES, "(%d)" % tris)
	var thrusters: int = 0
	for n in model.find_children("thruster_?", "", true, false):
		thrusters += 1
	TestWorld.rec(out, "astralis: tres propulsores e cockpit panoramico", thrusters == 3 and model.find_child("cockpit", true, false) != null)
	TestWorld.rec(out, "astralis: sem colisao (so visual) e sem armas", model.find_children("*", "CollisionObject3D", true, false).is_empty())
	holder.queue_free()


func _arrival(tree: SceneTree, out: Array) -> void:
	for skip_after in [0, 20, 300]:
		var view := AstralisView.new()
		tree.get_root().add_child(view)
		await tree.process_frame
		var heard := {"n": 0}
		view.arrived.connect(func() -> void: heard["n"] += 1)
		view.arrive(1.0)
		TestWorld.rec(out, "astralis: chegada comeca longe do ponto de pouso (skip em %d quadros)" % skip_after,
				view.is_arriving and view.position.distance_to(view.rest_position) > 10.0)
		for i in skip_after:
			await tree.process_frame
		view.skip()
		await tree.process_frame
		TestWorld.rec(out, "astralis: pular em %d quadros posiciona no pouso e emite arrived uma vez" % skip_after,
				view.position.is_equal_approx(view.rest_position) and heard["n"] == 1 and not view.is_arriving)
		view.skip()
		TestWorld.rec(out, "astralis: pular de novo nao tem efeito (idempotente)", heard["n"] == 1)
		view.queue_free()
	var full := AstralisView.new()
	tree.get_root().add_child(full)
	await tree.process_frame
	var n := {"v": 0}
	full.arrived.connect(func() -> void: n["v"] += 1)
	full.arrive(0.2)
	for i in 40:
		await tree.process_frame
	TestWorld.rec(out, "astralis: sem pular, a chegada termina sozinha no pouso", n["v"] == 1 and full.position.is_equal_approx(full.rest_position))
	full.queue_free()
