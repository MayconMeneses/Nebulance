class_name LevelBot18
extends LevelBot06
## Bot de Ferrorraiz: interruptores sincronizados, ancora magnetica (sobe com o heroi), protecao no alto e Golpe Triade com tres herois.


func play() -> bool:
	var lv := arena as MecatronLevel18
	stage = "chegada"
	await frames(40)
	stage = "etapa 1 (dois interruptores sincronizados)"
	if not await safe_walk(1.5):
		return false
	if not await press_until(func() -> bool: return lv.power_a.is_active):
		return false
	if not await safe_walk(6.5):
		return false
	if not await press_until(func() -> bool: return boss.phase == VyrkanBoss.Phase.TWO):
		stage += " (A=%s B=%s)" % [lv.power_a.is_active, lv.power_b.is_active]
		return false
	stage = "etapa 2 (ancora magnetica)"
	if not await safe_walk(21.5):
		return false
	if not await press_until(func() -> bool: return lv.anchor.control.is_active):
		return false
	for i in 400:
		await tree.physics_frame
		if boss.phase == VyrkanBoss.Phase.THREE:
			break
	await frames(10)
	if boss.phase != VyrkanBoss.Phase.THREE or body.global_position.y < 4.5:
		stage += " (fase=%d y=%.2f)" % [boss.phase, body.global_position.y]
		return false
	stage = "etapa 3 (protecao no alto)"
	if not await walk_to(25.0):
		return false
	if not await press_until(func() -> bool: return boss.phase == VyrkanBoss.Phase.FINISH):
		return false
	stage = "descer e Golpe Triade (3 herois)"
	input.move_axis = 1.0
	for i in 200:
		await tree.physics_frame
		if x() > 28.4:
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
	if not await swap_hero(2):
		return false
	if not await safe_walk(6.5):
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
