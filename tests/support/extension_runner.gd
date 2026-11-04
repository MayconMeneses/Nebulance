class_name ExtensionRunner
extends RefCounted
## Executa a ROTA do trecho extra da fase (level.extension.get("route", []), ver ExtCursor) usando SOMENTE intents do bot, e termina no bau.
## Cada passo falho grava o motivo em `bot.stage`; a fisica decide se a fase e atravessavel (nao ha teleporte).


## `visit` (opcional): passo extra feito junto ao bau novo antes de abri-lo (ex.: o portal que fica ALEM do bau na fase 09).
static func finish(bot: LevelBot, visit: Callable = Callable()) -> bool:
	for s in bot.level.extension.get("route", []):
		bot.stage = "trecho extra: %s (x=%.1f)" % [s["op"], bot.x()]
		if not await _do(bot, s):
			bot.stage += " FALHOU em x=%.1f y=%.2f" % [bot.x(), bot.body.global_position.y]
			return false
	bot.stage = "bau do trecho extra"
	var chest: Chest = bot.level.find_children("*", "Chest", true, false)[0] as Chest
	if not await bot.run_to(chest.global_position.x - 0.4):
		return false
	if visit.is_valid():
		if not await visit.call():
			return false
		bot.stage = "volta ao bau do trecho extra"
		if bot.x() > chest.global_position.x + 0.6 and not await bot.run_left_to(chest.global_position.x + 0.6):
			return false
		if not await bot.walk_to(chest.global_position.x - 0.2):
			return false
	bot.input.move_axis = 0.0
	for i in 90:
		bot.input.press_interact()
		await bot.tree.physics_frame
		if bot.level.controller.completed:
			return true
	return false


static func _do(bot: LevelBot, s: Dictionary) -> bool:
	match s["op"]:
		&"hero": return await _hero(bot, int(s["index"]))
		&"hop": return await _hop(bot, float(s["x"]), float(s["land"]))
		&"cross": return await bot.cross_enemy(float(s["x"]), s["enemy"])
		&"special": return await _special(bot, s)
		&"dbl": return await _double_jump(bot, s)
		&"glide": return await _glide(bot, float(s["x"])) and bot.x() >= float(s["to"])
		&"rupt": return await _rupture(bot, s)
		&"tap": return await _tap(bot, float(s["x"]))
	return false


## Salto com o ar controlado: corre ate `x`, salta e freia no ar perto do centro da plataforma de destino (nao passa direto das mais curtas).
static func _hop(bot: LevelBot, x: float, land: float) -> bool:
	if not await bot.run_to(x):
		return false
	bot.input.press_jump()
	bot.input.jump_held = true
	await bot.wait_airborne()
	for i in 150:
		await bot.tree.physics_frame
		if bot.x() >= land - 0.8:
			bot.input.move_axis = 0.0
		if bot.body.is_on_floor():
			break
	bot.input.jump_held = false
	bot.input.move_axis = 0.0
	await bot.frames(8)
	return bot.body.is_on_floor() and bot.x() >= land - 2.0


static func _hero(bot: LevelBot, index: int) -> bool:
	## A troca anda um heroi por vez: repete ate chegar (Rocco -> Pipa leva duas).
	bot.input.move_axis = 0.0
	await bot.wait_floor()
	await bot.frames(30)
	for i in 8:
		var now: int = bot.level.rig.active_index
		if now == index:
			return true
		await bot.swap_to(now + (1 if index > now else -1))
		await bot.frames(20)
	return bot.level.rig.active_index == index


static func _special(bot: LevelBot, s: Dictionary) -> bool:
	if not await bot.run_to(float(s["x"])):
		return false
	bot.input.press_special()
	for i in 90:
		await bot.tree.physics_frame
		if (s["barrier"] as ImpactBarrier).is_broken:
			break
	bot.input.special_held = false
	return (s["barrier"] as ImpactBarrier).is_broken


static func _double_jump(bot: LevelBot, s: Dictionary) -> bool:
	if not await bot.run_to(float(s["x"])):
		return false
	bot.input.press_jump()
	bot.input.jump_held = true
	for i in 40:
		await bot.tree.physics_frame
		if bot.body.velocity.y <= 0.5:
			break
	bot.input.press_jump()
	bot.input.jump_held = true
	await bot.frames(30)
	bot.input.jump_held = false
	return await bot.wait_floor() and bot.body.global_position.y >= float(s["top"]) + 0.3


static func _glide(bot: LevelBot, x: float) -> bool:
	if not await bot.run_to(x):
		return false
	bot.input.press_jump()
	bot.input.jump_held = true
	await bot.frames(18)
	bot.input.press_special()
	var landed: bool = false
	for i in 300:
		await bot.tree.physics_frame
		if bot.body.is_on_floor():
			landed = true
			break
	bot.input.special_held = false
	bot.input.jump_held = false
	await bot.frames(10)
	return landed


## Espera a plataforma de ruptura alvo ficar solida por tempo suficiente e salta para ela da borda da anterior.
static func _rupture(bot: LevelBot, s: Dictionary) -> bool:
	var plat: RupturePlatform = s["plat"]
	if not await bot.run_to(float(s["x"])):
		return false
	bot.input.move_axis = 0.0
	for i in 600:
		await bot.tree.physics_frame
		if plat.is_solid() and plat.solid_remaining() >= 2.0:
			break
	return await _hop_short(bot)


## Corre ate `x` e da o saltinho curto (usado para sair da ultima plataforma de ruptura).
static func _tap(bot: LevelBot, x: float) -> bool:
	if not await bot.run_to(x):
		return false
	return await _hop_short(bot)


## Saltinho curto (solta o botao logo): nao passa direto das plataformas estreitas, qualquer heroi cobre os 1,5 m do vao.
static func _hop_short(bot: LevelBot) -> bool:
	bot.input.move_axis = 1.0
	bot.input.press_jump()
	bot.input.jump_held = false
	await bot.wait_airborne()
	return await bot.wait_floor()
