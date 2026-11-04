class_name LevelBot04
extends LevelBot
## Bot da fase 04: espera as plataformas moveis nos extremos (velocidade ~0), resgata a criatura e foge da onda pulando o buraco.


func _mps() -> Array:
	var list: Array = level.find_children("*", "MovingPlatform", true, false)
	list.sort_custom(func(a: Node3D, b: Node3D) -> bool: return a.origin_x < b.origin_x)
	return list


func _wait_platform(mp: MovingPlatform, near_x: float, cap: int = 900) -> void:
	for i in cap:
		await tree.physics_frame
		if absf(mp.current_x() - near_x) <= 0.25:
			return


func _hop_right() -> bool:
	input.move_axis = 1.0
	input.press_jump()
	input.jump_held = true
	await wait_airborne()
	var ok: bool = await wait_floor(120)
	input.jump_held = false
	input.move_axis = 0.0
	return ok and body.global_position.y > -1.0


func play() -> bool:
	var mp: Array = _mps()
	stage = "chegada"
	await frames(40)
	stage = "primeira plataforma movel"
	if not await walk_to(13.3):
		return false
	await _wait_platform(mp[0], 17.0)
	if not await _hop_right():
		return false
	await _wait_platform(mp[0], 21.0)
	stage = "ilha do resgate"
	if not await _hop_right():
		return false
	if not await walk_to(26.3):
		return false
	if not await walk_to(28.0):
		return false
	var creature: Rescue = level.find_children("*", "Rescue", true, false)[0] as Rescue
	for i in 30:
		input.press_interact()
		await tree.physics_frame
		if creature.is_rescued:
			break
	if not creature.is_rescued:
		return false
	stage = "segunda plataforma movel"
	if not await walk_to(31.0):
		return false
	await _wait_platform(mp[1], 35.0)
	if not await _hop_right():
		return false
	await _wait_platform(mp[1], 39.0)
	if not await _hop_right():
		return false
	stage = "checkpoint e perseguicao (buraco em x=80)"
	if not await run_to(79.2):
		return false
	input.press_jump()
	input.jump_held = true
	await wait_airborne()
	if not await wait_floor(120):
		return false
	input.jump_held = false
	stage = "bau"
	if not await run_to(115.4):
		return false
	return await ExtensionRunner.finish(self)
