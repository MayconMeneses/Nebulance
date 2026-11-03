extends RefCounted
## Fase 25 (O Porto das Nuvens): vento direcional de popa, plataformas suspensas, checkpoint apos a primeira corrente, ids e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	await _main_route_only(tree, out)
	return out


func _level(tree: SceneTree) -> AerionLevel25:
	var level := AerionLevel25.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _drop_at(level: AerionLevel25, tree: SceneTree, pos: Vector3, frames: int) -> float:
	level.rig.body.global_position = pos
	level.rig.body.velocity = Vector3.ZERO
	for i in frames:
		await tree.physics_frame
	return level.rig.body.velocity.x


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel25 = _level(tree)
	await _settle(tree, 3)
	var body: ActorController = level.rig.body
	level.rig.body.global_position = Vector3(17.5, 3.0, 0.0)
	await _settle(tree, 1)
	TestWorld.rec(out, "TC-050 fase 25: a corrente do vao empurra para frente (+x) so dentro da zona de vento",
			is_equal_approx(ZoneEffects.wind_push(body).x, 40.0) and ZoneEffects.wind_push(body).y == 0.0)
	var in_wind: float = await _drop_at(level, tree, Vector3(15.5, 6.0, 0.0), 8)
	var no_wind: float = await _drop_at(level, tree, Vector3(5.0, 6.0, 0.0), 8)
	TestWorld.rec(out, "TC-050 fase 25: quem esta no ar dentro da corrente ganha velocidade para frente; fora dela nao",
			in_wind > 1.0 and absf(no_wind) < 0.1, "(com vento vx=%.2f sem vento vx=%.2f)" % [in_wind, no_wind])
	level.rig.body.global_position = Vector3(5.0, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 20)
	TestWorld.rec(out, "TC-050 fase 25: no chao o vento nao arrasta o heroi (so afeta quem esta no ar)",
			absf(body.velocity.x) < 0.1 and body.is_on_floor())
	# Checkpoint depois da primeira corrente: cair no vao reaparece nele.
	level.rig.body.global_position = Vector3(23.5, 1.0, 0.0)
	await _settle(tree, 5)
	level.rig.body.global_position = Vector3(17.0, -9.0, 0.0)
	await _settle(tree, 6)
	TestWorld.rec(out, "TC-050 fase 25: cair no vao depois de passar o checkpoint reaparece nele",
			level.rig.body.global_position.x >= 22.0 and level.rig.vitals.lives == 4,
			"(x=%.1f vidas=%d)" % [level.rig.body.global_position.x, level.rig.vitals.lives])
	TestWorld.rec(out, "TC-050 fase 25: bau, item Horizonte e 9 moedas com ids estaveis",
			level.definition.chest_id == &"aerion_25_chest" and level.definition.secret_item_ids == PackedStringArray(["aerion_25_horizon_item"])
			and level.definition.coin_ids.size() == 9 and level.definition.checkpoint_ids == PackedStringArray(["aerion_25_cp1"]))
	level.queue_free()
	await _settle(tree, 3)
	# Controle: sem o vento o mesmo salto NAO atravessa o vao de 7 m (o vento e o que torna a travessia possivel).
	var calm: AerionLevel25 = _level(tree)
	await tree.physics_frame
	calm.tailwind.wind_on = Vector3.ZERO
	var probe := LevelBot25.new(tree, calm)
	await probe.frames(30)
	await probe.jump_at(13.4)
	await probe.frames(60)
	TestWorld.rec(out, "TC-050 fase 25: sem a corrente o salto no vao falha (cai e perde uma vida); a corrente e o que atravessa",
			calm.controller.session.lives_lost >= 1, "(vidas perdidas=%d)" % calm.controller.session.lives_lost)
	calm.queue_free()
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel25 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot25.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 25 (vento de popa, checkpoint, degraus suspensos, observatorio, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 25 com 9 moedas e o item Horizonte, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["aerion_25_horizon_item"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("aerion_25") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()


## O item Horizonte e segredo de verdade: a rota principal inteira (sem a escalada de Zuri) termina a fase sem ele.
func _main_route_only(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel25 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot25.new(tree, level)
	bot.take_secret = false
	var finished: bool = await bot.play()
	TestWorld.rec(out, "TC-050 fase 25: a rota principal completa a fase SEM pegar o item Horizonte (e segredo, exige a escalada de Zuri)",
			finished and level.controller.session.item_ids.is_empty(), "(itens=%s)" % [level.controller.session.item_ids])
	level.queue_free()
	await _settle(tree, 3)
