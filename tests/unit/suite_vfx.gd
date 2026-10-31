extends RefCounted
## Efeitos: quantidade por perfil, escala 0, limpeza e integracao com o jogo (sem alterar gameplay).


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _scaling(tree, out)
	await _integration(tree, out)
	GraphicsProfile.particle_scale = 1.0
	return out


func _amount_for(tree: SceneTree, profile: String) -> int:
	GraphicsProfile.particle_scale = GraphicsProfile.values(profile)["particle_scale"]
	var fx := EffectsDirector.new()
	tree.get_root().add_child(fx)
	var p: CPUParticles3D = fx.burst(&"chest", Vector3.ZERO)
	var n: int = p.amount if p != null else 0
	fx.queue_free()
	return n


func _scaling(tree: SceneTree, out: Array) -> void:
	var low: int = await _amount_for(tree, "low")
	var medium: int = await _amount_for(tree, "medium")
	var high: int = await _amount_for(tree, "high")
	TestWorld.rec(out, "vfx: quantidade de particulas cresce com o perfil (Baixo < Medio < Alto)", low < medium and medium < high,
			"(%d < %d < %d)" % [low, medium, high])
	GraphicsProfile.particle_scale = 0.0
	var fx := EffectsDirector.new()
	tree.get_root().add_child(fx)
	TestWorld.rec(out, "vfx: escala 0 desliga os efeitos (nenhum no criado)", fx.burst(&"coin", Vector3.ZERO) == null and fx.get_child_count() == 0)
	GraphicsProfile.particle_scale = 1.0
	TestWorld.rec(out, "vfx: tipo desconhecido e ignorado", fx.burst(&"inexistente", Vector3.ZERO) == null)
	var p: CPUParticles3D = fx.burst(&"coin", Vector3.ZERO)
	TestWorld.rec(out, "vfx: efeito ativo e unico disparo", p != null and p.one_shot and fx.active == 1)
	for i in 80:
		await tree.process_frame
	TestWorld.rec(out, "vfx: efeito termina e e liberado (sem vazamento de nos)", fx.active == 0 and fx.get_child_count() == 0,
			"(ativos=%d filhos=%d)" % [fx.active, fx.get_child_count()])
	fx.queue_free()


func _integration(tree: SceneTree, out: Array) -> void:
	GraphicsProfile.particle_scale = 1.0
	var level := SylvaraLevel01.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	await tree.physics_frame
	var fx: EffectsDirector = level.effects
	TestWorld.rec(out, "vfx: a fase tem o diretor de efeitos ligado", fx != null)
	var before: int = fx.spawned_total
	level.rig.body.global_position = Vector3(4, 1, 0)
	level.rig.body.velocity = Vector3.ZERO
	for i in 4:
		await tree.physics_frame
	TestWorld.rec(out, "vfx: coletar uma moeda dispara o efeito de moeda", fx.spawned_total > before)
	level.queue_free()
