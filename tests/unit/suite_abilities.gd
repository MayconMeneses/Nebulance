extends RefCounted
## Habilidades: TC-006 (Rocco), TC-007 (Zuri), TC-008 (Pipa), com testes negativos.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _tc006(tree, out)
	await _tc007_double_jump(tree, out)
	await _tc007_climb(tree, out)
	await _tc008(tree, out)
	return out


func _tc006(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	var barrier: ImpactBarrier = w.add_barrier(Vector3(3.0, 1.5, 0.0), Vector3(1.0, 3.0, 3.0))
	await w.step(20)
	w.input.press_special()
	await w.step(40)
	TestWorld.rec(out, "TC-006 investida de Rocco quebra barreira marcada", barrier.is_broken)
	w.dispose()

	var walk := TestWorld.create(tree, 0)
	var barrier2: ImpactBarrier = walk.add_barrier(Vector3(3.0, 1.5, 0.0), Vector3(1.0, 3.0, 3.0))
	await walk.step(20)
	walk.input.move_axis = 1.0
	await walk.step(80)
	TestWorld.rec(out, "TC-006 sem investida, a barreira NAO quebra", not barrier2.is_broken)
	walk.dispose()

	var wall := TestWorld.create(tree, 0)
	wall.add_box(Vector3(3.0, 1.5, 0.0), Vector3(1.0, 3.0, 3.0), PhysicsLayers.WORLD)
	await wall.step(20)
	wall.input.press_special()
	await wall.step(40)
	TestWorld.rec(out, "TC-006 parede comum NAO e atravessada pela investida", wall.body.global_position.x < 2.2,
			"(x=%.2f)" % wall.body.global_position.x)
	wall.dispose()

	var unmarked := TestWorld.create(tree, 0)
	var barrier4: ImpactBarrier = unmarked.add_barrier(Vector3(3.0, 1.5, 0.0), Vector3(1.0, 3.0, 3.0))
	barrier4.remove_from_group(&"impact_target")
	await unmarked.step(20)
	unmarked.input.press_special()
	await unmarked.step(40)
	TestWorld.rec(out, "TC-006 alvo com on_impacted mas NAO marcado (fora do grupo) nao quebra", not barrier4.is_broken)
	unmarked.dispose()

	var zuri := TestWorld.create(tree, 1)
	var barrier3: ImpactBarrier = zuri.add_barrier(Vector3(3.0, 1.5, 0.0), Vector3(1.0, 3.0, 3.0))
	await zuri.step(20)
	zuri.input.move_axis = 1.0
	zuri.input.press_special()
	await zuri.step(60)
	TestWorld.rec(out, "TC-006 Zuri nao quebra barreira marcada", not barrier3.is_broken)
	zuri.dispose()


func _tc007_double_jump(tree: SceneTree, out: Array) -> void:
	for hero in [1, 0]:
		var w := TestWorld.create(tree, hero)
		await w.step(20)
		var name_hero: String = "Zuri" if hero == 1 else "Rocco"
		for round in 2:
			w.input.press_jump()
			await w.step(10)
			var before: float = w.body.velocity.y
			w.input.press_jump()
			await w.step(1)
			var boosted: bool = w.body.velocity.y > before + 1.0
			if hero == 1:
				TestWorld.rec(out, "TC-007 Zuri salto duplo no ar (volta %d)" % (round + 1), boosted,
						"(vy %.2f -> %.2f)" % [before, w.body.velocity.y])
			else:
				TestWorld.rec(out, "TC-007 Rocco NAO tem salto duplo (volta %d)" % (round + 1), not boosted)
			await w.step(3)
			var before3: float = w.body.velocity.y
			w.input.press_jump()
			await w.step(1)
			TestWorld.rec(out, "TC-007 %s: terceiro salto no mesmo voo NAO acontece (volta %d)" % [name_hero, round + 1],
					w.body.velocity.y < before3)
			w.input.release_all()
			await w.step(150)
		w.dispose()


func _tc007_climb(tree: SceneTree, out: Array) -> void:
	var cases: Array = [[1, true, "Zuri sobe superficie marcada"], [1, false, "Zuri NAO sobe sem superficie marcada"],
			[0, true, "Rocco NAO escala (mesmo em superficie marcada)"]]
	for c in cases:
		var w := TestWorld.create(tree, c[0])
		if c[1]:
			w.add_zone(PhysicsLayers.CLIMBABLE, Vector3(0.0, 3.0, 0.0), Vector3(3.0, 6.0, 3.0))
		await w.step(20)
		var y0: float = w.feet_y()
		w.input.special_held = true
		await w.step(40)
		var rise: float = w.feet_y() - y0
		var should_climb: bool = c[0] == 1 and c[1]
		TestWorld.rec(out, "TC-007 " + c[2], (rise > 1.5) == should_climb, "(subiu %.2f)" % rise)
		w.dispose()


func _tc008(tree: SceneTree, out: Array) -> void:
	var speeds: Dictionary = {}
	for case in [["pipa_glide", 2, true, false], ["pipa_free", 2, false, false], ["zuri_special", 1, true, false],
			["pipa_wind", 2, true, true]]:
		var w := TestWorld.create(tree, case[1], "adventure", Vector3(0.0, 41.0, 0.0))
		if case[3]:
			w.add_zone(PhysicsLayers.WIND, Vector3(0.0, 30.0, 0.0), Vector3(4.0, 80.0, 4.0), Vector3(0.0, 23.0, 0.0))
		if case[2]:
			w.input.press_special()
		await w.step(60)
		speeds[case[0]] = w.body.velocity.y
		if case[0] == "pipa_glide":
			await w.step(90)
			speeds["pipa_after_limit"] = w.body.velocity.y
		w.dispose()
	TestWorld.rec(out, "TC-008 Pipa planando: queda limitada", speeds["pipa_glide"] > -2.1 and speeds["pipa_glide"] < -1.5,
			"(vy=%.2f)" % speeds["pipa_glide"])
	TestWorld.rec(out, "TC-008 sem planar a queda e rapida", speeds["pipa_free"] < -15.0, "(vy=%.2f)" % speeds["pipa_free"])
	TestWorld.rec(out, "TC-008 planeio tem limite de duracao", speeds["pipa_after_limit"] < -10.0,
			"(vy=%.2f apos 2.5s)" % speeds["pipa_after_limit"])
	TestWorld.rec(out, "TC-008 Zuri nao planeia", speeds["zuri_special"] < -15.0)
	TestWorld.rec(out, "TC-008 vento sustenta o planeio", speeds["pipa_wind"] > speeds["pipa_glide"] + 0.5,
			"(vento=%.2f sem=%.2f)" % [speeds["pipa_wind"], speeds["pipa_glide"]])
	var finals: Array[float] = []
	for i in 2:
		var w := TestWorld.create(tree, 2, "adventure", Vector3(0.0, 41.0, 0.0))
		w.add_zone(PhysicsLayers.WIND, Vector3(0.0, 30.0, 0.0), Vector3(4.0, 80.0, 4.0), Vector3(0.0, 23.0, 0.0))
		w.input.press_special()
		await w.step(80)
		finals.append(w.body.global_position.y)
		w.dispose()
	TestWorld.rec(out, "TC-008 vento e deterministico (duas execucoes iguais)", finals[0] == finals[1],
			"(%.5f vs %.5f)" % [finals[0], finals[1]])
