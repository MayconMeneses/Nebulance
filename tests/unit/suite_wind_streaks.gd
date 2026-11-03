extends RefCounted
## Sinalizacao visual do vento (faixas de particulas): so sopram quando a corrente sopra, seguem a direcao do vento e respeitam o perfil grafico
## e a opcao de reduzir movimento. Puramente visual: o empurrao (wind_push) continua o mesmo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	var saved_scale: float = GraphicsProfile.particle_scale
	await _states(tree, out)
	await _settings(tree, out)
	GraphicsProfile.particle_scale = saved_scale
	return out


func _vent(tree: SceneTree, wind: Vector3, control: Mechanism = null) -> WindVent:
	var v := WindVent.new()
	v.wind_on = wind
	v.control = control
	tree.get_root().add_child(v)
	return v


func _states(tree: SceneTree, out: Array) -> void:
	GraphicsProfile.particle_scale = 1.0
	var panel := Mechanism.new()
	tree.get_root().add_child(panel)
	var vent: WindVent = _vent(tree, Vector3(40.0, 0.0, 0.0), panel)
	await tree.physics_frame
	TestWorld.rec(out, "vento visual: corrente desligada (painel inativo) nao emite faixas e nao empurra",
			not vent.streaks.emitting and vent.wind_push == Vector3.ZERO)
	panel.is_active = true
	await tree.physics_frame
	TestWorld.rec(out, "vento visual: painel ligado -> a corrente sopra e as faixas aparecem",
			vent.streaks.emitting and vent.wind_push == Vector3(40.0, 0.0, 0.0))
	TestWorld.rec(out, "vento visual: faixas seguem a direcao do vento (horizontal +x; vertical +y)",
			vent.streaks.direction.is_equal_approx(Vector3.RIGHT) and _vent(tree, Vector3(0.0, 23.0, 0.0)).streaks.direction.is_equal_approx(Vector3.UP))
	panel.is_active = false
	await tree.physics_frame
	TestWorld.rec(out, "vento visual: desligar o painel para as faixas de novo", not vent.streaks.emitting)
	vent.queue_free()
	panel.queue_free()


func _settings(tree: SceneTree, out: Array) -> void:
	GraphicsProfile.particle_scale = 1.0
	var full: int = _vent(tree, Vector3(40.0, 0.0, 0.0)).streaks.amount
	Accessibility.reduce_motion = true
	GraphicsApplier.apply(tree.get_root(), SettingsStore.defaults().merged({"reduce_motion": true}, true), tree)
	var reduced: int = _vent(tree, Vector3(40.0, 0.0, 0.0)).streaks.amount
	Accessibility.reduce_motion = false
	GraphicsProfile.particle_scale = 0.0
	var off: WindVent = _vent(tree, Vector3(40.0, 0.0, 0.0))
	await tree.physics_frame
	TestWorld.rec(out, "vento visual: reduzir movimento diminui as faixas; escala de particulas 0 as desliga (o vento continua empurrando)",
			reduced < full and not off.streaks.emitting and off.wind_push == Vector3(40.0, 0.0, 0.0), "(cheio=%d reduzido=%d)" % [full, reduced])
	Accessibility.set_from({})
	for v in tree.get_root().find_children("*", "WindVent", true, false):
		v.queue_free()
	await tree.process_frame
