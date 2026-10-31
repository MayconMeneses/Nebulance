class_name LevelBot12
extends LevelBot06
## Bot de Zythra: prisma ate o nucleo, flor REAL (a que nao pisca), planeio de Pipa e Golpe Triade com tres herois.


func play() -> bool:
	var lv := arena as CristaliaLevel12
	stage = "chegada"
	await frames(40)
	stage = "etapa 1 (prisma ate o nucleo)"
	if not await walk_to(1.0):
		return false
	for i in 12:
		if lv.prism.orientation == 0:
			break
		input.press_interact()
		await tree.physics_frame
		await frames(4)
	await frames(6)
	if boss.phase != VyrkanBoss.Phase.TWO:
		stage += " (fase=%d)" % boss.phase
		return false
	stage = "etapa 2 (a flor real e a que nao pisca)"
	var real_x: float = 0.0
	for f in lv.flowers:
		if f.is_real:
			real_x = f.position.x
	if not await safe_walk(real_x):
		return false
	if not await press_until(func() -> bool: return boss.phase == VyrkanBoss.Phase.THREE):
		return false
	stage = "etapa 3 (Zuri escala, Pipa planeia)"
	if not await safe_walk(27.2):
		return false
	if not await swap_hero(1):
		return false
	if not await safe_walk(28.5, 0.5):
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
	if not await swap_hero(2):
		return false
	if not await walk_to(29.6):
		return false
	input.move_axis = -1.0
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
	if not landed or body.global_position.y < 5.3 or x() > 20.4 or x() < 13.6:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	await frames(10)
	if not await walk_to(18.0):
		return false
	if not await press_until(func() -> bool: return lv.pipa_mechanism.is_active):
		return false
	stage = "descer e Golpe Triade (3 herois)"
	if not await walk_to(15.0):
		return false
	for i in 400:
		await tree.physics_frame
		if boss.lane_safe(2, 1.6):
			break
	input.move_axis = -0.35
	for i in 200:
		await tree.physics_frame
		if not body.is_on_floor():
			break
	if not await wait_floor():
		return false
	input.move_axis = 0.0
	if not await safe_walk(11.5):
		return false
	if not await press_until(func() -> bool: return lv.triad.nodes[1].is_active):
		return false
	if not await swap_hero(0):
		return false
	if not await safe_walk(6.5):
		return false
	if not await press_until(func() -> bool: return lv.triad.nodes[0].is_active):
		return false
	if not await swap_hero(1):
		return false
	if not await safe_walk(16.5):
		return false
	if not await press_until(func() -> bool: return boss.is_defeated()):
		return false
	stage = "bau"
	if not await safe_walk(31.4):
		return false
	input.move_axis = 0.0
	for i in 60:
		input.press_interact()
		await tree.physics_frame
		if level.controller.completed:
			return true
	return false
