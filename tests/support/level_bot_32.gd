class_name LevelBot32
extends LevelBotUmbraxis
## Bot da fase 32: atravessa os cinco modulos (barreira, plataforma movel, esteira+elevadores, mare, muro+planeio) e abre o bau.


func play() -> bool:
	var lv := level as UmbraxisLevel32
	stage = "chegada"
	await frames(40)
	stage = "modulo Sylvara (barreira de Rocco)"
	if not await do_barrier(lv.barrier_mod, UmbraxisLevel32.OX_BARRIER):
		return false
	stage = "modulo Cristalia (plataforma movel)"
	if not await do_moving(lv.moving_mod, UmbraxisLevel32.OX_MOVING):
		return false
	stage = "modulo Mecatron (esteira e elevadores)"
	if not await do_belt_lift(lv.belt_mod, UmbraxisLevel32.OX_BELT):
		return false
	stage = "modulo Aquarys (mare)"
	if not await do_tide(lv.tide_mod, UmbraxisLevel32.OX_TIDE):
		return false
	stage = "modulo Aerion (muro e planeio)"
	if not await do_glide(UmbraxisLevel32.OX_GLIDE):
		return false
	stage = "bau"
	if not await run_to(177.0):
		return false
	if not await walk_to(179.9):
		return false
	return await press_until(func() -> bool: return level.controller.completed)
