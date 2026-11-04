class_name LevelBot11
extends LevelBot07
## Bot da fase 11: prisma abre a parede de luz, Zuri escala a torre, aciona os dois mecanismos sincronizados e abre o bau no arquivo.


func play() -> bool:
	var lv := level as CristaliaLevel11
	stage = "chegada"
	await frames(40)
	stage = "prisma (parede de luz)"
	if not await run_to(9.4):
		return false
	if not await walk_to(10.0):
		return false
	if not await set_prism(lv.prism, 0):
		return false
	await frames(6)
	stage = "corredor e checkpoint"
	if not await run_to(36.6):
		return false
	stage = "trocar para Zuri e escalar a torre"
	if not await swap_to(1):
		return false
	if not await walk_to(39.3):
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
	stage = "mecanismos sincronizados"
	if not await run_to(42.4):
		return false
	if not await walk_to(43.0):
		return false
	for i in 30:
		input.press_interact()
		await tree.physics_frame
		if lv.mech_a.is_active:
			break
	if not lv.mech_a.is_active:
		return false
	if not await run_to(50.4):
		return false
	if not await walk_to(51.0):
		return false
	for i in 30:
		input.press_interact()
		await tree.physics_frame
		if lv.sync_gate.is_open:
			break
	if not lv.sync_gate.is_open:
		stage += " (portao fechado)"
		return false
	stage = "salao do arquivo e bau"
	if not await run_to(60.0):
		return false
	return await ExtensionRunner.finish(self)
