class_name LevelBot26
extends LevelBotAerion
## Bot da fase 26: Pipa planeia a 1a lacuna, Rocco rompe a barreira, Zuri escala a estrutura, Pipa planeia a 2a lacuna.
## Com `take_cloud`, antes Zuri escala a 2a face ate a ilha de nuvem (item) e Pipa planeia dela ate a ilha do bau (rota opcional).

var take_cloud: bool = true


func play() -> bool:
	var lv := level as AerionLevel26
	stage = "chegada"
	await frames(40)
	stage = "primeira lacuna (Pipa planeia)"
	if not await run_to(12.6):
		return false
	if not await glide_across(13.7, 22.8, 0.3):
		return false
	stage = "barreira marcada (Rocco)"
	if not await break_barrier(28.6, lv.barrier):
		return false
	stage = "moeda sob a estrutura flutuante"
	if not await run_to(40.5):
		return false
	if not await run_left_to(36.0):
		return false
	input.move_axis = 0.0
	stage = "estrutura que flutua (Zuri escala)"
	if not await climb_to(37.4, 5.0):
		return false
	if take_cloud:
		stage = "rota nas nuvens (Zuri escala a 2a face)"
		if not await walk_to(44.5):
			return false
		if not await climb_to(45.4, 9.75):
			return false
		if not await run_to(49.5):
			return false
		stage = "rota nas nuvens (Pipa planeia ate o bau)"
		if not await glide_across(52.0, 55.8, 5.3):
			return false
		# Do alto da nuvem o planeio vai mais longe: volta pelas moedas da ilha do bau.
		if x() > 63.5 and not await run_left_to(57.5):
			return false
	else:
		stage = "segunda lacuna (Pipa planeia)"
		if not await walk_to(45.0):
			return false
		if not await glide_across(45.7, 54.8, 5.3):
			return false
	stage = "bau"
	if not await run_to(71.4):
		return false
	input.move_axis = 0.0
	return await press_until(func() -> bool: return level.controller.completed)
