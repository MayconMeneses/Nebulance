class_name LevelBotUmbraxis
extends LevelBot19
## Base dos bots de Umbraxis: os mesmos passos ja validados nas fases de origem (barreira, plataforma movel, esteira+elevadores, mare,
## muro+planeio, ponte de ruptura), recebendo o deslocamento `ox` do modulo, mais escalada generica e a identificacao das pedras-eco por
## EVIDENCIA (pisca ou forma), nunca pelo campo `is_real`.


## Troca para o heroi `index` so se ainda nao for ele (o swap_to base com o mesmo indice giraria o trio).
func swap_to(index: int) -> bool:
	if level.rig.active_index == index:
		return true
	return await super.swap_to(index)


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


# ---- modulos (ver UmbraxisModules) ----

func do_barrier(info: Dictionary, ox: float) -> bool:
	if not await swap_to(0):
		return false
	if not await run_to(ox + 6.8):
		return false
	input.press_special()
	for i in 60:
		await tree.physics_frame
		if (info["barrier"] as ImpactBarrier).is_broken:
			break
	input.special_held = false
	if not (info["barrier"] as ImpactBarrier).is_broken:
		return false
	return await run_to(ox + 19.0)


func do_moving(info: Dictionary, ox: float) -> bool:
	if not await swap_to(0):
		return false
	var mp: MovingPlatform = info["mp"]
	if mp == null:
		return await run_to(ox + 33.0)
	if not await walk_to(ox + 13.3):
		return false
	await wait_platform(mp, ox + 17.0)
	if not await hop_right():
		return false
	await wait_platform(mp, ox + 21.0)
	if not await hop_right():
		return false
	return await run_to(ox + 33.0)


func do_belt_lift(info: Dictionary, ox: float) -> bool:
	if not await swap_to(0):
		return false
	if not await run_to(ox + 21.8):
		return false
	if not await ride(info["up"], ox + 23.5):
		return false
	if not await run_to(ox + 40.4 - 0.0):
		return false
	if not await ride(info["down"], ox + 41.5):
		return false
	if not await wait_floor() or body.global_position.y > 1.2:
		return false
	return await run_to(ox + 44.0)


func do_tide(info: Dictionary, ox: float) -> bool:
	if not await run_to(ox + 13.4):
		return false
	if not await walk_to(ox + 14.0):
		return false
	if not await set_tide(info["control"]):
		return false
	return await run_to(ox + 36.0)


func do_glide(ox: float) -> bool:
	if not await run_to(ox + 4.6):
		return false
	if not await swap_to(1):
		return false
	if not await run_to(ox + 7.0):
		return false
	if not await double_jump_up(3.2):
		stage += " (muro)"
		return false
	if not await swap_to(2):
		return false
	if not await run_to(ox + 15.8):
		return false
	if not await pipa_glide(3.2):
		return false
	return await run_to(ox + 33.0)


func do_bridge(info: Dictionary, ox: float) -> bool:
	if not await swap_to(1):
		return false
	if not await run_to(ox + 15.0):
		return false
	if not await walk_to(ox + 16.0):
		return false
	var st: Mechanism = info["stabilizer"]
	if not await press_until(func() -> bool: return st.is_active):
		return false
	if not await jump_at(ox + 19.3):
		return false
	var platforms: Array = info["platforms"]
	for p in platforms:
		if not await run_to((p as RupturePlatform).position.x + 0.8):
			return false
		if not await slow_hop():
			return false
	return true


# ---- ilusoes ----

## Observa as pedras por ~1 s e devolve a unica que nunca piscou e tem forma cheia; null se a evidencia for ambigua.
func pick_real_stone(stones: Array) -> EchoStone:
	var fake: Dictionary = {}
	for i in 70:
		await tree.physics_frame
		for s in stones:
			var st: EchoStone = s
			if not st.steady() or st.body_scale() != Vector3.ONE:
				fake[st] = true
	var real: Array = stones.filter(func(s: EchoStone) -> bool: return not fake.has(s))
	return real[0] if real.size() == 1 else null


func touch_stone(stone: EchoStone) -> bool:
	if not await walk_to(stone.position.x):
		return false
	return await press_until(func() -> bool: return stone.solved)
