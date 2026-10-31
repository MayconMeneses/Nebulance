extends RefCounted
## Controller: aceleracao/desaceleracao, coyote time, jump buffer e salto variavel (TC-005).


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _accel_decel(tree, out)
	await _coyote(tree, out)
	await _buffer(tree, out)
	await _variable_jump(tree, out)
	return out


func _accel_decel(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	await w.step(20)
	w.input.move_axis = 1.0
	await w.step(30)
	var speed: float = w.body.velocity.x
	TestWorld.rec(out, "controller: acelera ate a velocidade de corrida", speed > 5.4, "(vx=%.2f)" % speed)
	# Esperado: 5.5*0.5 - 5.5^2/(2*40) = ~2.37 m em 0.5 s.
	TestWorld.rec(out, "controller: avanca para a direita (~2.4 m em 0.5 s)", absf(w.body.global_position.x - 2.37) < 0.3,
			"(x=%.2f)" % w.body.global_position.x)
	w.input.move_axis = 0.0
	await w.step(30)
	TestWorld.rec(out, "controller: desacelera ate parar", absf(w.body.velocity.x) < 0.05, "(vx=%.3f)" % w.body.velocity.x)
	w.dispose()


func _coyote(tree: SceneTree, out: Array) -> void:
	for case in [[3, true], [15, false]]:
		var w := TestWorld.create(tree, 0, "adventure", Vector3(0.0, 1.0, 0.0), -20.0, 3.0)
		await w.step(20)
		w.input.move_axis = 1.0
		for i in 200:
			await w.step(1)
			if not w.body.is_on_floor():
				break
		await w.step(case[0])
		w.input.press_jump()
		await w.step(1)
		var jumped: bool = w.body.velocity.y > 0.0
		var label: String = "dentro da janela" if case[1] else "apos a janela"
		TestWorld.rec(out, "TC-005 coyote time: salto %s %s" % [label, "ocorre" if case[1] else "NAO ocorre"],
				jumped == case[1], "(vy=%.2f)" % w.body.velocity.y)
		w.dispose()


func _buffer(tree: SceneTree, out: Array) -> void:
	for case in [[5, true], [0, false]]:
		var w := TestWorld.create(tree, 0, "adventure", Vector3(0.0, 1.15, 0.0))
		await w.step(case[0])
		w.input.press_jump()
		var peak_vy: float = -100.0
		for i in 30:
			await w.step(1)
			peak_vy = maxf(peak_vy, w.body.velocity.y)
		var jumped: bool = peak_vy > 5.0
		var label: String = "pressionado perto do pouso" if case[1] else "pressionado cedo demais"
		TestWorld.rec(out, "TC-005 jump buffer: %s %s" % [label, "salta no pouso" if case[1] else "NAO salta"],
				jumped == case[1], "(pico vy=%.2f)" % peak_vy)
		w.dispose()


func _variable_jump(tree: SceneTree, out: Array) -> void:
	var peaks: Array[float] = []
	for hold in [true, false]:
		var w := TestWorld.create(tree, 0)
		await w.step(20)
		var ground: float = w.feet_y()
		w.input.press_jump()
		await w.step(1)
		w.input.jump_held = hold
		var peak: float = ground
		for i in 60:
			await w.step(1)
			peak = maxf(peak, w.feet_y())
		peaks.append(peak - ground)
		w.dispose()
	TestWorld.rec(out, "controller: segurar o salto sobe mais que um toque", peaks[0] > peaks[1] + 0.5,
			"(segurado=%.2f toque=%.2f)" % [peaks[0], peaks[1]])
