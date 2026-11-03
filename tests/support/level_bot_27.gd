class_name LevelBot27
extends LevelBotAerion
## Bot da fase 27: Pipa planeia a 1a travessia, Zuri liga o painel, Rocco libera a base, Pipa planeia o corredor.
## Com `take_clue`, antes do bau aciona a valvula (inverte a corrente) e pega a pista na ilha oculta (segredo).

var take_clue: bool = true


func play() -> bool:
	var lv := level as AerionLevel27
	stage = "chegada"
	await frames(40)
	stage = "primeira travessia (Pipa guia)"
	if not await run_to(12.6):
		return false
	if not await glide_across(13.7, 22.8, 0.3):
		return false
	stage = "painel de vento no alto (Zuri)"
	if not await run_to(25.4):
		return false
	if not await climb_to(27.4, 5.0):
		return false
	if not await walk_to(31.0):
		return false
	if not await press_until(func() -> bool: return lv.panel.is_active):
		return false
	stage = "descer e liberar a base (Rocco)"
	if not await run_to(35.0):
		return false
	input.move_axis = 0.0
	if not await wait_floor():
		return false
	if not await break_barrier(36.2, lv.barrier):
		return false
	if not lv.lift_b.is_blowing():
		stage += " (corrente ainda parada)"
		return false
	stage = "corredor do vento (Pipa planeia)"
	if not await glide_across(45.7, 54.8, 0.3):
		return false
	if take_clue:
		stage = "valvula e ilha oculta (pista do portal)"
		if not await walk_to(57.0):
			return false
		if not await press_until(func() -> bool: return lv.valve.is_active):
			return false
		if not await jump_at(59.6):
			return false
		if not lv.island.is_solid() or not "memory_secret_portal_clue_27" in level.controller.session.memory_ids:
			stage += " (x=%.1f y=%.2f)" % [x(), body.global_position.y]
			return false
	stage = "bau"
	if not await run_to(83.4):
		return false
	input.move_axis = 0.0
	return await press_until(func() -> bool: return level.controller.completed)
