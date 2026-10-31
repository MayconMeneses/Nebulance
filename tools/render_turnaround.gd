extends SceneTree
## Gera renders de conferencia (frente, lado, costas, 3/4) de um modelo, NA ENGINE (janela real, nao headless).
## Uso: godot --path . --script res://tools/render_turnaround.gd -- <heroi> [clipe] [altura_alvo]
## Saida: docs/visual/<heroi>_<vista>.png (renders proprios, para validacao visual).

const VIEWS: Dictionary = {
	"frente": Vector3(1.0, 0.0, 0.0),
	"lado": Vector3(0.0, 0.0, 1.0),
	"costas": Vector3(-1.0, 0.0, 0.0),
	"tres_quartos": Vector3(0.7, 0.0, 0.7),
}


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var hero: String = args[0]
	var clip: String = args[1] if args.size() > 1 else "idle"
	var height: float = float(args[2]) if args.size() > 2 else 1.8
	var viewport := SubViewport.new()
	viewport.size = Vector2i(640, 800)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var world := Node3D.new()
	viewport.add_child(world)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("2B3548")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("A9C7D6")
	env.ambient_light_energy = 0.8
	var we := WorldEnvironment.new()
	we.environment = env
	world.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40.0, 35.0, 0.0)
	world.add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20.0, -140.0, 0.0)
	fill.light_energy = 0.5
	world.add_child(fill)
	var model: Node3D = (load("res://assets/models/%s.glb" % hero) as PackedScene).instantiate()
	world.add_child(model)
	var ap := model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if ap != null and ap.has_animation(clip):
		ap.play(clip)
		ap.seek(0.2, true)
		ap.pause()
	var cam := Camera3D.new()
	cam.fov = 24.0
	world.add_child(cam)
	DirAccess.make_dir_recursive_absolute("res://docs/visual")
	var dist: float = height * 3.6
	for view_name in VIEWS:
		var dir: Vector3 = (VIEWS[view_name] as Vector3).normalized()
		cam.look_at_from_position(Vector3(0.0, height * 0.55, 0.0) + dir * dist, Vector3(0.0, height * 0.5, 0.0))
		for i in 3:
			await process_frame
		await RenderingServer.frame_post_draw
		var img: Image = viewport.get_texture().get_image()
		var out: String = ProjectSettings.globalize_path("res://docs/visual/%s_%s.png" % [hero, view_name])
		print("RENDER ", out, " ", img.save_png(out), " ", img.get_size())
	quit(0)
