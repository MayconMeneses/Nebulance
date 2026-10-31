extends RefCounted
## Troca de heroi: TC-003 (preserva estado) e TC-004 (colisao invalida sem softlock).


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _tc003_ground(tree, out)
	await _tc003_extras(tree, out)
	await _tc004(tree, out)
	await _real_input_path(tree, out)
	return out


func _tc003_ground(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	await w.step(20)
	var flags := {"changed": 0}
	w.rig.hero_changed.connect(func(_p: HeroProfile) -> void: flags["changed"] += 1)
	w.rig.vitals.hit()
	var hearts_before: int = w.rig.vitals.hearts
	var lives_before: int = w.rig.vitals.lives
	var feet_before: float = w.feet_y()
	var x_before: float = w.body.global_position.x
	w.body.velocity.x = 3.0
	var result: HeroSwapper.Result = w.rig.request_swap(1)
	TestWorld.rec(out, "TC-003 troca em solo e aceita", result == HeroSwapper.Result.OK)
	TestWorld.rec(out, "TC-003 heroi ativo mudou para Zuri", w.body.profile.hero_id == &"zuri" and w.rig.active_index == 1)
	TestWorld.rec(out, "TC-003 mantem vidas e coracoes", w.rig.vitals.lives == lives_before and w.rig.vitals.hearts == hearts_before,
			"(vidas=%d coracoes=%d)" % [w.rig.vitals.lives, w.rig.vitals.hearts])
	TestWorld.rec(out, "TC-003 mantem posicao dos pes e x", absf(w.feet_y() - feet_before) < 0.001
			and absf(w.body.global_position.x - x_before) < 0.001, "(pes %.3f -> %.3f)" % [feet_before, w.feet_y()])
	TestWorld.rec(out, "TC-003 mantem velocidade", is_equal_approx(w.body.velocity.x, 3.0))
	TestWorld.rec(out, "TC-003 emite hero_changed uma vez", flags["changed"] == 1)
	TestWorld.rec(out, "TC-003 trocar para o mesmo heroi e recusado", w.rig.request_swap(1) == HeroSwapper.Result.SAME_HERO)
	await w.step(5)
	TestWorld.rec(out, "TC-003 Zuri->Pipa->Rocco em piso aberto (pes alinhados)",
			w.rig.request_swap(2) == HeroSwapper.Result.OK and w.rig.request_swap(0) == HeroSwapper.Result.OK)
	w.dispose()


func _tc003_extras(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	await w.step(20)
	w.input.swap(1)
	await w.step(2)
	TestWorld.rec(out, "TC-003 troca por intencao (swap_dir) funciona", w.rig.active_index == 1)
	w.input.press_jump()
	await w.step(8)
	TestWorld.rec(out, "TC-003 troca no ar e aceita", not w.body.is_on_floor() and w.rig.request_swap(2) == HeroSwapper.Result.OK)
	w.dispose()
	var h := TestWorld.create(tree, 0)
	await h.step(20)
	h.body.take_hit()
	await h.step(1)
	TestWorld.rec(out, "TC-003 troca durante dano (HURT) e recusada", h.rig.request_swap(1) == HeroSwapper.Result.DENIED_STATE)
	await h.step(40)
	TestWorld.rec(out, "TC-003 troca volta a ser aceita apos o dano", h.rig.request_swap(1) == HeroSwapper.Result.OK)
	h.dispose()


func _tc004(tree: SceneTree, out: Array) -> void:
	for case in [[1.5, false], [2.5, true]]:
		var w := TestWorld.create(tree, 2)
		w.add_box(Vector3(0.0, case[0] + 0.5, 0.0), Vector3(6.0, 1.0, 4.0), PhysicsLayers.WORLD)
		await w.step(20)
		var pos_before: Vector3 = w.body.global_position
		var hearts: int = w.rig.vitals.hearts
		var result: HeroSwapper.Result = w.rig.request_swap(0)
		if case[1]:
			TestWorld.rec(out, "TC-004 controle: teto alto permite a troca", result == HeroSwapper.Result.OK)
		else:
			TestWorld.rec(out, "TC-004 teto baixo recusa a troca (DENIED_SPACE)", result == HeroSwapper.Result.DENIED_SPACE)
			TestWorld.rec(out, "TC-004 heroi, posicao e vitais inalterados",
					w.body.profile.hero_id == &"pipa" and w.body.global_position.is_equal_approx(pos_before)
					and w.rig.vitals.hearts == hearts)
			w.input.move_axis = 1.0
			await w.step(30)
			TestWorld.rec(out, "TC-004 sem softlock: ainda se move para fora do tunel", w.body.global_position.x > pos_before.x + 2.0,
					"(x=%.2f)" % w.body.global_position.x)
		w.dispose()


## Caminho REAL de entrada: InputMap -> InputReader -> HeroIntent -> troca (sem ScriptedInput).
func _real_input_path(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	var reader := InputReader.new()
	w.root.add_child(reader)
	w.body.intent_provider = reader.read
	await w.step(20)
	Input.action_press(&"swap_next")
	await w.step(3)
	Input.action_release(&"swap_next")
	TestWorld.rec(out, "entrada real: swap_next (R) troca Rocco -> Zuri", w.rig.active_index == 1, "(indice=%d)" % w.rig.active_index)
	await w.step(3)
	Input.action_press(&"swap_next")
	await w.step(3)
	Input.action_release(&"swap_next")
	TestWorld.rec(out, "entrada real: swap_next de novo troca Zuri -> Pipa", w.rig.active_index == 2, "(indice=%d)" % w.rig.active_index)
	await w.step(3)
	Input.action_press(&"swap_prev")
	await w.step(3)
	Input.action_release(&"swap_prev")
	TestWorld.rec(out, "entrada real: swap_prev (Q) volta Pipa -> Zuri", w.rig.active_index == 1, "(indice=%d)" % w.rig.active_index)
	w.dispose()
