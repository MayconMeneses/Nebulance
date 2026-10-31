class_name LevelBot06
extends LevelBot
## Bot do chefe Vyrkan: so entra numa faixa de raizes quando ela e segura; cumpre as 3 etapas e o Golpe Triade com 3 herois.

var boss: VyrkanBoss
var arena: Node


func _init(scene_tree: SceneTree, target_level: LevelScene) -> void:
	super._init(scene_tree, target_level)
	arena = target_level
	boss = arena.boss


func _entering_unsafe(dir: float) -> bool:
	for i in VyrkanBoss.LANE_X.size():
		var lx: float = VyrkanBoss.LANE_X[i]
		var inside: bool = absf(x() - lx) <= 2.0
		var ahead: bool = absf((x() + dir * 1.6) - lx) <= 2.0
		if ahead and not inside and not boss.lane_safe(i, 1.0):
			return true
	return false


func safe_walk(target_x: float, speed: float = 1.0) -> bool:
	for i in 3000:
		await tree.physics_frame
		var d: float = target_x - x()
		if absf(d) <= 0.2:
			input.move_axis = 0.0
			await frames(8)
			return true
		var dir: float = signf(d)
		input.move_axis = 0.0 if _entering_unsafe(dir) else dir * speed
	return false


func swap_hero(index: int) -> bool:
	input.move_axis = 0.0
	await frames(4)
	for i in 4:
		if level.rig.active_index == index:
			return true
		input.swap(1 if index > level.rig.active_index else -1)
		await frames(8)
	return level.rig.active_index == index


func press_until(check: Callable) -> bool:
	for i in 40:
		input.press_interact()
		await tree.physics_frame
		if check.call():
			return true
	return false


func play() -> bool:
	stage = "chegada"
	await frames(40)
	stage = "etapa 1 (Rocco: apoio marcado)"
	input.move_axis = 0.0
	input.press_special()
	input.move_axis = 1.0
	await frames(30)
	input.special_held = false
	input.move_axis = 0.0
	if boss.phase != VyrkanBoss.Phase.TWO:
		stage += " (fase=%d)" % boss.phase
		return false
	stage = "atravessar a arena (esperando as faixas)"
	if not await safe_walk(27.2):
		return false
	stage = "etapa 2 (Zuri: escalar e mecanismo alto)"
	if not await swap_hero(1):
		return false
	if not await safe_walk(28.5, 0.5):
		return false
	input.special_held = true
	for i in 400:
		await tree.physics_frame
		if body.global_position.y - 0.75 >= 5.4:
			break
	input.special_held = false
	input.move_axis = 1.0
	if not await wait_floor() or body.global_position.y < 5.5:
		stage += " (x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	if not await walk_to(33.5):
		return false
	if not await press_until(func() -> bool: return arena.zuri_mechanism.is_active):
		return false
	stage = "etapa 3 (Pipa: planear com vento)"
	if not await swap_hero(2):
		return false
	if not await walk_to(29.6):
		return false
	input.move_axis = -1.0
	input.press_jump()
	input.jump_held = true
	await frames(18)
	input.press_special()
	var landed: bool = false
	for i in 260:
		await tree.physics_frame
		if body.is_on_floor():
			landed = true
			break
	input.move_axis = 0.0
	input.special_held = false
	input.jump_held = false
	if not landed or body.global_position.y < 5.3 or x() > 20.4 or x() < 13.6:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	await frames(10)
	if not await walk_to(18.0):
		return false
	if not await press_until(func() -> bool: return arena.pipa_mechanism.is_active):
		return false
	stage = "descer da plataforma (esperando a faixa)"
	if not await walk_to(15.0):
		return false
	for i in 400:
		await tree.physics_frame
		if boss.lane_safe(2, 1.6):
			break
	input.move_axis = -0.35
	for i in 200:
		await tree.physics_frame
		if not body.is_on_floor():
			break
	if not await wait_floor():
		return false
	input.move_axis = 0.0
	stage = "Golpe Triade (3 herois)"
	if not await safe_walk(11.5):
		return false
	if not await press_until(func() -> bool: return arena.triad.nodes[1].is_active):
		return false
	if not await swap_hero(0):
		return false
	if not await safe_walk(6.5):
		return false
	if not await press_until(func() -> bool: return arena.triad.nodes[0].is_active):
		return false
	if not await swap_hero(1):
		return false
	if not await safe_walk(16.5):
		return false
	if not await press_until(func() -> bool: return boss.is_defeated()):
		return false
	stage = "bau"
	if not await safe_walk(31.4):
		return false
	input.move_axis = 0.0
	for i in 60:
		input.press_interact()
		await tree.physics_frame
		if level.controller.completed:
			return true
	return false
