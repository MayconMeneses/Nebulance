extends RefCounted
## Fase 21 (Os Recifes Esquecidos): correntes, plataformas transparentes estabilizadas, inscricao que abre o portal da S04, reinicio no
## checkpoint do recife (idempotente) e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> AquarysLevel21:
	var level := AquarysLevel21.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel21 = _level(tree)
	await _settle(tree, 3)
	TestWorld.rec(out, "fase 21: o portal da S04 comeca fechado, a inscricao desligada e a S04 esta no catalogo fora da ordem principal",
			not level.portal.can_interact() and not level.inscription.is_active and level.portal.destination_level_id == &"aquarys_s04"
			and LevelCatalog.has("aquarys_s04") and not "aquarys_s04" in LevelCatalog.MAIN_ORDER["aquarys"]
			and "aquarys_21" in LevelCatalog.MAIN_ORDER["aquarys"])
	TestWorld.rec(out, "fase 21: as duas correntes tem sentidos opostos e a contraria e mais lenta que Rocco",
			level.current_with.effective_direction() > 0.0 and level.current_against.effective_direction() < 0.0 and level.current_against.speed < 5.5)
	level.rig.body.global_position = Vector3(25.0, 0.9, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 40)
	var x_with: float = level.rig.body.global_position.x
	TestWorld.rec(out, "fase 21: a corrente a favor arrasta o heroi parado para a frente", x_with > 25.5, "(x=%.2f)" % x_with)
	level.rig.body.global_position = Vector3(48.0, 0.9, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 40)
	var x_against: float = level.rig.body.global_position.x
	TestWorld.rec(out, "fase 21: a corrente contraria arrasta o heroi parado para tras", x_against < 47.5, "(x=%.2f)" % x_against)
	var group_a: int = 0
	var group_b: int = 0
	for p in level.reef_platforms:
		if p.link_id == &"reef_a":
			group_a += 1
		elif p.link_id == &"reef_b":
			group_b += 1
	TestWorld.rec(out, "fase 21: seis plataformas transparentes em dois grupos, todas instaveis no inicio",
			group_a == 4 and group_b == 2 and level.reef_platforms.all(func(p: RupturePlatform) -> bool: return not p.stabilized))
	level.stabilizer_a.interact()
	var a_ok: bool = level.reef_platforms.filter(func(p: RupturePlatform) -> bool: return p.link_id == &"reef_a").all(func(p: RupturePlatform) -> bool: return p.stabilized)
	var b_untouched: bool = level.reef_platforms.filter(func(p: RupturePlatform) -> bool: return p.link_id == &"reef_b").all(func(p: RupturePlatform) -> bool: return not p.stabilized)
	TestWorld.rec(out, "TC-046 fase 21: o primeiro mecanismo estabiliza so o primeiro grupo de plataformas", a_ok and b_untouched)
	# Checkpoint do recife: o primeiro mecanismo ja estava ligado ao alcanca-lo; a inscricao e o segundo mecanismo ficam depois.
	level.rig.body.global_position = Vector3(57.0, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 4)
	TestWorld.rec(out, "fase 21: alcancar o recife registra o checkpoint", level.rig.last_checkpoint_id == &"aquarys_21_cp1")
	level.inscription.interact()
	level.stabilizer_b.interact()
	TestWorld.rec(out, "TC-044 fase 21: a inscricao revela o portal secreto da S04", level.portal.can_interact() and level.stabilizer_b.is_active)
	for round_index in 2:
		level.controller._on_life_lost(&"test")
		await _settle(tree, 3)
		TestWorld.rec(out, "TC-046 fase 21: reaparecer (%da vez) volta ao checkpoint do recife (primeiro mecanismo mantido, inscricao e segundo desligados)" % (round_index + 1),
				level.stabilizer_a.is_active and not level.inscription.is_active and not level.stabilizer_b.is_active and not level.portal.can_interact()
				and level.reef_platforms[0].stabilized and not level.reef_platforms[4].stabilized)
		level.inscription.interact()
	level.queue_free()
	# O heroi liberado ainda existe neste quadro e coletaria as moedas da proxima instancia (mesmas coordenadas no mundo de fisica).
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel21 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot21.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 21 (correntes, inscricao, mecanismos, plataformas transparentes, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 21 com 9 moedas, arquivo do primeiro explorador e portal aberto, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and "memory_first_explorer_21" in c.session.memory_ids and level.portal.can_interact() and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("aquarys_21") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
