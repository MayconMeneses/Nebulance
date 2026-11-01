class_name LevelBot22
extends LevelBot04
## Bot da fase 22 (herda LevelBot04, sem usar o play dele): Rocco abre a via, Zuri sobe o muro, Pipa planeia com o vento ate a passarela do
## sobrevivente (resgate), laje elevada com moedas e bau, sempre a frente da onda.

var min_gap: float = 999.0


func _track() -> void:
	var w: ChaseWave = (level as AquarysLevel22).wave
	min_gap = minf(min_gap, x() - w.position.x)


func _run(target_x: float) -> bool:
	input.move_axis = 1.0
	for i in 900:
		await tree.physics_frame
		_track()
		if x() >= target_x:
			return true
	return false


func play() -> bool:
	var lv := level as AquarysLevel22
	stage = "chegada"
	await frames(40)
	stage = "checkpoint e barreira marcada (Rocco)"
	if not await run_to(42.8):
		return false
	input.press_special()
	for i in 60:
		await tree.physics_frame
		_track()
		if lv.barrier.is_broken:
			break
	input.special_held = false
	if not lv.barrier.is_broken:
		return false
	stage = "Zuri sobe o muro"
	if not await _run(50.6):
		return false
	if not await swap_to(1):
		return false
	if not await _run(53.0):
		return false
	input.press_jump()
	input.jump_held = true
	for i in 40:
		await tree.physics_frame
		if body.velocity.y <= 0.5:
			break
	input.press_jump()
	input.jump_held = true
	await frames(30)
	input.jump_held = false
	if not await wait_floor() or body.global_position.y < 3.2:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	stage = "Pipa planeia com o vento"
	if not await swap_to(2):
		return false
	if not await _run(61.8):
		return false
	input.press_jump()
	input.jump_held = true
	await frames(18)
	input.press_special()
	var landed: bool = false
	for i in 240:
		await tree.physics_frame
		_track()
		if body.is_on_floor():
			landed = true
			break
	input.special_held = false
	input.jump_held = false
	if not landed or body.global_position.y < 3.2:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	input.move_axis = 0.0
	await frames(10)
	stage = "resgate do sobrevivente"
	if not await walk_to(75.5):
		return false
	for i in 30:
		input.press_interact()
		await tree.physics_frame
		_track()
		if lv.survivor.is_rescued:
			break
	if not lv.survivor.is_rescued:
		return false
	stage = "laje elevada"
	if not await jump_at(82.6):
		return false
	if not await _run(100.0):
		return false
	stage = "bau"
	if not await _run(115.4):
		return false
	input.move_axis = 0.0
	for i in 60:
		input.press_interact()
		await tree.physics_frame
		if level.controller.completed:
			return true
	return false
