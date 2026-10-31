extends RefCounted
## Visual 3D dos herois: modelos, esqueleto, clipes (contrato), orcamento, separacao da fisica, estados e giro.

const HEROES: Array[String] = ["rocco", "zuri", "pipa"]
const CLIPS: Array[String] = ["idle", "run", "jump", "fall", "land", "special", "hurt", "celebrate"]
const LOOPING: Array[String] = ["idle", "run", "celebrate"]
const MAX_TRIANGLES: int = 4000
const MAX_MATERIALS: int = 12


func run(tree: SceneTree) -> Array:
	var out: Array = []
	for hero in HEROES:
		await _model(tree, hero, out)
	await _visual_node(tree, out)
	await _swap_and_facing(tree, out)
	return out


func _model(tree: SceneTree, hero: String, out: Array) -> void:
	var path: String = "res://assets/models/%s.glb" % hero
	var packed: PackedScene = load(path)
	TestWorld.rec(out, "visual %s: modelo .glb importa" % hero, packed != null)
	if packed == null:
		return
	var holder := Node3D.new()
	tree.get_root().add_child(holder)
	var model: Node3D = packed.instantiate()
	holder.add_child(model)
	await tree.process_frame
	var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
	TestWorld.rec(out, "visual %s: esqueleto com 11 ossos" % hero, skeleton != null and skeleton.get_bone_count() == 11)
	var ap := model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	var all_clips: bool = ap != null
	for clip in CLIPS:
		all_clips = all_clips and ap != null and ap.has_animation(clip)
	TestWorld.rec(out, "visual %s: os 8 clipes do contrato existem" % hero, all_clips)
	var loops_ok: bool = ap != null
	for clip in CLIPS:
		if ap != null and ap.has_animation(clip):
			loops_ok = loops_ok and ((ap.get_animation(clip).loop_mode != Animation.LOOP_NONE) == (clip in LOOPING))
	TestWorld.rec(out, "visual %s: so idle/run/celebrate fazem laco" % hero, loops_ok)
	var tris: int = 0
	var mats: Dictionary = {}
	var aabb := AABB()
	var first: bool = true
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		for s in mi.mesh.get_surface_count():
			tris += mi.mesh.surface_get_arrays(s)[Mesh.ARRAY_INDEX].size() / 3
			mats[mi.mesh.surface_get_material(s).resource_name] = true
		var box: AABB = mi.global_transform * mi.get_aabb()
		aabb = box if first else aabb.merge(box)
		first = false
	TestWorld.rec(out, "visual %s: orcamento de triangulos (<= %d)" % [hero, MAX_TRIANGLES], tris <= MAX_TRIANGLES, "(%d)" % tris)
	TestWorld.rec(out, "visual %s: materiais compartilhados (<= %d)" % [hero, MAX_MATERIALS], mats.size() <= MAX_MATERIALS, "(%d)" % mats.size())
	var profile: HeroProfile = load("res://game/actors/data/%s.tres" % hero) as HeroProfile
	var height_ok: bool = aabb.size.y >= profile.capsule_height * 0.9 and aabb.size.y <= profile.capsule_height * 1.25
	TestWorld.rec(out, "visual %s: altura do modelo cabe na capsula de colisao" % hero, height_ok,
			"(modelo=%.2f capsula=%.2f)" % [aabb.size.y, profile.capsule_height])
	TestWorld.rec(out, "visual %s: pes no chao (base do modelo em y~0)" % hero, absf(aabb.position.y) < 0.05, "(y=%.3f)" % aabb.position.y)
	TestWorld.rec(out, "visual %s: largura compativel com a capsula" % hero,
			aabb.size.x <= profile.capsule_radius * 2.0 * 2.2 and aabb.size.z <= profile.capsule_radius * 2.0 * 1.9,
			"(x=%.2f z=%.2f)" % [aabb.size.x, aabb.size.z])
	TestWorld.rec(out, "visual %s: modelo nao tem colisao (so visual)" % hero, model.find_children("*", "CollisionObject3D", true, false).is_empty())
	holder.queue_free()


func _visual_node(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	var visual := HeroVisual.new()
	w.body.add_child(visual)
	visual.bind(w.body, w.rig)
	await w.step(5)
	TestWorld.rec(out, "visual: usa o modelo real (sem fallback) para os 3 herois", not visual.uses_fallback)
	var states_ok: bool = true
	for state in MovementState.State.values():
		for hero_idx in 3:
			w.rig.request_swap(hero_idx)
			await w.step(1)
			var clip: StringName = HeroVisual.STATE_CLIPS.get(state, &"")
			states_ok = states_ok and clip != &"" and visual.has_clip(clip)
	TestWorld.rec(out, "visual: todo MovementState mapeia para um clipe existente em todos os herois", states_ok)
	w.rig.request_swap(0)
	await w.step(2)
	visual.set_state(MovementState.State.RUN)
	TestWorld.rec(out, "visual: estado RUN toca o clipe run", visual.current_clip == &"run")
	visual.set_state(MovementState.State.HURT)
	TestWorld.rec(out, "visual: estado HURT toca o clipe hurt", visual.current_clip == &"hurt")
	TestWorld.rec(out, "visual: pes alinhados com a base da capsula",
			is_equal_approx(visual.position.y, -(w.body.collision_shape.shape as CapsuleShape3D).height * 0.5))
	w.dispose()


func _swap_and_facing(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	var visual := HeroVisual.new()
	w.body.add_child(visual)
	visual.bind(w.body, w.rig)
	await w.step(3)
	w.rig.request_swap(1)
	TestWorld.rec(out, "visual: trocar de heroi troca o modelo", visual.hero_id == &"zuri")
	w.rig.request_swap(2)
	TestWorld.rec(out, "visual: trocar de heroi troca o modelo (Pipa)", visual.hero_id == &"pipa")
	w.body.facing = -1.0
	await w.step(40)
	TestWorld.rec(out, "visual: virar para a esquerda gira 180 graus em Y", absf(absf(visual.rotation.y) - PI) < 0.05,
			"(y=%.2f)" % visual.rotation.y)
	TestWorld.rec(out, "visual: nunca espelha por escala negativa", visual.scale == Vector3.ONE and visual.model.scale.x > 0.0)
	w.body.facing = 1.0
	await w.step(40)
	TestWorld.rec(out, "visual: voltar a direita zera o giro", absf(visual.rotation.y) < 0.05)
	var hx: float = w.body.global_position.x
	await w.step(5)
	TestWorld.rec(out, "visual: nao altera a fisica (posicao estavel em repouso)", absf(w.body.global_position.x - hx) < 0.01)
	w.dispose()
