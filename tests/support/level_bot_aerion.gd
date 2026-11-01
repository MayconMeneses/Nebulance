class_name LevelBotAerion
extends LevelBot13
## Base dos bots de Aerion: planeio de Pipa, escalada de Zuri e investida de Rocco (mesmos gestos do bot da fase 08 de Cristalia).


## Troca de heroi ate o indice pedido (passos de um em um).
func to_hero(index: int) -> bool:
	input.move_axis = 0.0
	await frames(4)
	for i in 4:
		if level.rig.active_index == index:
			return true
		input.swap(1 if index > level.rig.active_index else -1)
		await frames(8)
	return level.rig.active_index == index


## Troca para Pipa em `takeoff_x`, pula e planeia (com a corrente) ate pousar em `land_min_x` ou alem, na altura `land_y_min`.
func glide_across(takeoff_x: float, land_min_x: float, land_y_min: float) -> bool:
	if not await walk_to(takeoff_x):
		return false
	if not await to_hero(2):
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
	if not landed or body.global_position.y < land_y_min or x() < land_min_x:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	await frames(10)
	return true


## Troca para Zuri em `at_x` e escala a face marcada ate `top_y` (altura do pe), depois sobe no patamar.
func climb_to(at_x: float, top_y: float) -> bool:
	if not await to_hero(1):
		return false
	if not await walk_to(at_x):
		return false
	input.special_held = true
	for i in 400:
		await tree.physics_frame
		if body.global_position.y - 0.75 >= top_y + 0.4:
			break
	input.special_held = false
	input.move_axis = 1.0
	if not await wait_floor() or body.global_position.y < top_y + 0.5:
		stage += " (x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	return true


## Rocco: corre ate `from_x` e investe contra a barreira marcada.
func break_barrier(from_x: float, barrier: ImpactBarrier) -> bool:
	if not await to_hero(0):
		return false
	if not await run_to(from_x):
		return false
	input.press_special()
	for i in 60:
		await tree.physics_frame
		if barrier.is_broken:
			break
	input.special_held = false
	return barrier.is_broken
