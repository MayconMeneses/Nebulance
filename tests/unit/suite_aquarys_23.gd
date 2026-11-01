extends RefCounted
## Fase 23 (O Templo das Mares): dois reservatorios independentes, combinacao de niveis, fluxo luminoso, porta, checkpoint e bot.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> AquarysLevel23:
	var level := AquarysLevel23.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel23 = _level(tree)
	await _settle(tree, 3)
	var f: TideFlux = level.flux
	TestWorld.rec(out, "TC-047 fase 23: os dois reservatorios sao independentes e comecam no nivel 0; fluxo apagado e porta fechada",
			level.west != level.east and level.west.level == 0 and level.east.level == 0 and not f.is_lit() and f.collision_layer == PhysicsLayers.WORLD)
	level.east.set_level(2)
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-047 fase 23: mexer so no Leste nao muda o Oeste e a combinacao incompleta nao acende o fluxo",
			level.west.level == 0 and level.east.level == 2 and not f.is_lit() and f.requirement_met(1) and not f.requirement_met(0))
	level.west.set_level(2)
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-047 fase 23: combinacao errada (Oeste 2, Leste 2) mantem o fluxo apagado e a porta fechada",
			not f.is_lit() and f.collision_layer == PhysicsLayers.WORLD)
	level.west.set_level(1)
	level.east.set_level(1)
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-047 fase 23: combinacao errada (Oeste 1, Leste 1) tambem nao abre", not f.is_lit())
	level.east.set_level(2)
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-047 fase 23: combinacao certa (Oeste 1, Leste 2) acende o fluxo e libera a porta (sem colisao)",
			f.is_lit() and f.collision_layer == 0)
	level.west.set_level(0)
	await _settle(tree, 2)
	TestWorld.rec(out, "TC-047 fase 23: desfazer um nivel apaga o fluxo e fecha a porta de novo (estado derivado, reversivel)",
			not f.is_lit() and f.collision_layer == PhysicsLayers.WORLD)
	TestWorld.rec(out, "TC-047 fase 23: comportas oferecem so o que muda o nivel atual",
			level.west_low.can_interact() == false and level.west_mid.can_interact() and level.east_high.can_interact() == false)
	# Checkpoint antes do puzzle: o estado do checkpoint e restaurado de forma deterministica.
	level.west.set_level(2)
	level.east.set_level(0)
	await _settle(tree, 120)
	level.controller._on_checkpoint(&"aquarys_23_cp1")
	level.west.set_level(1)
	level.east.set_level(2)
	await _settle(tree, 120)
	var lit_before: bool = f.is_lit()
	level.rig.body.global_position = Vector3(40.0, 1.0, 0.0)
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-047 fase 23: reaparecer restaura os dois niveis do checkpoint (Oeste 2, Leste 0) com a altura da agua e o fluxo apagado",
			lit_before and level.west.level == 2 and level.east.level == 0 and level.west.is_settled() and level.east.is_settled()
			and not f.is_lit() and f.collision_layer == PhysicsLayers.WORLD)
	level.controller._on_life_lost(&"test")
	await _settle(tree, 3)
	TestWorld.rec(out, "TC-047 fase 23: reiniciar de novo e idempotente", level.west.level == 2 and level.east.level == 0 and not f.is_lit())
	TestWorld.rec(out, "TC-047 fase 23: bau especial, memoria antiga e entrada para Thalassa existem",
			level.chest != null and "memory_ancient_roots_23" in level.definition.secret_memory_ids and level.definition.chest_id == &"aquarys_23_chest")
	level.queue_free()
	# O heroi liberado ainda existe neste quadro e coletaria as moedas da proxima instancia.
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AquarysLevel23 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot23.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 23 (Oeste alto, combinacao 1+2, fluxo, porta, memoria, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 23 com 9 moedas, a memoria antiga, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.memory_ids == ["memory_ancient_roots_23"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("aquarys_23") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
