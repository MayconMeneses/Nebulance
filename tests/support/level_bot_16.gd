class_name LevelBot16
extends LevelBot13
## Bot da fase 16: sobe no elevador, atravessa o vao no trilho, desce no segundo elevador, inverte a esteira e abre o bau.


func ride(platform: PolarityPlatform, at_x: float) -> bool:
	if not await walk_to(at_x):
		return false
	if not await press_until(func() -> bool: return platform.control.is_active):
		return false
	for i in 400:
		await tree.physics_frame
		if platform.progress >= 1.0:
			break
	await frames(8)
	return platform.progress >= 1.0


func play() -> bool:
	var lv := level as MecatronLevel16
	stage = "chegada"
	await frames(40)
	stage = "elevador de subida"
	if not await run_to(17.5):
		return false
	if not await ride(lv.lift_up, 18.0):
		return false
	stage = "trilho sobre o vao"
	if not await run_to(29.8):
		return false
	if not await ride(lv.rail, 30.5):
		return false
	stage = "segunda plataforma (checkpoint)"
	if not await run_to(51.6):
		return false
	stage = "elevador de descida"
	if not await ride(lv.lift_down, 52.5):
		return false
	if not await wait_floor() or body.global_position.y > 1.2:
		stage += " (y=%.2f)" % body.global_position.y
		return false
	stage = "alavanca da esteira"
	if not await run_to(55.5):
		return false
	if not await walk_to(56.0):
		return false
	if not await press_until(func() -> bool: return lv.lever_belt.is_active):
		return false
	stage = "esteira invertida e beco"
	if not await run_to(88.5):
		return false
	stage = "bau"
	if not await run_left_to(77.0):
		return false
	if not await walk_to(76.2):
		return false
	return await press_until(func() -> bool: return level.controller.completed)
