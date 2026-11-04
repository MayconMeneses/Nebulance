class_name LevelBot14
extends LevelBot13
## Bot da fase 14: Rocco quebra a barreira, esteira, Zuri escala ao item, depois cruza as tres prensas esperando cada uma subir.


func play() -> bool:
	var lv := level as MecatronLevel14
	stage = "chegada"
	await frames(40)
	stage = "barreira marcada (Rocco)"
	if not await run_to(11.8):
		return false
	input.press_special()
	for i in 60:
		await tree.physics_frame
		if lv.barrier.is_broken:
			break
	input.special_held = false
	stage = "esteira"
	if not await run_to(31.0):
		return false
	stage = "Zuri escala ate o item"
	if not await swap_to(1):
		return false
	if not await walk_to(34.4):
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
	if not await walk_to(38.0):
		return false
	stage = "descer para as prensas"
	for i in 1200:
		await tree.physics_frame
		if lv.presses[0].state == HydraulicPress.State.RECOVER:
			break
	if not await run_to(44.8):
		return false
	if not await wait_floor():
		return false
	for k in 3:
		stage = "prensa %d" % (k + 1)
		if not await walk_to(lv.presses[k].position.x - 3.2) and k > 0:
			return false
		if not await cross_press(lv.presses[k]):
			return false
		if k < 2 and not await walk_to(lv.presses[k].position.x + 4.8):
			return false
	stage = "bau"
	if not await run_to(65.6):
		return false
	input.move_axis = 0.0
	return await ExtensionRunner.finish(self)
