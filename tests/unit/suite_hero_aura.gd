extends RefCounted
## Luz e poeira do heroi (TC-074): a luz tem a cor do heroi ativo e troca junto; a poeira so aparece correndo no chao e respeita
## "reduzir movimento" e a escala de particulas; sem colisao.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _aura(tree, out)
	return out


func _aura(tree: SceneTree, out: Array) -> void:
	var level := SylvaraLevel01.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	await tree.process_frame
	var auras: Array = level.rig.body.get_children().filter(func(n: Node) -> bool: return n is HeroAura)
	var aura: HeroAura = auras[0] if auras.size() == 1 else null
	var rocco: Color = aura.light.light_color if aura != null else Color.BLACK
	level.rig.request_swap(1)
	await tree.process_frame
	var zuri: Color = aura.light.light_color
	level.rig.request_swap(2)
	await tree.process_frame
	var pipa: Color = aura.light.light_color
	TestWorld.rec(out, "TC-074 heroi: cada heroi tem sua luz (laranja, verde-agua, azul) que troca com o heroi ativo, sem sombra e sem colisao",
			aura != null and rocco == HeroAura.COLORS[&"rocco"] and zuri == HeroAura.COLORS[&"zuri"] and pipa == HeroAura.COLORS[&"pipa"]
			and not aura.light.shadow_enabled and aura.find_children("*", "CollisionObject3D", true, false).is_empty())
	var old_scale: float = GraphicsProfile.particle_scale
	var old_reduce: bool = Accessibility.reduce_motion
	GraphicsProfile.particle_scale = 1.0
	Accessibility.reduce_motion = false
	var running: bool = HeroAura.dust_active(5.0, true)
	var standing: bool = HeroAura.dust_active(0.5, true)
	var flying: bool = HeroAura.dust_active(5.0, false)
	Accessibility.reduce_motion = true
	var calm: bool = HeroAura.dust_active(5.0, true)
	Accessibility.reduce_motion = false
	GraphicsProfile.particle_scale = 0.0
	var no_particles: bool = HeroAura.dust_active(5.0, true)
	GraphicsProfile.particle_scale = old_scale
	Accessibility.reduce_motion = old_reduce
	TestWorld.rec(out, "TC-074 heroi: poeira so correndo no chao; parado, no ar, com 'reduzir movimento' ou com particulas desligadas nao aparece",
			running and not standing and not flying and not calm and not no_particles)
	level.queue_free()
	await tree.process_frame
