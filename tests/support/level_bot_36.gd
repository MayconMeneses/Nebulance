class_name LevelBot36
extends LevelBotUmbraxis
## Bot de Necryon: so entra numa faixa de raizes quando ela e segura; combinacao dos cristais, pedra-eco real escolhida por EVIDENCIA,
## estabilizador + travessia + escalada + nucleo, e Golpe Triade com tres herois.

var boss: NecryonBoss


func _entering_unsafe(dir: float) -> bool:
	for i in VyrkanBoss.LANE_X.size():
		var lx: float = VyrkanBoss.LANE_X[i]
		var inside: bool = absf(x() - lx) <= 2.0
		var ahead: bool = absf((x() + dir * 1.6) - lx) <= 2.0
		if ahead and not inside and not boss.lane_safe(i, 1.0):
			return true
	return false


func safe_walk(target_x: float) -> bool:
	for i in 3000:
		await tree.physics_frame
		var d: float = target_x - x()
		if absf(d) <= 0.2:
			input.move_axis = 0.0
			await frames(8)
			return true
		var dir: float = signf(d)
		input.move_axis = 0.0 if _entering_unsafe(dir) else dir
	return false


func play() -> bool:
	var lv := level as UmbraxisLevel36
	boss = lv.boss
	stage = "chegada"
	await frames(40)
	stage = "etapa 1 (combinacao dos cristais)"
	for k in lv.lock.order.size():
		var idx: int = lv.lock.order[k]
		if not await safe_walk(UmbraxisLevel36.CRYSTAL_X[idx]):
			return false
		var before: int = lv.lock.progress
		if not await press_until(func() -> bool: return lv.lock.progress != before or lv.lock.is_unlocked):
			return false
	await frames(3)
	if boss.phase != VyrkanBoss.Phase.TWO:
		stage += " (fase=%d)" % boss.phase
		return false
	stage = "etapa 2 (pedra-eco real por evidencia)"
	if not await safe_walk(UmbraxisLevel36.STONE_X[0]):
		return false
	var real: EchoStone = await pick_real_stone(lv.stones)
	if real == null:
		stage += " (evidencia ambigua)"
		return false
	if not await safe_walk(real.position.x):
		return false
	if not await press_until(func() -> bool: return boss.phase == VyrkanBoss.Phase.THREE):
		return false
	stage = "etapa 3 (ruptura: estabilizar, atravessar, escalar, selar o nucleo)"
	if not await safe_walk(31.5):
		return false
	if not await swap_to(1):
		return false
	if not await run_to(41.0):
		return false
	if not await walk_to(42.0):
		return false
	if not await press_until(func() -> bool: return lv.stabilizer.is_active):
		return false
	if not await jump_at(45.3):
		return false
	for p in lv.platforms:
		if not await run_to((p as RupturePlatform).position.x + 0.8):
			return false
		if not await slow_hop():
			return false
	if not await climb(66.0, 5.0):
		return false
	if not await walk_to(70.0):
		return false
	if not await press_until(func() -> bool: return boss.phase == VyrkanBoss.Phase.FINISH):
		return false
	stage = "descer e Golpe Triade (3 herois)"
	if not await descend_slow():
		stage += " (descida)"
		return false
	if not await walk_to(74.0):
		stage += " (andar ao ponto 1, x=%.1f)" % x()
		return false
	if not await press_until(func() -> bool: return lv.triad.nodes[0].is_active):
		stage += " (ponto 1, x=%.1f ativo=%s)" % [x(), lv.triad.nodes[0].can_interact()]
		return false
	if not await swap_to(0):
		return false
	if not await walk_to(77.5):
		return false
	if not await press_until(func() -> bool: return lv.triad.nodes[1].is_active):
		return false
	if not await swap_to(2):
		return false
	if not await walk_to(81.0):
		return false
	if not await press_until(func() -> bool: return boss.is_defeated()):
		return false
	stage = "bau"
	if not await walk_to(86.0):
		return false
	return await press_until(func() -> bool: return level.controller.completed)
