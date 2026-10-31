extends RefCounted
## Smoke da cena jogavel: carrega, monta o trio e o heroi pousa no piso sem erros.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	var packed: PackedScene = load("res://tests/scenes/playground.tscn")
	TestWorld.rec(out, "playground: cena carrega", packed != null)
	if packed == null:
		return out
	var scene: Node = packed.instantiate()
	tree.get_root().add_child(scene)
	for i in 90:
		await tree.physics_frame
	var rig: TrioRig = scene.get("rig") as TrioRig
	TestWorld.rec(out, "playground: trio montado", rig != null and rig.body != null)
	if rig != null:
		TestWorld.rec(out, "playground: heroi pousa no piso", rig.body.is_on_floor(), "(y=%.2f)" % rig.body.global_position.y)
		TestWorld.rec(out, "playground: Rocco ativo no inicio", rig.body.profile.hero_id == &"rocco")
		TestWorld.rec(out, "playground: vidas e coracoes iniciais", rig.vitals.lives == 5 and rig.vitals.hearts == 3)
	scene.queue_free()
	return out
