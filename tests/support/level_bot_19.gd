class_name LevelBot19
extends LevelBot13
## Bot da fase 19: sobe a mare, atravessa as plataformas flutuantes, baixa a mare e cruza a passarela exposta.


func set_tide(control: SluiceControl) -> bool:
	if not await press_until(func() -> bool: return control.water.level == control.target_level):
		return false
	for i in 400:
		await tree.physics_frame
		if control.water.is_settled():
			break
	await frames(6)
	return control.water.is_settled()


func play() -> bool:
	var lv := level as AquarysLevel19
	stage = "chegada"
	await frames(40)
	stage = "comporta alta"
	if not await run_to(13.4):
		return false
	if not await walk_to(14.0):
		return false
	if not await set_tide(lv.raise_control):
		return false
	stage = "plataformas flutuantes"
	if not await run_to(33.0):
		return false
	stage = "comporta baixa"
	if not await walk_to(35.0):
		return false
	if not await set_tide(lv.lower_control):
		return false
	stage = "passarela exposta"
	if not await run_to(66.0):
		return false
	stage = "bau"
	if not await run_to(75.4):
		return false
	input.move_axis = 0.0
	return await press_until(func() -> bool: return level.controller.completed)
