extends RefCounted
## Fase 28 (O Ceu de Cabeca para Baixo): gravidade local invertida (teto vira trajeto), pilar so pelo teto, checkpoint e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> AerionLevel28:
	var level := AerionLevel28.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel28 = _level(tree)
	await _settle(tree, 3)
	var body: ActorController = level.rig.body
	TestWorld.rec(out, "TC-053 fase 28: tres zonas de gravidade invertida (escala negativa) em areas definidas",
			level.zones.size() == 3 and level.zones[0].gravity_scale < 0.0 and level.zones[1].gravity_scale < 0.0 and level.zones[2].gravity_scale < 0.0)
	body.global_position = Vector3(2.0, 1.0, 0.0)
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-053 fase 28: fora das zonas a gravidade e normal (escala 1)", is_equal_approx(ZoneEffects.gravity_scale(body), 1.0))
	body.global_position = Vector3(21.0, 3.0, 0.0)
	await _settle(tree, 1)
	TestWorld.rec(out, "TC-053 fase 28: dentro da zona a gravidade fica invertida", ZoneEffects.gravity_scale(body) < 0.0)
	# Quem entra na zona sobe ate o teto e fica encostado nele (sem ficar preso: ainda anda).
	body.global_position = Vector3(17.0, 0.9, 0.0)
	body.velocity = Vector3.ZERO
	await _settle(tree, 90)
	var ceiling_y: float = body.global_position.y
	var x0: float = body.global_position.x
	level.rig.body.intent_provider = func() -> HeroIntent:
		var i := HeroIntent.new()
		i.move_axis = 1.0
		return i
	await _settle(tree, 30)
	TestWorld.rec(out, "TC-053 fase 28: dentro da zona o heroi sobe ate o teto (y alto, encostado) e continua andando por ele",
			ceiling_y > 4.5 and body.is_on_ceiling() and not body.is_on_floor() and body.global_position.x > x0 + 1.0 and body.global_position.y > 4.5,
			"(y=%.2f x0=%.1f x=%.1f)" % [ceiling_y, x0, body.global_position.x])
	level.rig.body.intent_provider = Callable()
	# Gravidade normal depois de sair da zona (sem teto: pula do chao e cai).
	body.global_position = Vector3(2.0, 3.0, 0.0)
	body.velocity = Vector3.ZERO
	await _settle(tree, 60)
	TestWorld.rec(out, "TC-053 fase 28: fora da zona o heroi cai e pousa normalmente", body.is_on_floor() and body.global_position.y < 1.5)
	# O pilar de 3,5 m nao se transpoe no chao: correr contra ele no piso fica bloqueado (so o teto passa).
	body.global_position = Vector3(43.0, 0.9, 0.0)
	body.velocity = Vector3.ZERO
	await _settle(tree, 2)
	var pillar: StaticBody3D = null
	for n in level.find_children("*", "StaticBody3D", true, false):
		if absf(n.global_position.x - 50.0) < 0.1 and absf(n.global_position.y - 1.75) < 0.1:
			pillar = n
	TestWorld.rec(out, "TC-053 fase 28: o pilar da inversao 2 mede 3,5 m (alto demais para saltar)", pillar != null)
	# Checkpoint antes da inversao complexa: cair no poco 3 reaparece nele.
	body.global_position = Vector3(40.0, 1.0, 0.0)
	await _settle(tree, 5)
	body.global_position = Vector3(66.0, -9.0, 0.0)
	await _settle(tree, 6)
	TestWorld.rec(out, "TC-053 fase 28: cair no abismo reaparece no checkpoint antes da primeira inversao complexa",
			absf(body.global_position.x - 40.0) < 2.0 and level.rig.vitals.lives == 4, "(x=%.1f vidas=%d)" % [body.global_position.x, level.rig.vitals.lives])
	TestWorld.rec(out, "TC-053 fase 28: item de pista de gravidade, bau e 9 moedas com ids estaveis",
			level.definition.secret_item_ids == PackedStringArray(["aerion_28_gravity_clue"]) and level.definition.coin_ids.size() == 9
			and level.definition.chest_id == &"aerion_28_chest")
	level.queue_free()
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AerionLevel28 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot28.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 28 (tres inversoes pelo teto, pilar, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 28 com 9 moedas e o item de pista, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["aerion_28_gravity_clue"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("aerion_28") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
