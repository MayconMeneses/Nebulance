class_name LevelBot35
extends LevelBotUmbraxis
## Bot da fase 35: ponte de ruptura (Zuri), plataforma movel, esteira+elevadores, mare, muro+planeio e o terminal dos exploradores.


func play() -> bool:
	var lv := level as UmbraxisLevel35
	stage = "chegada"
	await frames(40)
	stage = "Sylvara: ponte de ruptura estabilizada"
	if not await do_bridge(lv.bridge_mod, UmbraxisLevel35.OX_BRIDGE):
		return false
	stage = "Cristalia: plataforma movel"
	if not await do_moving(lv.moving_mod, UmbraxisLevel35.OX_MOVING):
		return false
	stage = "Mecatron: esteira e elevadores"
	if not await do_belt_lift(lv.belt_mod, UmbraxisLevel35.OX_BELT):
		return false
	stage = "Aquarys: mare"
	if not await do_tide(lv.tide_mod, UmbraxisLevel35.OX_TIDE):
		return false
	stage = "Aerion: muro e planeio"
	if not await do_glide(UmbraxisLevel35.OX_GLIDE):
		return false
	stage = "terminal dos exploradores"
	if not await run_to(UmbraxisLevel35.TERMINAL_X - 1.0):
		return false
	if not await walk_to(UmbraxisLevel35.TERMINAL_X):
		return false
	if not await press_until(func() -> bool: return lv.terminal.is_active):
		return false
	stage = "mensagem e bau"
	if not await run_to(208.0):
		return false
	if not await walk_to(212.0):
		return false
	return await press_until(func() -> bool: return level.controller.completed)
