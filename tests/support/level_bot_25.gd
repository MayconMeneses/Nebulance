class_name LevelBot25
extends LevelBotAerion
## Bot da fase 25: salta no vao com vento de popa, passa o checkpoint, sobe os degraus suspensos ate o observatorio e abre o bau.


func play() -> bool:
	stage = "chegada"
	await frames(40)
	stage = "vao com vento de popa"
	if not await jump_at(13.4):
		return false
	if x() < 21.0:
		stage += " (x=%.1f)" % x()
		return false
	stage = "checkpoint e degraus suspensos"
	if not await run_to(28.2):
		return false
	if not await jump_at(28.4):
		return false
	if not await jump_at(33.6):
		return false
	if not await jump_at(38.8):
		return false
	stage = "observatorio e bau"
	if not await run_to(57.4):
		return false
	input.move_axis = 0.0
	return await press_until(func() -> bool: return level.controller.completed)
