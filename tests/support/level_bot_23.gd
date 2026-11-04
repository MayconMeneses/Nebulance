class_name LevelBot23
extends LevelBot19
## Bot da fase 23: sobe o Oeste, cruza ate o templo, ajusta Oeste=1 e Leste=2 (acende o fluxo), cruza o Leste, passa a porta, memoria e bau.


func play() -> bool:
	var lv := level as AquarysLevel23
	stage = "chegada"
	await frames(40)
	stage = "comporta Oeste (nivel 2)"
	if not await run_to(11.4):
		return false
	if not await walk_to(12.0):
		return false
	if not await set_tide(lv.west_raise):
		return false
	stage = "plataformas do Oeste"
	if not await run_to(30.4):
		return false
	stage = "combinacao: Oeste nivel 1"
	if not await walk_to(31.0):
		return false
	if not await set_tide(lv.west_mid):
		return false
	stage = "combinacao: Leste nivel 2"
	if not await run_to(42.4):
		return false
	if not await walk_to(43.0):
		return false
	if not await set_tide(lv.east_high):
		return false
	if not lv.flux.is_lit():
		stage += " (fluxo apagado)"
		return false
	stage = "plataformas do Leste e porta"
	if not await run_to(75.0):
		return false
	stage = "memoria e bau"
	if not await run_to(89.4):
		return false
	input.move_axis = 0.0
	return await ExtensionRunner.finish(self)
