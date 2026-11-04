class_name LevelBot07
extends LevelBot
## Bot da fase 07: gira prismas (E) ate o cristal acender, atravessa as pontes de luz e pega o segredo com Zuri.


func set_prism(prism: BeamPrism, want: int) -> bool:
	for i in 12:
		if prism.orientation == want:
			return true
		input.press_interact()
		await tree.physics_frame
		await frames(4)
	return prism.orientation == want


func play() -> bool:
	var lv := level as CristaliaLevel07
	stage = "chegada"
	await frames(40)
	stage = "primeiro prisma (ponte b1)"
	if not await run_to(11.2):
		return false
	if not await walk_to(12.0):
		return false
	if not await set_prism(lv.prism_a, 0):
		return false
	await frames(6)
	stage = "atravessar a ponte de luz"
	if not await run_to(33.4):
		return false
	stage = "segundo prisma (ponte b2)"
	if not await walk_to(37.0):
		return false
	if not await set_prism(lv.prism_b, 0):
		return false
	await frames(6)
	stage = "trocar para Zuri e pegar o segredo"
	if not await walk_to(31.0):
		return false
	if not await swap_to(1):
		return false
	input.press_jump()
	input.jump_held = true
	input.move_axis = 1.0
	for i in 40:
		await tree.physics_frame
		if body.velocity.y <= 0.5:
			break
	input.press_jump()
	await frames(30)
	input.jump_held = false
	if not await wait_floor() or body.global_position.y < 3.2:
		stage += " (x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	if not await run_to(41.4):
		return false
	input.move_axis = 0.3
	for i in 200:
		await tree.physics_frame
		if not body.is_on_floor():
			break
	if not await wait_floor():
		return false
	stage = "bau"
	if not await run_to(75.4):
		return false
	return await ExtensionRunner.finish(self)
