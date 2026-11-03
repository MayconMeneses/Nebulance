extends RefCounted
## Fase 26 (Os Jardins Suspensos): correntes ascendentes, barreira de Rocco, estrutura que flutua (Zuri), rota opcional nas nuvens (item), reinicio e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	await _main_route_only(tree, out)
	return out


func _level(tree: SceneTree) -> AerionLevel26:
	var level := AerionLevel26.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel26 = _level(tree)
	await _settle(tree, 3)
	var body: ActorController = level.rig.body
	body.global_position = Vector3(18.5, 3.0, 0.0)
	await _settle(tree, 1)
	TestWorld.rec(out, "TC-051 fase 26: as duas lacunas longas tem corrente ascendente sinalizada (y=23) e sem empurrao horizontal",
			is_equal_approx(ZoneEffects.wind_push(body).y, 23.0) and ZoneEffects.wind_push(body).x == 0.0 and level.lift_a.is_blowing() and level.lift_b.is_blowing())
	body.global_position = Vector3(50.5, 7.0, 0.0)
	await _settle(tree, 1)
	TestWorld.rec(out, "TC-051 fase 26: a segunda corrente fica ao lado da estrutura flutuante", is_equal_approx(ZoneEffects.wind_push(body).y, 23.0))
	body.global_position = Vector3(30.0, 1.0, 0.0)
	body.velocity = Vector3.ZERO
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-051 fase 26: a barreira marcada bloqueia o caminho ate o impacto de Rocco (inteira e solida)",
			not level.barrier.is_broken and level.barrier.collision_layer & PhysicsLayers.WORLD != 0)
	level.barrier.on_impacted()
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-051 fase 26: rompida, a barreira libera a passagem", level.barrier.is_broken and level.barrier.collision_layer == 0)
	# Checkpoint antes das lacunas longas; cair depois dele reaparece nele e a barreira volta ao estado do checkpoint.
	body.global_position = Vector3(12.0, 1.0, 0.0)
	await _settle(tree, 5)
	body.global_position = Vector3(18.0, -9.0, 0.0)
	await _settle(tree, 6)
	TestWorld.rec(out, "TC-051 fase 26: cair numa lacuna reaparece no checkpoint, com a barreira no estado capturado nele (rompida antes de tocar o checkpoint)",
			body.global_position.x >= 11.0 and body.global_position.x <= 14.0 and level.barrier.is_broken == true,
			"(x=%.1f)" % body.global_position.x)
	TestWorld.rec(out, "TC-051 fase 26: item das nuvens (rota opcional, ilha alta); 9 moedas; ids estaveis",
			level.definition.secret_item_ids == PackedStringArray(["aerion_26_cloud_seed"]) and level.definition.coin_ids.size() == 9
			and level.definition.chest_id == &"aerion_26_chest")
	level.queue_free()
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel26 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot26.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 26 pela rota das nuvens (Pipa planeia, Rocco rompe, Zuri escala duas vezes, Pipa planeia, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 26 com 9 moedas e o item das nuvens, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["aerion_26_cloud_seed"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("aerion_26") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()


## A rota nas nuvens e opcional: a rota principal completa a fase sem o item (ele exige a 2a escalada de Zuri e a ilha alta).
func _main_route_only(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel26 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot26.new(tree, level)
	bot.take_cloud = false
	var finished: bool = await bot.play()
	TestWorld.rec(out, "TC-051 fase 26: a rota principal completa a fase SEM o item das nuvens (a rota opcional exige a 2a escalada de Zuri)",
			finished and level.controller.session.item_ids.is_empty(),
			"(etapa=%s x=%.1f y=%.1f itens=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.controller.session.item_ids])
	level.queue_free()
	await _settle(tree, 3)
