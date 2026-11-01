class_name LevelBot24
extends LevelBot06
## Bot de Thalassa: comportas (fluxo), onda que ergue a folha com o heroi, protecao no alto e Golpe Triade com tres herois.


## Aciona a comporta e espera a agua assentar.
func set_tide(control: SluiceControl) -> bool:
	if not await press_until(func() -> bool: return control.water.level == control.target_level):
		return false
	for i in 400:
		await tree.physics_frame
		if control.water.is_settled():
			break
	return control.water.is_settled()


func play() -> bool:
	var lv := arena as AquarysLevel24
	stage = "chegada"
	await frames(40)
	stage = "etapa 1 (comportas: Oeste 2, Leste 1)"
	if not await safe_walk(1.5):
		return false
	if not await set_tide(lv.west_gate):
		return false
	if not await safe_walk(6.5):
		return false
	if not await press_until(func() -> bool: return boss.phase == VyrkanBoss.Phase.TWO):
		stage += " (Oeste=%d Leste=%d)" % [lv.west.level, lv.east.level]
		return false
	stage = "etapa 2 (onda e folha flutuante)"
	if not await safe_walk(21.5):
		return false
	if not await press_until(func() -> bool: return lv.wave.level == 2):
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
	if not await walk_to(26.0):
		return false
	if not await press_until(func() -> bool: return boss.phase == VyrkanBoss.Phase.FINISH):
		return false
	stage = "descer e Golpe Triade (3 herois)"
	input.move_axis = 1.0
	for i in 200:
		await tree.physics_frame
		if x() > 29.2:
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
