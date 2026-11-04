class_name LevelBot17
extends LevelBot13
## Bot da fase 17: Zuri escala e liga o painel escondido (abre o portal), Rocco cruza esteira, prensa, elevador, segunda prensa,
## elevador de descida e esteira invertida; pega o arquivo e abre o bau.


func play() -> bool:
	var lv := level as MecatronLevel17
	stage = "chegada"
	await frames(40)
	stage = "Zuri escala ao painel escondido"
	if not await swap_to(1):
		return false
	if not await run_to(10.2):
		return false
	if not await walk_to(11.0):
		return false
	input.special_held = true
	for i in 400:
		await tree.physics_frame
		if body.global_position.y - 0.75 >= 5.4:
			break
	input.special_held = false
	input.move_axis = 1.0
	if not await wait_floor() or body.global_position.y < 5.5:
		stage += " (x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	if not await walk_to(15.0):
		return false
	if not await press_until(func() -> bool: return lv.secret_lever.is_active):
		return false
	stage = "descer e voltar a Rocco"
	if not await run_to(19.0):
		return false
	if not await wait_floor():
		return false
	if not await swap_to(0):
		return false
	stage = "esteira"
	if not await run_to(41.0):
		return false
	stage = "primeira prensa"
	if not await walk_to(lv.presses[0].position.x - 3.2):
		return false
	if not await cross_press(lv.presses[0]):
		return false
	stage = "elevador de subida"
	if not await run_to(51.8):
		return false
	if not await ride(lv.lift_up, 53.5):
		return false
	stage = "segunda prensa"
	if not await run_to(58.8):
		return false
	if not await cross_press(lv.presses[1]):
		return false
	stage = "elevador de descida"
	if not await run_to(70.4):
		return false
	if not await ride(lv.lift_down, 71.5):
		return false
	if not await wait_floor() or body.global_position.y > 1.2:
		return false
	stage = "alavanca da esteira"
	if not await run_to(74.0):
		return false
	if not await walk_to(74.5):
		return false
	if not await press_until(func() -> bool: return lv.lever_belt.is_active):
		return false
	stage = "arquivo e bau"
	if not await run_to(100.8):
		return false
	if not await run_left_to(97.0):
		return false
	if not await walk_to(96.2):
		return false
	return await ExtensionRunner.finish(self)
