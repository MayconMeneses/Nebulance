class_name LevelBotUmbraxisBase
extends LevelBot19
## Base dos bots de Umbraxis: os mesmos passos ja validados nas fases de origem (barreira, plataforma movel, esteira+elevadores, mare,
## muro+planeio, ponte de ruptura), recebendo o deslocamento `ox` do modulo, mais escalada generica e a identificacao das pedras-eco por
## EVIDENCIA (pisca ou forma), nunca pelo campo `is_real`.


## Troca para o heroi `index` so se ainda nao for ele (o swap_to base com o mesmo indice giraria o trio).
func swap_to(index: int) -> bool:
	if level.rig.active_index == index:
		return true
	for attempt in 4:
		if await super.swap_to(index):
			return true
		await frames(8)
	return level.rig.active_index == index


func slow_hop() -> bool:
	input.move_axis = 0.6
	input.press_jump()
	input.jump_held = true
	await wait_airborne()
	var ok: bool = await wait_floor()
	input.jump_held = false
	input.move_axis = 1.0
	return ok and body.global_position.y > -1.0


## Espera ate o destino estar solido com folga e a plataforma atual ainda durar; entao salta (plataformas de ruptura instaveis).
func hop(cur: RupturePlatform, nxt: RupturePlatform, land_x: float, fall_y: float = -1.5) -> bool:
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
		if body.global_position.y < fall_y:
			input.jump_held = false
			return false
	input.jump_held = false
	return false


func stand_at(x_target: float) -> bool:
	if not await run_to(x_target):
		return false
	input.move_axis = 0.0
	await frames(12)
	return true


## Zuri escala a zona escalavel em `zone_x` ate pousar no patamar cujo topo fica em `top` (ex.: 5,0).
func climb(zone_x: float, top: float) -> bool:
	if not await run_to(zone_x - 0.8):
		return false
	if not await walk_to(zone_x):
		return false
	input.special_held = true
	for i in 500:
		await tree.physics_frame
		if body.global_position.y - 0.75 >= top + 0.4:
			break
	input.special_held = false
	input.move_axis = 1.0
	if not await wait_floor() or body.global_position.y < top + 0.5:
		stage += " (x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	return true


## Desce devagar do patamar (eixo analogico) ate o chao.
func descend_slow(axis: float = 0.3) -> bool:
	input.move_axis = axis
	for i in 300:
		await tree.physics_frame
		if not body.is_on_floor():
			break
	return await wait_floor()


func double_jump_up(min_y: float) -> bool:
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
	return await wait_floor() and body.global_position.y >= min_y


func pipa_glide(min_y: float) -> bool:
	input.press_jump()
	input.jump_held = true
	await frames(18)
	input.press_special()
	var landed: bool = false
	for i in 240:
		await tree.physics_frame
		if body.is_on_floor():
			landed = true
			break
	input.move_axis = 0.0
	input.special_held = false
	input.jump_held = false
	if not landed or body.global_position.y < min_y:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	await frames(10)
	return true


func wait_platform(mp: MovingPlatform, near_x: float, cap: int = 900) -> void:
	for i in cap:
		await tree.physics_frame
		if absf(mp.current_x() - near_x) <= 0.25:
			return


func hop_right() -> bool:
	input.move_axis = 1.0
	input.press_jump()
	input.jump_held = true
	await wait_airborne()
	var ok: bool = await wait_floor(120)
	input.jump_held = false
	input.move_axis = 0.0
	return ok and body.global_position.y > -1.0
