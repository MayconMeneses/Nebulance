class_name LevelBot29
extends LevelBotAerion
## Bot da fase 29: vento de popa, inversao de gravidade pelo teto, planeio com corrente (Pipa), tres coordenadas, console, ponte e bau.


func play() -> bool:
	var lv := level as AerionLevel29
	stage = "chegada"
	await frames(40)
	stage = "desafio do vento"
	if not await jump_at(13.4):
		return false
	if x() < 21.0:
		stage += " (x=%.1f)" % x()
		return false
	if not await walk_to(30.0):
		return false
	if not await press_until(func() -> bool: return lv.coord_wind.is_active):
		return false
	stage = "desafio da gravidade (pelo teto)"
	if not await run_to(54.0):
		return false
	input.move_axis = 0.0
	if not await wait_floor():
		stage += " (x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	if not await walk_to(58.0):
		return false
	if not await press_until(func() -> bool: return lv.coord_gravity.is_active):
		return false
	stage = "desafio do planeio (Pipa)"
	if not await run_to(69.0):
		return false
	if not await glide_across(69.7, 78.8, 0.3):
		return false
	stage = "coordenada da rota e console"
	if not await walk_to(84.0):
		return false
	if not await press_until(func() -> bool: return lv.coord_route.is_active):
		return false
	if not await walk_to(92.0):
		return false
	if not await press_until(func() -> bool: return lv.console.is_active):
		stage += " (console liberado=%s)" % lv.console.enabled
		return false
	stage = "ponte da rota, memoria e bau"
	if not await run_to(115.4):
		return false
	input.move_axis = 0.0
	return await ExtensionRunner.finish(self)
