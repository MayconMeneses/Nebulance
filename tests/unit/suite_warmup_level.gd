extends RefCounted
## TC-077 Aquecimento dos visuais da fase (LevelWarmup) e cache dos modelos dos herois (HeroVisual): evitam os picos de ~100-150 ms da
## primeira vez que algo e desenhado (shader do Compatibility) e do .glb instanciado a cada troca de heroi. Medido por benchmark em janela real;
## aqui se confere a ESTRUTURA: copias so visuais, deduplicadas, liberadas; modelos reaproveitados e escondidos.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	var level: LevelScene = LevelCatalog.make("sylvara_01")
	level.use_input_reader = false
	tree.get_root().add_child(level)
	await tree.physics_frame
	_copies(out, level)
	await _cache(out, tree, level)
	level.queue_free()
	await tree.process_frame
	return out


func _copies(out: Array, level: LevelScene) -> void:
	var meshes_before: int = level.find_children("*", "MeshInstance3D", true, false).size()
	var anchor: Vector3 = level.rig.body.global_position
	var temps: Array[Node] = LevelWarmup.spawn(level, anchor)
	temps.append_array(LevelWarmup.dust_copy(level, anchor))
	var visual_only: bool = true
	for t in temps:
		visual_only = visual_only and (t is MeshInstance3D or t is CPUParticles3D) and t.get_script() == null \
				and (t as Node).find_children("*", "CollisionObject3D", true, false).is_empty()
	TestWorld.rec(out, "TC-077 aquecimento da fase: so copias visuais (sem script nem colisao)", not temps.is_empty() and visual_only, "(%d copias)" % temps.size())
	TestWorld.rec(out, "TC-077 aquecimento da fase: deduplicado por material (bem menos copias que malhas da fase)", temps.size() < meshes_before / 2 and temps.size() >= 3,
			"(%d copias, %d malhas)" % [temps.size(), meshes_before])
	var shader_a: ShaderMaterial = FuturisticLook.panel(Vector3.ONE, Color.RED, Color.WHITE)
	var shader_b: ShaderMaterial = FuturisticLook.panel(Vector3(4, 1, 2), Color.BLUE, Color.GREEN, true)
	TestWorld.rec(out, "TC-077 aquecimento da fase: paineis com cores/tamanhos diferentes compartilham UMA assinatura (mesmo shader)",
			LevelWarmup.signature("BoxMesh", shader_a, 1) == LevelWarmup.signature("BoxMesh", shader_b, 1))
	var opaque := StandardMaterial3D.new()
	var alpha := StandardMaterial3D.new()
	alpha.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	TestWorld.rec(out, "TC-077 aquecimento da fase: material opaco e translucido tem assinaturas diferentes",
			LevelWarmup.signature("BoxMesh", opaque, 1) != LevelWarmup.signature("BoxMesh", alpha, 1))
	for t in temps:
		t.queue_free()


func _cache(out: Array, tree: SceneTree, level: LevelScene) -> void:
	var visual: HeroVisual = level.visual
	visual.preload_models(level.rig.profiles)
	var visible_models: int = 0
	var disabled_models: int = 0
	for child in visual.get_children():
		if child is Node3D and child.visible:
			visible_models += 1
		elif child is Node3D and child.process_mode == Node.PROCESS_MODE_DISABLED:
			disabled_models += 1
	TestWorld.rec(out, "TC-077 modelos dos herois: os 3 ficam prontos, so o ativo visivel (os outros escondidos e sem processar)", visible_models == 1 and disabled_models == 2,
			"(visiveis=%d desativados=%d)" % [visible_models, disabled_models])
	var first: Node3D = visual.model
	await _swap_to(tree, level, 1)
	var second: Node3D = visual.model
	await _swap_to(tree, level, 0)
	var back: Node3D = visual.model
	TestWorld.rec(out, "TC-077 modelos dos herois: trocar e voltar reaproveita o MESMO modelo (nao instancia de novo)", second != first and back == first and visual.get_child_count() == 3,
			"(filhos=%d)" % visual.get_child_count())
	TestWorld.rec(out, "TC-077 modelos dos herois: o modelo ativo e visivel, anima (idle) e o anterior fica escondido",
			back.visible and visual.player != null and visual.current_clip == &"idle" and not second.visible and second.process_mode == Node.PROCESS_MODE_DISABLED)


func _swap_to(tree: SceneTree, level: LevelScene, index: int) -> void:
	for i in 8:
		if level.rig.active_index == index:
			break
		level.rig.request_swap(index)
		for f in 20:
			await tree.physics_frame
