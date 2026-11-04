class_name LevelBot05
extends LevelBot02
## Bot da fase 05: Rocco (barreira) -> Zuri (escalar a torre) -> Pipa (vao com vento) -> ponte de ruptura -> bau.


func play() -> bool:
	var p: Array = _platforms()
	stage = "checkpoint"
	await frames(40)
	if not await run_to(20.6):
		return false
	stage = "barreira (Rocco)"
	if not await run_to(24.6):
		return false
	input.move_axis = 0.0
	await frames(8)
	input.press_special()
	input.move_axis = 1.0
	await frames(40)
	input.special_held = false
	if not await run_to(31.2):
		return false
	if not await walk_to(32.2):
		return false
	stage = "trocar para Zuri e escalar a torre"
	if not await swap_to(1):
		return false
	if not await walk_to(33.3):
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
	if not await run_to(45.0):
		return false
	input.move_axis = 0.3
	for i in 300:
		await tree.physics_frame
		if not body.is_on_floor():
			break
	if not await wait_floor():
		return false
	if not await walk_to(48.5):
		return false
	stage = "trocar para Pipa e planear o vao"
	if not await swap_to(2):
		return false
	if not await run_to(51.7):
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
	if not landed or x() < 60.5:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	await frames(10)
	stage = "holograma e ponte de ruptura"
	if not await run_to(70.4):
		return false
	if not await walk_to(75.4):
		return false
	if not await hop(null, p[0], 77.6):
		return false
	if not await stand_at(p[0].position.x + 1.1):
		return false
	if not await hop(p[0], p[1], p[1].position.x - 1.4):
		return false
	if not await stand_at(p[1].position.x + 1.1):
		return false
	if not await hop(p[1], p[2], p[2].position.x - 1.4):
		return false
	if not await stand_at(p[2].position.x + 1.1):
		return false
	if not await hop(p[2], null, 91.5):
		return false
	stage = "bau"
	if not await run_to(105.4):
		return false
	return await ExtensionRunner.finish(self)
