class_name LevelBot30
extends LevelBot06
## Bot de Zefrion: controles de vento sincronizados, escalada de Zuri ao farol, planeio de Pipa ate o nucleo e Golpe Triade com tres herois.


func play() -> bool:
	var lv := arena as AerionLevel30
	stage = "chegada"
	await frames(40)
	stage = "etapa 1 (dois controles de vento sincronizados)"
	if not await safe_walk(1.5):
		return false
	if not await press_until(func() -> bool: return lv.anchor_a.is_active):
		return false
	if not await safe_walk(6.5):
		return false
	if not await press_until(func() -> bool: return boss.phase == VyrkanBoss.Phase.TWO):
		stage += " (A=%s B=%s)" % [lv.anchor_a.is_active, lv.anchor_b.is_active]
		return false
	stage = "etapa 2 (Zuri escala ate o farol)"
	if not await swap_hero(1):
		return false
	if not await safe_walk(21.5):
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
	if not await walk_to(27.0):
		return false
	if not await press_until(func() -> bool: return boss.phase == VyrkanBoss.Phase.THREE):
		return false
	stage = "etapa 3 (Pipa planeia ate o nucleo)"
	if not await swap_hero(2):
		return false
	if not await walk_to(30.2):
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
	if not landed or body.global_position.y < 5.3 or x() < 39.3:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	await frames(10)
	if not await walk_to(43.0):
		return false
	if not await press_until(func() -> bool: return boss.phase == VyrkanBoss.Phase.FINISH):
		return false
	stage = "descer e Golpe Triade (3 herois)"
	input.move_axis = 1.0
	for i in 200:
		await tree.physics_frame
		if x() > 47.2:
			break
	input.move_axis = 0.0
	if not await wait_floor():
		return false
	if not await safe_walk(16.5):
		return false
	if not await press_until(func() -> bool: return lv.triad.nodes[2].is_active):
		return false
	if not await swap_hero(1):
		return false
	if not await safe_walk(11.5):
		return false
	if not await press_until(func() -> bool: return lv.triad.nodes[1].is_active):
		return false
	if not await swap_hero(0):
		return false
	if not await safe_walk(6.5):
		return false
	if not await press_until(func() -> bool: return boss.is_defeated()):
		return false
	stage = "bau"
	if not await safe_walk(53.4):
		return false
	input.move_axis = 0.0
	for i in 60:
		input.press_interact()
		await tree.physics_frame
		if level.controller.completed:
			return true
	return false
