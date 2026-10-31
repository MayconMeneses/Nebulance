class_name LevelBotS02
extends LevelBot
## Bot da S02: toca os cristais na ordem da fechadura e abre o bau.


func go_to(target: float) -> bool:
	if target > x():
		if not await run_to(target - 0.8):
			return false
	else:
		if not await run_left_to(target + 0.8):
			return false
	return await walk_to(target)


func play() -> bool:
	var lv := level as CristaliaLevelS02
	stage = "chegada"
	await frames(40)
	for k in lv.lock.order.size():
		var idx: int = lv.lock.order[k]
		stage = "cristal %d (passo %d)" % [idx, k + 1]
		if not await go_to(8.0 + 8.0 * idx):
			return false
		var before: int = lv.lock.progress
		for i in 30:
			input.press_interact()
			await tree.physics_frame
			if lv.lock.progress != before or lv.lock.is_unlocked:
				break
	if not lv.lock.is_unlocked:
		return false
	stage = "itens e bau"
	if not await go_to(39.5):
		return false
	if not await go_to(42.0):
		return false
	for i in 60:
		input.press_interact()
		await tree.physics_frame
		if level.controller.completed:
			return true
	return false
