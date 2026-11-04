class_name LevelBot31
extends LevelBotUmbraxis
## Bot da fase 31: cruza as tres plataformas dimensionais esperando o momento solido, Zuri pega o fragmento na plataforma alta e vai ao bau.


func play() -> bool:
	var lv := level as UmbraxisLevel31
	var p: Array = lv.platforms
	stage = "chegada"
	await frames(40)
	if not await stand_at(15.4):
		return false
	stage = "plataformas dimensionais"
	if not await hop(null, p[0], 17.6):
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
	if not await hop(p[2], null, 31.5):
		return false
	if not await stand_at(32.4):
		return false
	stage = "Zuri: fragmento do Legado Celestial"
	if not await swap_to(1):
		return false
	if not await run_to(33.0):
		return false
	if not await double_jump_up(3.2):
		return false
	if not await run_to(43.0):
		return false
	if not await descend_slow():
		return false
	stage = "bau"
	if not await run_to(72.8):
		return false
	if not await walk_to(73.9):
		return false
	return await ExtensionRunner.finish(self)
