class_name LevelBot03
extends LevelBot
## Bot da fase 03: Rocco quebra a barreira e ativa o mecanismo 1; Zuri escala e ativa o 2; Pipa planeia ate o 3,
## pega a memoria no portal e segue ate o bau.

var portal_requests: Array[StringName] = []


func _press_until(node: Mechanism) -> bool:
	for i in 40:
		input.press_interact()
		await tree.physics_frame
		if node.is_active:
			return true
	return false


func play() -> bool:
	var mechs: Array = level.find_children("*", "Mechanism", true, false)
	mechs.sort_custom(func(a: Node3D, b: Node3D) -> bool: return a.position.x < b.position.x)
	level.controller.portal_requested.connect(func(id: StringName, _dest: StringName) -> void: portal_requests.append(id))
	stage = "chegada e checkpoint"
	await frames(40)
	if not await run_to(16.6):
		return false
	stage = "barreira (Rocco)"
	if not await run_to(26.8):
		return false
	input.move_axis = 0.0
	await frames(8)
	input.press_special()
	input.move_axis = 1.0
	await frames(40)
	input.special_held = false
	stage = "mecanismo 1 (nicho)"
	if not await run_to(32.4):
		return false
	if not await walk_to(31.5):
		return false
	if not await _press_until(mechs[0]):
		return false
	stage = "trocar para Zuri e escalar"
	if not await swap_to(1):
		return false
	if not await run_to(38.6):
		return false
	input.move_axis = 0.0
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
	stage = "mecanismo 2 (no alto)"
	if not await run_to(44.2):
		return false
	if not await walk_to(44.5):
		return false
	if not await _press_until(mechs[1]):
		return false
	stage = "trocar para Pipa e planear com o vento"
	if not await swap_to(2):
		return false
	if not await run_to(45.7):
		return false
	input.press_jump()
	input.jump_held = true
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
	if not landed or body.global_position.y < 5.3:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	await frames(10)
	stage = "mecanismo 3 (simbolo) e portao"
	if not await run_to(56.0):
		return false
	if not await walk_to(56.5):
		return false
	if not await _press_until(mechs[2]):
		return false
	await frames(5)
	stage = "portal e memoria do segredo"
	if not await walk_to(60.4):
		return false
	for i in 20:
		input.press_interact()
		await tree.physics_frame
		if not portal_requests.is_empty():
			break
	if portal_requests.is_empty():
		return false
	stage = "descer e ir ao bau"
	input.move_axis = 0.3
	for i in 200:
		await tree.physics_frame
		if not body.is_on_floor():
			break
	if not await wait_floor():
		return false
	if not await run_to(97.4):
		return false
	return await ExtensionRunner.finish(self)
