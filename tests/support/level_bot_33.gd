class_name LevelBot33
extends LevelBotUmbraxis
## Bot da fase 33: identifica a pedra-eco verdadeira por EVIDENCIA (pisca / forma), cruza as plataformas estabilizadas, Zuri le a inscricao
## (abre o portal), pega o traje e abre o bau depois do arquivo da tripulacao.


func fork(stones: Array, platforms: Array, edge_x: float) -> bool:
	var real: EchoStone = await pick_real_stone(stones)
	if real == null:
		stage += " (evidencia ambigua)"
		return false
	if not await touch_stone(real):
		return false
	if not await jump_at(edge_x):
		return false
	for p in platforms:
		if not await run_to((p as RupturePlatform).position.x + 0.8):
			return false
		if not await slow_hop():
			return false
	return true


func play() -> bool:
	var lv := level as UmbraxisLevel33
	stage = "chegada"
	await frames(40)
	if not await swap_to(1):
		return false
	stage = "primeiro conjunto de ecos (pisca)"
	if not await run_to(18.0):
		return false
	if not await fork(lv.stones_a, lv.platforms_a, 31.3):
		return false
	stage = "segundo conjunto de ecos (forma)"
	if not await run_to(49.0):
		return false
	if not await fork(lv.stones_b, lv.platforms_b, 65.3):
		return false
	stage = "inscricao e traje"
	if not await climb(82.0, 5.0):
		return false
	if not await walk_to(86.0):
		return false
	if not await press_until(func() -> bool: return lv.inscription.is_active):
		return false
	if not await run_to(88.2):
		return false
	if not await descend_slow():
		return false
	stage = "arquivo e bau"
	if not await run_to(105.0):
		return false
	if not await run_left_to(101.7):
		return false
	if not await walk_to(100.2):
		return false
	return await press_until(func() -> bool: return level.controller.completed)
