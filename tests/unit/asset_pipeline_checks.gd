extends RefCounted
## Checagens do pipeline de ferramentas (PDF 15.8, ordem 01-04):
## Blender->.glb, Krita->PNG com transparencia, audio no bus SFX.
## Retorna lista de [nome, ok, detalhe]; o runner imprime e conta falhas.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_check_glb(out)
	_check_png(out)
	await _check_audio(tree, out)
	return out


func _check_glb(out: Array) -> void:
	var packed: PackedScene = load("res://assets/models/test_cube.glb")
	out.append(["glb_imports_as_scene", packed != null, ""])
	if packed == null:
		return
	var root: Node = packed.instantiate()
	var meshes: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
	out.append(["glb_has_mesh", meshes.size() == 1, "(meshes=%d)" % meshes.size()])
	if meshes.size() == 1:
		var size: Vector3 = (meshes[0] as MeshInstance3D).get_aabb().size
		out.append(["glb_scale_is_1_unit", size.is_equal_approx(Vector3.ONE), "(aabb=%s)" % size])
	root.free()


func _check_png(out: Array) -> void:
	var tex: Texture2D = load("res://assets/textures/test_icon.png")
	out.append(["png_imports_as_texture", tex != null, ""])
	if tex == null:
		return
	var img: Image = tex.get_image()
	out.append(["png_has_alpha_channel", img.detect_alpha() != Image.ALPHA_NONE, ""])
	out.append(["png_corner_transparent", is_zero_approx(img.get_pixel(0, 0).a), ""])
	out.append(["png_center_opaque", is_equal_approx(img.get_pixel(16, 16).a, 1.0), ""])


func _check_audio(tree: SceneTree, out: Array) -> void:
	var bus_idx: int = AudioServer.get_bus_index(&"SFX")
	out.append(["audio_bus_sfx_exists", bus_idx >= 0, ""])
	var stream: AudioStream = load("res://assets/audio/test_sfx.wav")
	out.append(["wav_imports_as_stream", stream != null, ""])
	if stream == null or bus_idx < 0:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = &"SFX"
	tree.get_root().add_child(player)
	player.play()
	await tree.process_frame
	out.append(["wav_plays_on_sfx_bus", player.playing and player.bus == &"SFX", ""])
	player.queue_free()
