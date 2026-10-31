class_name LevelBotS01
extends LevelBot
## Bot da S01 (gravidade baixa 0.4): cada salto tem o eixo calculado pela fisica para pousar no centro da proxima plataforma.

const G_LOW: float = 9.6
const V_JUMP: float = 8.5
const RUN: float = 5.5


## Salta de takeoff_x ate o centro `land_x` com desnivel `dh` (m); o eixo sai da duracao do voo em gravidade baixa.
func arc_hop(land_x: float, dh: float) -> bool:
	var t_air: float = (V_JUMP + sqrt(V_JUMP * V_JUMP - 2.0 * G_LOW * dh)) / G_LOW
	var axis: float = clampf((land_x - x()) / (RUN * t_air), 0.1, 1.0)
	input.move_axis = axis
	input.press_jump()
	input.jump_held = true
	await wait_airborne()
	var ok: bool = await wait_floor(240)
	input.jump_held = false
	input.move_axis = 0.0
	await frames(10)
	return ok and body.global_position.y > -1.0


func wait_solid(platform: RupturePlatform, need: float) -> void:
	for i in 900:
		await tree.physics_frame
		if platform.is_solid() and platform.solid_remaining() >= need:
			return


func play() -> bool:
	var rup: Array = level.find_children("*", "RupturePlatform", true, false)
	rup.sort_custom(func(a: Node3D, b: Node3D) -> bool: return a.position.x < b.position.x)
	stage = "chegada"
	await frames(40)
	stage = "salto 1 (degrau)"
	if not await walk_to(2.0) or not await arc_hop(5.0, 2.0):
		return false
	if not await walk_to(5.0) or not await walk_to(6.2):
		return false
	stage = "salto 2 (plataforma que se reorganiza)"
	await wait_solid(rup[0], 2.4)
	if not await arc_hop(11.0, 1.75):
		return false
	if not await walk_to(12.2):
		return false
	stage = "salto 3 (topo do jardim, itens)"
	if not await arc_hop(15.0, 2.25):
		return false
	if not await walk_to(14.9) or not await walk_to(16.0):
		return false
	stage = "salto 4 (plataforma que se reorganiza)"
	await wait_solid(rup[1], 2.8)
	if not await arc_hop(20.0, -2.25):
		return false
	if not await walk_to(21.2):
		return false
	stage = "salto 5"
	if not await arc_hop(25.0, -1.75):
		return false
	if not await walk_to(25.0) or not await walk_to(26.2):
		return false
	stage = "salto final e bau"
	if not await arc_hop(31.0, -2.0):
		return false
	if not await walk_to(30.0) or not await walk_to(32.8):
		return false
	for i in 60:
		input.press_interact()
		await tree.physics_frame
		if level.controller.completed:
			return true
	return false
