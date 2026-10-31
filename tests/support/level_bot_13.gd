class_name LevelBot13
extends LevelBot
## Bot da fase 13: esteira a favor, esteira contraria (corre contra), alavanca do elevador, subida e bau.


func press_until(cond: Callable) -> bool:
	for i in 40:
		input.press_interact()
		await tree.physics_frame
		if cond.call():
			return true
	return false


func play() -> bool:
	var lv := level as MecatronLevel13
	stage = "chegada"
	await frames(40)
	stage = "esteira a favor"
	if not await run_to(31.0):
		return false
	stage = "esteira contraria (correr contra)"
	if not await run_to(48.0):
		return false
	stage = "alavanca do elevador"
	if not await run_to(53.9):
		return false
	if not await walk_to(55.0):
		return false
	if not await press_until(func() -> bool: return lv.lever.is_active):
		return false
	for i in 300:
		await tree.physics_frame
		if lv.elevator.progress >= 1.0:
			break
	await frames(10)
	if body.global_position.y < 6.5:
		stage += " (y=%.2f)" % body.global_position.y
		return false
	stage = "patamar e segredo"
	if not await run_to(76.5):
		return false
	stage = "bau"
	if not await walk_to(72.2):
		return false
	input.move_axis = 0.0
	return await press_until(func() -> bool: return level.controller.completed)
