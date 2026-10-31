extends SceneTree
## Inspeciona um .glb importado: nos, esqueleto, clipes, triangulos, AABB e materiais.
## Uso: godot --headless --path . --script res://tools/inspect_model.gd -- res://assets/models/rocco.glb


func _initialize() -> void:
	var path: String = OS.get_cmdline_user_args()[0]
	var packed: PackedScene = load(path)
	if packed == null:
		print("INSPECT erro: nao carregou ", path)
		quit(1)
		return
	var root: Node = packed.instantiate()
	var skeletons: Array[Node] = root.find_children("*", "Skeleton3D", true, false)
	print("INSPECT skeletons=%d" % skeletons.size())
	if skeletons.size() > 0:
		var sk := skeletons[0] as Skeleton3D
		var names: PackedStringArray = []
		for i in sk.get_bone_count():
			names.append(sk.get_bone_name(i))
		print("INSPECT bones=%d %s" % [sk.get_bone_count(), ", ".join(names)])
	var players: Array[Node] = root.find_children("*", "AnimationPlayer", true, false)
	print("INSPECT animation_players=%d" % players.size())
	if players.size() > 0:
		var ap := players[0] as AnimationPlayer
		for clip in ap.get_animation_list():
			var a: Animation = ap.get_animation(clip)
			print("INSPECT clip=%s length=%.2f tracks=%d loop=%d" % [clip, a.length, a.get_track_count(), a.loop_mode])
	var tris: int = 0
	var mats: Dictionary = {}
	var aabb := AABB()
	var first: bool = true
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var mesh: Mesh = mi.mesh
		for s in mesh.get_surface_count():
			tris += mesh.surface_get_arrays(s)[Mesh.ARRAY_INDEX].size() / 3
			var m: Material = mesh.surface_get_material(s)
			if m != null:
				mats[m.resource_name] = true
		var local: AABB = mi.get_aabb()
		var world: AABB = mi.global_transform * local
		aabb = world if first else aabb.merge(world)
		first = false
	print("INSPECT meshes=%d triangles=%d materials=%d" % [root.find_children("*", "MeshInstance3D", true, false).size(), tris, mats.size()])
	print("INSPECT aabb pos=%s size=%s" % [aabb.position, aabb.size])
	quit(0)
