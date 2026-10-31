class_name LevelBotS03
extends LevelBot13
## Bot da S03: elevador, trilho de polaridade, itens da bancada e bau.


func play() -> bool:
	var lv := level as MecatronLevelS03
	stage = "chegada"
	await frames(40)
	stage = "elevador"
	if not await run_to(15.4):
		return false
	if not await ride(lv.lift, 16.0):
		return false
	stage = "trilho"
	if not await run_to(24.6):
		return false
	if not await ride(lv.rail, 26.5):
		return false
	stage = "bancada"
	if not await run_to(40.2):
		return false
	stage = "bau"
	if not await walk_to(41.6):
		return false
	return await press_until(func() -> bool: return level.controller.completed)
