class_name LevelBotS05
extends LevelBotAerion
## Bot da S05 (gravidade 0,4): saltos em arco calculados com a fisica do heroi ativo, planeio de Pipa com correcao de direcao e bau.


## Salta do ponto atual ate o centro `land_x` com desnivel `dh`; o eixo sai do tempo de voo em gravidade baixa.
func arc_hop(land_x: float, dh: float) -> bool:
	var t: MovementTuning = body.profile.tuning
	var g: float = t.gravity * AerionLevelS05.LOW_GRAVITY
	var t_air: float = (t.jump_velocity + sqrt(t.jump_velocity * t.jump_velocity - 2.0 * g * dh)) / g
	input.move_axis = clampf((land_x - x()) / (t.run_speed * t_air), 0.1, 1.0)
	input.press_jump()
	input.jump_held = true
	await wait_airborne()
	var ok: bool = await wait_floor(300)
	input.jump_held = false
	input.move_axis = 0.0
	await frames(10)
	return ok and body.global_position.y > -1.0


## Pipa: pula em `takeoff_x`, planeia e corrige a direcao pelo centro `land_x` da ilha de destino.
func precision_glide(takeoff_x: float, land_x: float, land_y_min: float) -> bool:
	if not await walk_to(takeoff_x):
		return false
	if not await to_hero(2):
		return false
	input.press_jump()
	input.jump_held = true
	input.move_axis = 1.0
	var landed: bool = false
	for i in 600:
		await tree.physics_frame
		if i == 18:
			input.press_special()
		input.move_axis = clampf((land_x - x()) / 3.0, -1.0, 1.0)
		if i > 20 and body.is_on_floor():
			landed = true
			break
	input.move_axis = 0.0
	input.special_held = false
	input.jump_held = false
	if not landed or body.global_position.y < land_y_min or absf(x() - land_x) > 2.2:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	await frames(10)
	return true


func play() -> bool:
	stage = "chegada"
	await frames(40)
	stage = "salto 1"
	if not await walk_to(2.0) or not await arc_hop(5.0, 1.75):
		return false
	stage = "salto 2"
	if not await walk_to(5.0) or not await arc_hop(10.0, 2.0):
		return false
	stage = "salto 3"
	if not await walk_to(10.0) or not await arc_hop(15.0, 2.0):
		return false
	stage = "planeio de precisao (Pipa)"
	if not await precision_glide(16.0, 30.0, 4.5):
		return false
	stage = "salto ate a ilha do bau"
	if not await walk_to(31.0) or not await arc_hop(36.5, 2.0):
		return false
	stage = "bau"
	if not await walk_to(40.4):
		return false
	input.move_axis = 0.0
	return await press_until(func() -> bool: return level.controller.completed)
