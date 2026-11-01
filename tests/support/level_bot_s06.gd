class_name LevelBotS06
extends LevelBotUmbraxis
## Bot da S06: escolhe a pedra-eco verdadeira pela evidencia, cruza as plataformas estabilizadas, toca os cristais na ordem da fechadura
## e abre o bau depois de pegar o traje e o arquivo final.


func go_to(target: float) -> bool:
	if target > x():
		if not await run_to(target - 0.8):
			return false
	else:
		if not await run_left_to(target + 0.8):
			return false
	return await walk_to(target)


func play() -> bool:
	var lv := level as UmbraxisLevelS06
	stage = "chegada"
	await frames(40)
	if not await swap_to(1):
		return false
	stage = "ilusoes leves"
	if not await run_to(5.0):
		return false
	var real: EchoStone = await pick_real_stone(lv.stones)
	if real == null:
		return false
	if not await touch_stone(real):
		return false
	if not await jump_at(19.3):
		return false
	for p in lv.platforms:
		if not await run_to((p as RupturePlatform).position.x + 0.8):
			return false
		if not await slow_hop():
			return false
	for k in lv.lock.order.size():
		var idx: int = lv.lock.order[k]
		stage = "cristal %d (passo %d)" % [idx, k + 1]
		if not await go_to(36.0 + 6.0 * idx):
			return false
		var before: int = lv.lock.progress
		for i in 30:
			input.press_interact()
			await tree.physics_frame
			if lv.lock.progress != before or lv.lock.is_unlocked:
				break
	if not lv.lock.is_unlocked:
		return false
	stage = "traje, arquivo e bau"
	if not await go_to(65.6):
		return false
	if not await go_to(62.2):
		return false
	return await press_until(func() -> bool: return level.controller.completed)
