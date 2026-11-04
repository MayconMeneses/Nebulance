class_name LevelBot20
extends LevelBot19
## Bot da fase 20: mare alta, Zuri escala ao coletavel, Rocco quebra a barreira, mare baixa e passarela ate o bau.


func play() -> bool:
	var lv := level as AquarysLevel20
	stage = "chegada"
	await frames(40)
	stage = "comporta alta"
	if not await run_to(11.4):
		return false
	if not await walk_to(12.0):
		return false
	if not await set_tide(lv.raise_control):
		return false
	stage = "plataformas flutuantes"
	if not await run_to(31.0):
		return false
	stage = "Zuri escala ao coletavel"
	if not await swap_to(1):
		return false
	if not await walk_to(33.0):
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
	if not await walk_to(37.0):
		return false
	if not await run_left_to(32.0):
		return false
	input.move_axis = 0.0
	if not await wait_floor():
		return false
	stage = "comporta baixa"
	if not await swap_to(0):
		return false
	if not await walk_to(36.0):
		return false
	if not await set_tide(lv.lower_control):
		return false
	stage = "barreira marcada (Rocco)"
	if not await run_to(37.6):
		return false
	input.press_special()
	for i in 60:
		await tree.physics_frame
		if lv.barrier.is_broken:
			break
	input.special_held = false
	stage = "passarela exposta"
	if not await run_to(56.0):
		return false
	stage = "bau"
	if not await run_to(65.4):
		return false
	input.move_axis = 0.0
	return await ExtensionRunner.finish(self)
