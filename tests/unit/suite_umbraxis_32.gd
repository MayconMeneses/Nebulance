extends RefCounted
## Fase 32 (As Fases Quebradas): modulos carregados/descarregados de verdade por checkpoint (TC-067), reinicio que recria o comeco, atalho
## dimensional (so Zuri alcanca) e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _streaming(tree, out)
	await _restart(tree, out)
	await _shortcut(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> UmbraxisLevel32:
	var level := UmbraxisLevel32.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func _goto(level: UmbraxisLevel32, tree: SceneTree, x: float) -> void:
	level.rig.body.global_position = Vector3(x, 1.0, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 4)


## Quantos nos de colisao/mecanismo existem dentro dos modulos (prova de que descarregar libera de verdade).
func _module_nodes(level: UmbraxisLevel32) -> int:
	var n: int = 0
	for i in level.streamer.module_count():
		if level.streamer.is_loaded(i):
			n += level.streamer.container(i).find_children("*", "", true, false).size()
	return n


func _streaming(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel32 = _level(tree)
	await _settle(tree, 3)
	var first_barrier: Node = level.barrier_mod["barrier"]
	TestWorld.rec(out, "TC-067 fase 32: ao comecar so os modulos 0 e 1 existem (os outros 3 nem foram criados) e ha 4 checkpoints",
			level.streamer.loaded_indices() == [0, 1] and level.streamer.module_count() == 5 and level.belt_mod.is_empty() and level.tide_mod.is_empty()
			and level.definition.checkpoint_ids.size() == 4)
	var peak: int = level.streamer.loaded_indices().size()
	var plan: Array = [[22.0, [1, 2]], [51.0, [1, 2, 3]], [99.0, [3, 4]], [139.0, [4]]]
	var plan_ok: bool = true
	var counts: Array[int] = [_module_nodes(level)]
	for step in plan:
		await _goto(level, tree, step[0])
		peak = maxi(peak, level.streamer.loaded_indices().size())
		plan_ok = plan_ok and level.streamer.loaded_indices() == step[1]
		counts.append(_module_nodes(level))
	TestWorld.rec(out, "TC-067 fase 32: cada checkpoint carrega o proximo modulo e descarrega os de tras (planos 1-2, 1-3, 3-4 e 4) com no maximo 3 ao mesmo tempo",
			plan_ok and peak <= 3 and level.rig.last_checkpoint_id == &"umbraxis_32_cp4", "(carregados no pico=%d)" % peak)
	TestWorld.rec(out, "TC-067 fase 32: o modulo descarregado sumiu de verdade (a barreira do modulo 0 foi liberada e o muro nao tem mais corpos do modulo 1)",
			not is_instance_valid(first_barrier) and counts[4] < counts[2] and not level.streamer.is_loaded(0))
	# Checkpoint do meio (modulo Aquarys): reaparecer volta a mare ao nivel do checkpoint, sem voltar a carregar o que ficou para tras.
	await _goto(level, tree, 99.0)
	level.tide_mod["control"].interact()
	await _settle(tree, 5)
	for round_index in 2:
		level.controller._on_life_lost(&"test")
		level.rig.body.respawn(level.rig.checkpoint_position)
		await _settle(tree, 3)
		TestWorld.rec(out, "TC-061 fase 32: reaparecer (%da vez) volta a mare ao nivel do checkpoint e os modulos de tras continuam descarregados" % (round_index + 1),
				level.tide_mod["water"].level == 0 and level.rig.body.global_position.x > 90.0 and not level.streamer.is_loaded(1) and level.streamer.is_loaded(3))
		level.tide_mod["control"].interact()
		await _settle(tree, 2)
	level.queue_free()
	await _settle(tree, 3)


## Zerar as vidas reinicia a fase: os modulos do comeco voltam novos e os de adiante somem.
func _restart(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel32 = _level(tree)
	await _settle(tree, 3)
	level.barrier_mod["barrier"].on_impacted()
	await _goto(level, tree, 99.0)
	level.rig.level_restart_requested.emit()
	await _settle(tree, 30)
	var barrier: ImpactBarrier = level.barrier_mod["barrier"]
	TestWorld.rec(out, "TC-067 fase 32: reiniciar a fase recria os modulos 0 e 1 (barreira nova, inteira) e descarrega os de adiante; o heroi volta ao chao do inicio",
			level.streamer.loaded_indices() == [0, 1] and is_instance_valid(barrier) and not barrier.is_broken and level.rig.body.global_position.x < 5.0
			and level.rig.body.is_on_floor() and level.rig.last_checkpoint_id == &"")
	level.queue_free()
	await _settle(tree, 3)


func _jump_to_ledge(level: UmbraxisLevel32, tree: SceneTree, hero: int, presses: int) -> float:
	var body: ActorController = level.rig.body
	level.rig.request_swap(hero)
	await _settle(tree, 10)
	body.global_position = Vector3(UmbraxisLevel32.SHORTCUT_X - 2.5, 0.9, 0.0)
	body.velocity = Vector3.ZERO
	await _settle(tree, 20)
	var counter: Array[int] = [0]
	body.intent_provider = func() -> HeroIntent:
		var i := HeroIntent.new()
		var n: int = counter[0]
		counter[0] += 1
		i.jump_pressed = (n == 0) or (presses > 1 and n == 21)
		i.jump_held = n < 30
		i.move_axis = 0.35
		return i
	await _settle(tree, 100)
	body.intent_provider = Callable()
	return body.global_position.y - 0.75


func _shortcut(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel32 = _level(tree)
	await _settle(tree, 3)
	await _goto(level, tree, 22.0)
	var rocco: float = await _jump_to_ledge(level, tree, 0, 1)
	var zuri: float = await _jump_to_ledge(level, tree, 1, 2)
	TestWorld.rec(out, "TC-067 fase 32: a fenda dimensional fica numa plataforma alta; Rocco (um salto) nao chega e Zuri (salto duplo) pousa nela",
			rocco < 1.0 and zuri > 2.2, "(Rocco y=%.2f; Zuri y=%.2f)" % [rocco, zuri])
	# Em cima da plataforma, junto da fenda: o heroi a alcanca para interagir (E).
	level.rig.body.global_position = Vector3(UmbraxisLevel32.SHORTCUT_X, 3.3, 0.0)
	level.rig.body.velocity = Vector3.ZERO
	await _settle(tree, 6)
	var reachable: bool = level.rig.body.overlaps(PhysicsLayers.INTERACTABLE).has(level.shortcut)
	var old_shortcut: Node = level.shortcut
	level.shortcut.interact()
	await _settle(tree, 12)
	TestWorld.rec(out, "TC-067 fase 32: usar a fenda leva ao checkpoint do modulo de Aquarys, carrega o modulo de destino, descarrega o de origem e o da esteira (pulada)",
			reachable and level.rig.last_checkpoint_id == &"umbraxis_32_cp3" and level.streamer.loaded_indices() == [3, 4] and not level.streamer.is_loaded(2)
			and not is_instance_valid(old_shortcut) and absf(level.rig.body.global_position.x - 99.0) < 2.0 and level.rig.body.is_on_floor())
	level.queue_free()
	await _settle(tree, 3)


func _bot(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel32 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot32.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 32 (cinco modulos de ecossistemas, carregados por checkpoint) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 32 com 9 moedas e o registro oculto, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and "memory_hidden_record_32" in c.session.memory_ids and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("umbraxis_32") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
