extends RefCounted
## Mapa Galactico em 3D (TC-068): seis planetas que giram, alinhados com os pontos 2D do mapa, pintados pelo estado derivado do save;
## "reduzir movimento" para o giro; o palco nao tem colisao. LIMITE: aparencia (cores, nuvens, brilho) conferida em janela real, nao aqui.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _stage(tree, out)
	return out


func _stage(tree: SceneTree, out: Array) -> void:
	var map := GalaxyMap.new()
	tree.get_root().add_child(map)
	var save: Dictionary = SaveData.new_game()
	var before: String = JSON.stringify(save)
	map.show_state(save)
	await tree.process_frame
	var stage: SpaceStage = map._stage
	TestWorld.rec(out, "TC-068 mapa 3D: o palco tem 6 planetas (um por planeta, na ordem do mapa) e tamanho fixo 1280x720 (sem isso o 3D nao aparece)",
			stage.planets.size() == 6 and stage.size == Vector2(1280.0, 720.0) and stage.viewport.size == Vector2i(1280, 720)
			and stage.planets[0].planet_id == &"sylvara" and stage.planets[5].planet_id == &"umbraxis")
	var aligned: bool = true
	for i in 6:
		aligned = aligned and stage.planets[i].position.is_equal_approx(SpaceStage.world_position(map._planet_pos(i)))
	TestWorld.rec(out, "TC-068 mapa 3D: cada planeta fica exatamente sob o ponto 2D do mapa (camera ortografica, 1 unidade = 1 pixel)",
			aligned and stage.camera.projection == Camera3D.PROJECTION_ORTHOGONAL and is_equal_approx(stage.camera.size, 720.0))
	map.set_qa_progress(3)
	await tree.process_frame
	var dims: Array[float] = []
	for i in 6:
		dims.append(float((stage.planets[i]._material as ShaderMaterial).get_shader_parameter("dim")))
	var corruption: float = float((stage.planets[3]._material as ShaderMaterial).get_shader_parameter("corruption"))
	TestWorld.rec(out, "TC-068 mapa 3D: o estado pinta os planetas (3 salvos brilhantes, o disponivel com corrupcao, os 2 bloqueados escuros)",
			dims[0] > 1.0 and dims[1] > 1.0 and dims[2] > 1.0 and is_equal_approx(dims[4], 0.3) and is_equal_approx(dims[5], 0.3) and corruption > 0.3 and stage.planets[0].status == 3)
	var start: float = stage.planets[1].spin_angle()
	for i in 20:
		await tree.process_frame
	var moved: bool = not is_equal_approx(stage.planets[1].spin_angle(), start)
	var old_reduce: bool = Accessibility.reduce_motion
	Accessibility.reduce_motion = true
	var frozen_start: float = stage.planets[1].spin_angle()
	for i in 20:
		await tree.process_frame
	var frozen: bool = is_equal_approx(stage.planets[1].spin_angle(), frozen_start)
	Accessibility.reduce_motion = old_reduce
	TestWorld.rec(out, "TC-068 mapa 3D: os planetas giram sozinhos e 'reduzir movimento' para o giro", moved and frozen)
	TestWorld.rec(out, "TC-068 mapa 3D: o palco e transparente, tem mundo 3D proprio e nenhum corpo de colisao; o save nao e tocado",
			stage.viewport.transparent_bg and stage.viewport.own_world_3d and stage.find_children("*", "CollisionObject3D", true, false).is_empty()
			and JSON.stringify(save) == before)
	map.queue_free()
	await tree.process_frame
