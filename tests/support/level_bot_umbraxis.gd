class_name LevelBotUmbraxis
extends LevelBotUmbraxisBase
## Bots de Umbraxis: os modulos reaproveitados das fases de origem (ver UmbraxisModules) e a identificacao das pedras-eco por EVIDENCIA
## (pisca ou forma), nunca pelo campo `is_real`. Os passos basicos (saltos, escalada, planeio) ficam em LevelBotUmbraxisBase.


# ---- modulos (ver UmbraxisModules) ----

func do_barrier(info: Dictionary, ox: float) -> bool:
	if not await swap_to(0):
		return false
	if not await run_to(ox + 6.8):
		return false
	input.press_special()
	for i in 60:
		await tree.physics_frame
		if (info["barrier"] as ImpactBarrier).is_broken:
			break
	input.special_held = false
	if not (info["barrier"] as ImpactBarrier).is_broken:
		return false
	return await run_to(ox + 19.0)


func do_moving(info: Dictionary, ox: float) -> bool:
	if not await swap_to(0):
		return false
	var mp: MovingPlatform = info["mp"]
	if mp == null:
		return await run_to(ox + 33.0)
	if not await run_to(ox + 11.0):
		return false
	if not await walk_to(ox + 13.3):
		return false
	await wait_platform(mp, ox + 17.0)
	if not await hop_right():
		return false
	await wait_platform(mp, ox + 21.0)
	if not await hop_right():
		return false
	return await run_to(ox + 33.0)


func do_belt_lift(info: Dictionary, ox: float) -> bool:
	if not await swap_to(0):
		return false
	if not await run_to(ox + 21.8):
		return false
	if not await ride(info["up"], ox + 23.5):
		return false
	if not await run_to(ox + 40.4 - 0.0):
		return false
	if not await ride(info["down"], ox + 41.5):
		return false
	if not await wait_floor() or body.global_position.y > 1.2:
		return false
	return await run_to(ox + 44.0)


func do_tide(info: Dictionary, ox: float) -> bool:
	if not await run_to(ox + 13.4):
		return false
	if not await walk_to(ox + 14.0):
		return false
	if not await set_tide(info["control"]):
		return false
	return await run_to(ox + 36.0)


func do_glide(ox: float) -> bool:
	if not await run_to(ox + 4.6):
		return false
	if not await swap_to(1):
		return false
	if not await run_to(ox + 7.0):
		return false
	if not await double_jump_up(3.2):
		stage += " (muro)"
		return false
	if not await swap_to(2):
		return false
	if not await run_to(ox + 15.8):
		return false
	if not await pipa_glide(3.2):
		return false
	return await run_to(ox + 33.0)


func do_bridge(info: Dictionary, ox: float) -> bool:
	if not await swap_to(1):
		return false
	if not await run_to(ox + 15.0):
		return false
	if not await walk_to(ox + 16.0):
		return false
	var st: Mechanism = info["stabilizer"]
	if not await press_until(func() -> bool: return st.is_active):
		return false
	if not await jump_at(ox + 19.3):
		return false
	var platforms: Array = info["platforms"]
	for p in platforms:
		if not await run_to((p as RupturePlatform).position.x + 0.8):
			return false
		if not await slow_hop():
			return false
	return true


# ---- ilusoes ----

## Observa as pedras por ~1 s e devolve a unica que nunca piscou e tem forma cheia; null se a evidencia for ambigua.
func pick_real_stone(stones: Array) -> EchoStone:
	var fake: Dictionary = {}
	for i in 70:
		await tree.physics_frame
		for s in stones:
			var st: EchoStone = s
			if not st.steady() or st.body_scale() != Vector3.ONE:
				fake[st] = true
	var real: Array = stones.filter(func(s: EchoStone) -> bool: return not fake.has(s))
	return real[0] if real.size() == 1 else null


func touch_stone(stone: EchoStone) -> bool:
	if not await walk_to(stone.position.x):
		return false
	return await press_until(func() -> bool: return stone.solved)
