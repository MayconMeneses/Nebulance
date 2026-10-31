extends RefCounted
## Configuracoes graficas (TC-039 parcial): perfis, persistencia propria, saneamento e aplicacao.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_profiles(out)
	_store(out)
	await _apply(tree, out)
	await _flow(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _profiles(out: Array) -> void:
	var low: Dictionary = GraphicsProfile.values("low")
	var high: Dictionary = GraphicsProfile.values("high")
	TestWorld.rec(out, "TC-039 perfis: Baixo e mais leve que Alto em todos os controles",
			low["msaa"] < high["msaa"] and low["render_scale"] < high["render_scale"] and low["particle_scale"] < high["particle_scale"]
			and low["shadows"] == false and high["shadows"] == true)
	TestWorld.rec(out, "perfis: id desconhecido cai no Medio", GraphicsProfile.values("xyz") == GraphicsProfile.values("medium"))


func _store(out: Array) -> void:
	var dir: String = TmpDir.fresh("cfg")
	var s := SettingsStore.new(dir + "/settings.json")
	TestWorld.rec(out, "settings: arquivo ausente -> padrao (Medio, sem limite, vsync)", not s.load_settings() and s.data == SettingsStore.defaults())
	s.data["graphics_profile"] = "high"
	s.data["max_fps"] = 60
	s.data["vsync"] = false
	TestWorld.rec(out, "settings: grava", s.save_settings() == OK)
	var again := SettingsStore.new(dir + "/settings.json")
	TestWorld.rec(out, "settings: ida e volta preserva perfil, FPS e vsync",
			again.load_settings() and again.data["graphics_profile"] == "high" and again.data["max_fps"] == 60 and again.data["vsync"] == false)
	TmpDir.write(dir + "/settings.json", "{ nao e json")
	TestWorld.rec(out, "settings: arquivo corrompido -> padrao sem travar", not again.load_settings() and again.data == SettingsStore.defaults())
	TmpDir.write(dir + "/settings.json", JSON.stringify({"graphics_profile": "ultra", "max_fps": 77, "vsync": "sim", "extra": 1}))
	again.load_settings()
	TestWorld.rec(out, "settings: valores invalidos e chaves desconhecidas voltam ao padrao", again.data == SettingsStore.defaults())
	TmpDir.write(dir + "/settings.json", JSON.stringify({"graphics_profile": "low", "max_fps": 30.0, "vsync": true}))
	again.load_settings()
	TestWorld.rec(out, "settings: valores validos sao aproveitados individualmente (30.0 vira 30)",
			again.data["graphics_profile"] == "low" and again.data["max_fps"] == 30)


func _apply(tree: SceneTree, out: Array) -> void:
	var light := DirectionalLight3D.new()
	light.add_to_group(&"main_light")
	tree.get_root().add_child(light)
	var settings: Dictionary = SettingsStore.defaults()
	for id in GraphicsProfile.IDS:
		settings["graphics_profile"] = id
		var values: Dictionary = GraphicsApplier.apply(tree.get_root(), settings, tree)
		var ok: bool = tree.get_root().msaa_3d == values["msaa"] and is_equal_approx(tree.get_root().scaling_3d_scale, values["render_scale"]) \
				and light.shadow_enabled == values["shadows"] and is_equal_approx(GraphicsProfile.particle_scale, values["particle_scale"])
		TestWorld.rec(out, "TC-039 perfil %s: aplica MSAA, escala, sombras e particulas" % GraphicsProfile.label(id), ok)
	settings["max_fps"] = 60
	GraphicsApplier.apply(tree.get_root(), settings, tree)
	TestWorld.rec(out, "settings: limite de FPS aplicado ao motor", Engine.max_fps == 60)
	settings["max_fps"] = 0
	settings["graphics_profile"] = "medium"
	GraphicsApplier.apply(tree.get_root(), settings, tree)
	TestWorld.rec(out, "settings: FPS 0 = sem limite", Engine.max_fps == 0)
	light.queue_free()


func _flow(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("flowcfg")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.show_settings()
	await tree.process_frame
	flow.settings_menu._profile.select(2)
	flow.settings_menu._profile.item_selected.emit(2)
	TestWorld.rec(out, "settings: escolher Alto na tela grava e aplica", SettingsStore.new(dir + "/settings.json").load_settings()
			and tree.get_root().msaa_3d == GraphicsProfile.values("high")["msaa"])
	flow.settings_menu.back_pressed.emit()
	await tree.process_frame
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	flow.level.completed.emit({"grade": 1, "pickup_coins": 0, "chest_coins": 0, "upgraded": false, "new_items": [], "new_memories": []})
	await tree.process_frame
	flow.results.continue_pressed.emit()
	await tree.process_frame
	await tree.process_frame
	flow.map.back_pressed.emit()
	await tree.process_frame
	await tree.process_frame
	flow.menu.new_game_pressed.emit()
	await tree.process_frame
	TestWorld.rec(out, "settings: Nova Aventura NAO reseta as configuracoes (arquivo separado do save)",
			flow.settings.data["graphics_profile"] == "high" and SettingsStore.new(dir + "/settings.json").load_settings())
	tree.paused = false
	flow.queue_free()
	await tree.process_frame
	GraphicsApplier.apply(tree.get_root(), SettingsStore.defaults(), tree)
