class_name LevelBot34
extends LevelBotUmbraxis
## Bot da fase 34: Rocco cruza a prensa-raiz e quebra a barreira; Zuri escala, cruza as plataformas temporarias, resgata o sobrevivente,
## escala de novo e abre o bau no patamar final.


func play() -> bool:
	var lv := level as UmbraxisLevel34
	stage = "chegada"
	await frames(40)
	stage = "prensa-raiz sinalizada"
	if not await run_to(9.0):
		return false
	if not await walk_to(lv.press.position.x - 3.2):
		return false
	if not await cross_press(lv.press):
		return false
	stage = "barreira de Caeldron (Rocco)"
	if not await run_to(22.8):
		return false
	input.press_special()
	for i in 60:
		await tree.physics_frame
		if lv.barrier.is_broken:
			break
	input.special_held = false
	if not lv.barrier.is_broken:
		return false
	stage = "checkpoint e primeira escalada"
	if not await run_to(35.0):
		return false
	if not await swap_to(1):
		return false
	if not await run_to(38.0):
		return false
	if not await climb(40.0, 5.0):
		return false
	stage = "plataformas temporarias"
	var p: Array = lv.platforms
	if not await swap_to(0):
		return false
	if not await stand_at(45.4):
		return false
	if not await hop(null, p[0], p[0].position.x - 1.4, 3.0):
		return false
	if not await stand_at(p[0].position.x + 1.1):
		return false
	if not await hop(p[0], p[1], p[1].position.x - 1.4, 3.0):
		return false
	if not await stand_at(p[1].position.x + 1.1):
		return false
	if not await hop(p[1], p[2], p[2].position.x - 1.4, 3.0):
		return false
	if not await stand_at(p[2].position.x + 1.1):
		return false
	if not await hop(p[2], null, 61.5, 3.0):
		return false
	stage = "resgate opcional"
	if not await walk_to(64.0):
		return false
	if not await press_until(func() -> bool: return lv.survivor.is_rescued):
		return false
	stage = "segunda escalada e bau"
	if not await swap_to(1):
		return false
	if not await climb(68.0, 10.0):
		return false
	if not await run_to(72.6):
		return false
	if not await walk_to(73.1):
		return false
	return await ExtensionRunner.finish(self)
