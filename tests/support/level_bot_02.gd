class_name LevelBot02
extends LevelBot
## Bot da fase 02: atravessa plataformas de ruptura esperando o momento solido, ativa o estabilizador e pega o segredo com Zuri.


func _platforms() -> Array:
	var list: Array = level.find_children("*", "RupturePlatform", true, false)
	list.sort_custom(func(a: Node3D, b: Node3D) -> bool: return a.position.x < b.position.x)
	return list


func stand_at(x_target: float) -> bool:
	if not await run_to(x_target):
		return false
	input.move_axis = 0.0
	await frames(12)
	return true


## Espera ate o destino estar solido com folga e a plataforma atual ainda durar; entao salta.
func hop(cur: RupturePlatform, nxt: RupturePlatform, land_x: float) -> bool:
	for i in 900:
		await tree.physics_frame
		var ok_next: bool = nxt == null or (nxt.is_solid() and nxt.solid_remaining() >= 1.2)
		var ok_cur: bool = cur == null or cur.solid_remaining() >= 0.75
		if ok_next and ok_cur:
			break
	input.move_axis = 1.0
	input.press_jump()
	input.jump_held = true
	await wait_airborne()
	for i in 150:
		await tree.physics_frame
		if body.is_on_floor() and x() >= land_x:
			input.jump_held = false
			return true
		if body.global_position.y < -1.5:
			input.jump_held = false
			return false
	input.jump_held = false
	return false


## Salto curto (eixo analogico 0.6) para atravessar a ponte estabilizada pousando perto do centro da proxima plataforma.
func slow_hop() -> bool:
	input.move_axis = 0.6
	input.press_jump()
	input.jump_held = true
	await wait_airborne()
	var ok: bool = await wait_floor()
	input.jump_held = false
	input.move_axis = 1.0
	return ok and body.global_position.y > -1.0


func play() -> bool:
	var p: Array = _platforms()
	stage = "chegada e checkpoint"
	await frames(40)
	if not await run_to(14.6):
		return false
	if not await stand_at(15.4):
		return false
	stage = "primeira sequencia (3 plataformas de ruptura)"
	if not await hop(null, p[0], 17.6):
		return false
	if not await stand_at(p[0].position.x + 1.1):
		return false
	if not await hop(p[0], p[1], p[1].position.x - 1.4):
		return false
	if not await stand_at(p[1].position.x + 1.1):
		return false
	if not await hop(p[1], p[2], p[2].position.x - 1.4):
		return false
	if not await stand_at(p[2].position.x + 1.1):
		return false
	stage = "ilha central"
	if not await hop(p[2], null, 31.5):
		return false
	if not await stand_at(32.4):
		return false
	stage = "trocar para Zuri e pegar o segredo (salto duplo)"
	if not await swap_to(1):
		return false
	if not await run_to(33.0):
		return false
	input.press_jump()
	input.jump_held = true
	for i in 40:
		await tree.physics_frame
		if body.velocity.y <= 0.5:
			break
	input.press_jump()
	input.jump_held = true
	await frames(30)
	input.jump_held = false
	if not await wait_floor() or body.global_position.y < 3.2:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	stage = "itens da plataforma alta e descida"
	if not await run_to(43.0):
		return false
	# Desce devagar da plataforma alta (eixo analogico) para pousar na ilha, nao no abismo.
	input.move_axis = 0.3
	for i in 200:
		await tree.physics_frame
		if not body.is_on_floor():
			break
	if not await wait_floor():
		return false
	if not await stand_at(45.3):
		return false
	stage = "estabilizador"
	var stabilizer: Mechanism = level.find_children("*", "Mechanism", true, false)[0] as Mechanism
	for i in 30:
		input.press_interact()
		await tree.physics_frame
		if stabilizer.is_active:
			break
	if not stabilizer.is_active:
		return false
	stage = "segunda sequencia (estabilizada)"
	if not await jump_at(46.3):
		return false
	for k in range(3, 7):
		if not await run_to(p[k].position.x + 0.8):
			return false
		if not await slow_hop():
			return false
	stage = "bau"
	if not await run_to(102.4):
		return false
	return await ExtensionRunner.finish(self)
