extends RefCounted
## Fase 27 (Corredores do Vento): corrente que depende de painel + barreira, ilha oculta, reinicio no checkpoint e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	await _main_route_only(tree, out)
	return out


func _level(tree: SceneTree) -> AerionLevel27:
	var level := AerionLevel27.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel27 = _level(tree)
	await _settle(tree, 3)
	var body: ActorController = level.rig.body
	TestWorld.rec(out, "TC-052 fase 27: a primeira corrente e permanente; a segunda comeca parada e a ilha oculta nao existe",
			level.lift_a.is_blowing() and not level.lift_b.is_blowing() and not level.island.is_solid() and level.island.collision_layer == 0)
	# O checkpoint (depois da primeira travessia) e tocado ANTES de mexer em qualquer mecanismo: o estado salvo e o desligado.
	body.global_position = Vector3(25.0, 1.0, 0.0)
	await _settle(tree, 5)
	body.global_position = Vector3(50.5, 3.0, 0.0)
	await _settle(tree, 1)
	TestWorld.rec(out, "TC-052 fase 27: corrente parada nao ergue quem planeia (empurrao zero)", ZoneEffects.wind_push(body) == Vector3.ZERO)
	level.panel.interact()
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-052 fase 27: so o painel ligado NAO basta (a base da corrente continua coberta pela barreira)", not level.lift_b.is_blowing())
	TestWorld.rec(out, "TC-052 fase 27: ligar o painel NAO revela a ilha oculta (so a valvula que inverte a corrente a revela)", not level.island.is_solid())
	TestWorld.rec(out, "TC-052 fase 27: a corrente invertida comeca parada; ao acionar a valvula ela sopra PARA BAIXO (y negativo) e a ilha oculta aparece",
			not level.inverted.is_blowing() and level.inverted.wind_push == Vector3.ZERO and _invert(level, tree) and level.island.is_solid()
			and level.island.collision_layer == PhysicsLayers.WORLD and level.inverted.wind_push.y < 0.0)
	level.barrier.on_impacted()
	await _settle(tree, 2)
	body.global_position = Vector3(50.5, 3.0, 0.0)
	await _settle(tree, 1)
	TestWorld.rec(out, "TC-052 fase 27: painel ligado + barreira rompida: a segunda corrente sopra (y=23)",
			level.lift_b.is_blowing() and is_equal_approx(ZoneEffects.wind_push(body).y, 23.0))
	# Barreira rompida sem painel tambem nao basta: reinicia e testa so a barreira.
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-052 fase 27: reaparecer no checkpoint devolve painel, barreira, corrente e ilha ao estado do checkpoint (todos desligados/inteiros)",
			not level.panel.is_active and not level.barrier.is_broken and not level.lift_b.is_blowing() and not level.island.is_solid()
			and not level.valve.is_active and not level.inverted.is_blowing())
	level.barrier.on_impacted()
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-052 fase 27: so a barreira rompida (sem painel) NAO liga a corrente", not level.lift_b.is_blowing())
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-052 fase 27: reiniciar de novo e idempotente", not level.barrier.is_broken and not level.panel.is_active)
	TestWorld.rec(out, "TC-052 fase 27: pista do portal secreto (memoria), bau e 9 moedas com ids estaveis",
			level.definition.secret_memory_ids == PackedStringArray(["memory_secret_portal_clue_27"]) and level.definition.coin_ids.size() == 9
			and level.definition.chest_id == &"aerion_27_chest")
	level.queue_free()
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel27 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot27.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 27 (planeio, painel, barreira, corredor, valvula, ilha oculta, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 27 com 9 moedas e a pista do portal, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.memory_ids == ["memory_secret_portal_clue_27"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("aerion_27") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()


## Aciona a valvula e deixa o quadro seguir; devolve verdadeiro se ficou ativa (usado dentro de uma checagem).
func _invert(level: AerionLevel27, tree: SceneTree) -> bool:
	level.valve.interact()
	level.inverted._apply()
	level.island._apply()
	return level.valve.is_active


## A pista do portal e segredo de verdade: a rota principal inteira (sem a valvula e a ilha) termina a fase sem ela.
func _main_route_only(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel27 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot27.new(tree, level)
	bot.take_clue = false
	var finished: bool = await bot.play()
	TestWorld.rec(out, "TC-052 fase 27: a rota principal completa a fase SEM a pista do portal (exige a valvula e a ilha oculta)",
			finished and level.controller.session.memory_ids.is_empty(),
			"(etapa=%s x=%.1f y=%.1f memorias=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.controller.session.memory_ids])
	level.queue_free()
	await _settle(tree, 3)
