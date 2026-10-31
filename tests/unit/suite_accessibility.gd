extends RefCounted
## Acessibilidade (RNF-003): reduzir movimento e flashes. Persistencia, aplicacao e efeito observavel.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_store(out)
	_apply(tree, out)
	await _flower(tree, out)
	await _menu(tree, out)
	Accessibility.set_from({})
	GraphicsApplier.apply(tree.get_root(), SettingsStore.defaults(), tree)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _store(out: Array) -> void:
	var dir: String = TmpDir.fresh("acc")
	var s := SettingsStore.new(dir + "/s.json")
	TestWorld.rec(out, "acessibilidade: padrao desligado", not SettingsStore.defaults()["reduce_motion"] and not SettingsStore.defaults()["reduce_flashing"])
	s.load_settings()
	s.data["reduce_motion"] = true
	s.save_settings()
	var s2 := SettingsStore.new(dir + "/s.json")
	s2.load_settings()
	TestWorld.rec(out, "acessibilidade: opcao sobrevive ao recarregar", s2.data["reduce_motion"] == true and s2.data["reduce_flashing"] == false)
	var f := FileAccess.open(dir + "/s.json", FileAccess.WRITE)
	f.store_string('{"version":1,"reduce_motion":"sim","reduce_flashing":1}')
	f.close()
	var s3 := SettingsStore.new(dir + "/s.json")
	s3.load_settings()
	TestWorld.rec(out, "acessibilidade: valor de tipo errado no arquivo volta ao padrao", s3.data["reduce_motion"] == false and s3.data["reduce_flashing"] == false)


func _apply(tree: SceneTree, out: Array) -> void:
	var base: Dictionary = SettingsStore.defaults()
	GraphicsApplier.apply(tree.get_root(), base, tree)
	var normal: float = GraphicsProfile.particle_scale
	base["reduce_motion"] = true
	GraphicsApplier.apply(tree.get_root(), base, tree)
	TestWorld.rec(out, "reduzir movimento: particulas caem para 1/4 da escala do perfil", Accessibility.reduce_motion
			and is_equal_approx(GraphicsProfile.particle_scale, normal * 0.25) and not Accessibility.reduce_flashing)
	base["reduce_motion"] = false
	GraphicsApplier.apply(tree.get_root(), base, tree)
	TestWorld.rec(out, "reduzir movimento: desligar restaura a escala", is_equal_approx(GraphicsProfile.particle_scale, normal))


func _flower(tree: SceneTree, out: Array) -> void:
	var fake := FlowerCandidate.new()
	tree.get_root().add_child(fake)
	await tree.process_frame
	var colors: Array = []
	for t in [0.0, 0.31, 0.62, 0.93]:
		fake.elapsed = t
		fake._paint()
		colors.append(fake._material.albedo_color)
	TestWorld.rec(out, "flashes (padrao): a ilusao alterna de cor", colors[0] != colors[1])
	Accessibility.set_from({"reduce_flashing": true})
	colors.clear()
	for t in [0.0, 0.31, 0.62, 0.93]:
		fake.elapsed = t
		fake._paint()
		colors.append(fake._material.albedo_color)
	TestWorld.rec(out, "reduzir flashes: a ilusao fica com cor constante", colors[0] == colors[1] and colors[1] == colors[2] and colors[2] == colors[3])
	var illusion_color: Color = colors[0]
	fake.is_real = true
	fake._paint()
	TestWorld.rec(out, "reduzir flashes: a flor real continua distinguivel da ilusao", fake._material.albedo_color != illusion_color
			and fake.steady() and fake._material.emission_energy_multiplier > 0.9)
	fake.is_real = false
	fake.elapsed = 0.31
	TestWorld.rec(out, "reduzir flashes: a regra de jogo (steady) nao muda", not fake.steady())
	Accessibility.set_from({})
	fake.queue_free()
	await tree.process_frame


func _menu(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("accmenu")
	var store := SettingsStore.new(dir + "/s.json")
	store.load_settings()
	var menu := SettingsMenu.new()
	menu.setup(store)
	tree.get_root().add_child(menu)
	await tree.process_frame
	menu._motion.button_pressed = true
	menu._flashing.button_pressed = true
	var saved := SettingsStore.new(dir + "/s.json")
	saved.load_settings()
	TestWorld.rec(out, "menu: marcar as duas opcoes grava no arquivo", saved.data["reduce_motion"] == true and saved.data["reduce_flashing"] == true)
	menu.queue_free()
	await tree.process_frame
