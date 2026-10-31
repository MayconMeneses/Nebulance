class_name LevelBot09
extends LevelBot07
## Bot da fase 09: tres sinais de luz (chao, pedestal de Zuri, plataforma de Pipa), depois o portal (alem do bau) e o bau.

var portal_requests: Array[StringName] = []


func play() -> bool:
	var lv := level as CristaliaLevel09
	lv.controller.portal_requested.connect(func(id: StringName, _d: StringName) -> void: portal_requests.append(id))
	stage = "chegada"
	await frames(40)
	stage = "sinal 1 (chao)"
	if not await run_to(9.4):
		return false
	if not await walk_to(10.0):
		return false
	if not await set_prism(lv.prism_a, 0):
		return false
	stage = "sinal 2 (Zuri escala o pedestal)"
	if not await swap_to(1):
		return false
	if not await walk_to(13.3):
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
	if not await walk_to(18.0):
		return false
	if not await set_prism(lv.prism_b, 0):
		return false
	stage = "sinal 3 (Pipa planeia com vento)"
	if not await walk_to(19.7):
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
	if not landed or body.global_position.y < 5.3 or x() < 28.8:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	await frames(10)
	if not await walk_to(33.0):
		return false
	if not await set_prism(lv.prism_c, 0):
		return false
	input.move_axis = 0.3
	for i in 300:
		await tree.physics_frame
		if not body.is_on_floor():
			break
	if not await wait_floor():
		return false
	stage = "portal (alem do bau)"
	if not await run_to(97.6):
		return false
	if not await walk_to(98.0):
		return false
	for i in 20:
		input.press_interact()
		await tree.physics_frame
		if not portal_requests.is_empty():
			break
	if portal_requests.is_empty():
		return false
	stage = "bau"
	if not await run_left_to(85.8):
		return false
	if not await walk_to(84.4):
		return false
	for i in 60:
		input.press_interact()
		await tree.physics_frame
		if level.controller.completed:
			return true
	return false
