class_name LevelBot28
extends LevelBotAerion
## Bot da fase 28: cruza tres zonas de gravidade invertida seguindo o teto (poco, pilar e poco longo) e abre o bau.


func _ceiling_leg(until_x: float, label: String) -> bool:
	stage = label
	if not await run_to(until_x):
		return false
	input.move_axis = 0.0
	if not await wait_floor():
		stage += " (x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	return body.global_position.y > -1.0


func play() -> bool:
	stage = "chegada"
	await frames(40)
	if not await _ceiling_leg(29.0, "inversao 1 (poco)"):
		return false
	stage = "checkpoint"
	if not await run_to(39.5):
		return false
	if not await _ceiling_leg(57.0, "inversao 2 (pilar, pelo teto)"):
		return false
	if not await _ceiling_leg(76.0, "inversao 3 (poco longo)"):
		return false
	stage = "bau"
	if not await run_to(85.4):
		return false
	input.move_axis = 0.0
	return await ExtensionRunner.finish(self)
