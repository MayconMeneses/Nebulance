class_name GraphicsApplier
extends RefCounted
## Aplica as configuracoes graficas ao viewport, ao limite de FPS, ao vsync e as luzes marcadas (grupo main_light).


static func apply(viewport: Viewport, settings: Dictionary, tree: SceneTree) -> Dictionary:
	var values: Dictionary = GraphicsProfile.values(settings["graphics_profile"])
	viewport.msaa_3d = values["msaa"]
	viewport.scaling_3d_scale = values["render_scale"]
	Engine.max_fps = settings["max_fps"]
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings["vsync"] else DisplayServer.VSYNC_DISABLED)
	Accessibility.set_from(settings)
	GraphicsProfile.particle_scale = values["particle_scale"] * Accessibility.particle_factor()
	for light in tree.get_nodes_in_group(&"main_light"):
		(light as Light3D).shadow_enabled = values["shadows"]
	return values
