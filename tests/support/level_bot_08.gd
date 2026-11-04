class_name LevelBot08
extends LevelBot07
## Bot da fase 08: prisma do chao, escalada ate o prisma alto (Zuri), planeio ate o dispositivo (Pipa), parede aberta pela luz, bau.


func play() -> bool:
	var lv := level as CristaliaLevel08
	stage = "chegada"
	await frames(40)
	stage = "prisma do chao"
	if not await run_to(9.4):
		return false
	if not await walk_to(10.0):
		return false
	if not await set_prism(lv.prism_ground, 0):
		return false
	stage = "trocar para Zuri e escalar o pedestal"
	if not await swap_to(1):
		return false
	if not await walk_to(7.4):
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
	stage = "prisma alto"
	if not await walk_to(10.0):
		return false
	if not await set_prism(lv.prism_high, 0):
		return false
	stage = "trocar para Pipa e planear ate o dispositivo"
	if not await walk_to(13.7):
		return false
	if not await swap_to(2):
		return false
	input.press_jump()
	input.jump_held = true
	input.move_axis = 1.0
	await frames(18)
	input.press_special()
	var landed: bool = false
	for i in 260:
		await tree.physics_frame
		if body.is_on_floor():
			landed = true
			break
	input.move_axis = 0.0
	input.special_held = false
	input.jump_held = false
	if not landed or body.global_position.y < 5.3 or x() < 22.8:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	await frames(10)
	if not await walk_to(24.5):
		return false
	for i in 40:
		input.press_interact()
		await tree.physics_frame
		if lv.device.is_active:
			break
	if not lv.device.is_active:
		return false
	await frames(10)
	stage = "parede de luz aberta e bau"
	if not await walk_to(28.0):
		return false
	input.move_axis = 0.3
	for i in 200:
		await tree.physics_frame
		if not body.is_on_floor():
			break
	if not await wait_floor():
		return false
	if lv.field.is_lit(&"wall") == false:
		stage += " (parede ainda fechada)"
		return false
	if not await run_to(59.4):
		return false
	return await ExtensionRunner.finish(self)
