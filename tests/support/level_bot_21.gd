class_name LevelBot21
extends LevelBot19
## Bot da fase 21: Rocco cruza as correntes; no recife Zuri escala e le a inscricao (abre o portal), liga os dois mecanismos antigos e
## atravessa as plataformas transparentes estabilizadas; recolhe o arquivo do primeiro explorador e abre o bau.


## Salto curto (eixo analogico 0.6) para pousar perto do centro da proxima plataforma.
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
	var lv := level as AquarysLevel21
	stage = "chegada"
	await frames(40)
	stage = "correntes (a favor e contra)"
	if not await run_to(58.0):
		return false
	stage = "Zuri escala a inscricao"
	if not await swap_to(1):
		return false
	if not await run_to(59.2):
		return false
	if not await walk_to(60.0):
		return false
	input.special_held = true
	for i in 400:
		await tree.physics_frame
		if body.global_position.y - 0.75 >= 5.4:
			break
	input.special_held = false
	input.move_axis = 1.0
	if not await wait_floor() or body.global_position.y < 5.5:
		stage += " (x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	if not await walk_to(64.0):
		return false
	if not await press_until(func() -> bool: return lv.inscription.is_active):
		return false
	stage = "descer e ligar o primeiro mecanismo"
	input.move_axis = 0.3
	for i in 300:
		await tree.physics_frame
		if not body.is_on_floor():
			break
	if not await wait_floor():
		return false
	if not await walk_to(70.0):
		return false
	if not await press_until(func() -> bool: return lv.stabilizer_a.is_active):
		return false
	stage = "plataformas transparentes (primeira sequencia)"
	if not await jump_at(73.3):
		return false
	for k in 4:
		if not await run_to(lv.reef_platforms[k].position.x + 0.8):
			return false
		if not await slow_hop():
			return false
	stage = "segundo mecanismo"
	if not await walk_to(96.0):
		return false
	if not await press_until(func() -> bool: return lv.stabilizer_b.is_active):
		return false
	stage = "plataformas transparentes (segunda sequencia)"
	if not await jump_at(105.3):
		return false
	for k in range(4, 6):
		if not await run_to(lv.reef_platforms[k].position.x + 0.8):
			return false
		if not await slow_hop():
			return false
	stage = "arquivo e bau"
	if not await run_to(126.8):
		return false
	if not await run_left_to(123.0):
		return false
	if not await walk_to(122.2):
		return false
	return await press_until(func() -> bool: return level.controller.completed)
