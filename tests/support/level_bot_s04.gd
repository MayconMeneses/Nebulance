class_name LevelBotS04
extends LevelBot19
## Bot da S04: sobe a mare, cruza as plataformas flutuantes, sobe os degraus de metal e abre o bau (apos pegar o acessorio e a gravacao).


func play() -> bool:
	var lv := level as AquarysLevelS04
	stage = "chegada"
	await frames(40)
	stage = "comporta"
	if not await run_to(9.4):
		return false
	if not await walk_to(10.0):
		return false
	if not await set_tide(lv.raise_control):
		return false
	stage = "plataformas flutuantes"
	if not await run_to(33.0):
		return false
	stage = "degraus de metal"
	if not await jump_at(46.4):
		return false
	if not await jump_at(50.3):
		return false
	stage = "sala do bau"
	if not await jump_at(56.3):
		return false
	if not await run_to(66.6):
		return false
	if not await run_left_to(63.0):
		return false
	if not await walk_to(62.2):
		return false
	return await press_until(func() -> bool: return level.controller.completed)
