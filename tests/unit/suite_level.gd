extends RefCounted
## Fase 01: integridade de IDs, tentativa (checkpoint/morte), reset de mecanismos e inimigo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _ids(tree, out)
	await _attempt_rules(tree, out)
	await _barrier_and_enemy(tree, out)
	await _enemy_rules(tree, out)
	return out


func _level(tree: SceneTree) -> SylvaraLevel01:
	var level := SylvaraLevel01.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _ids(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel01 = _level(tree)
	await tree.physics_frame
	var def: LevelDefinition = level.definition
	var coins: Array[String] = []
	var others: Array[String] = []
	var all_ids: Array[String] = []
	for node in level.find_children("*", "Pickup", true, false):
		var p := node as Pickup
		all_ids.append(String(p.pickup_id))
		(coins if p.kind == Pickup.Kind.COIN else others).append(String(p.pickup_id))
	var chests: Array[Node] = level.find_children("*", "Chest", true, false)
	var cps: Array[String] = []
	for node in level.find_children("*", "LevelZone", true, false):
		if (node as LevelZone).zone_layer == PhysicsLayers.CHECKPOINT:
			cps.append(String((node as LevelZone).zone_id))
	var unique: Dictionary = {}
	for id in all_ids:
		unique[id] = true
	TestWorld.rec(out, "fase 01: IDs de coletaveis sao unicos", unique.size() == all_ids.size())
	coins.sort()
	var expected_coins: Array[String] = []
	for id in def.coin_ids:
		expected_coins.append(id)
	expected_coins.sort()
	TestWorld.rec(out, "fase 01: moedas da cena == moedas da definicao (9)", coins == expected_coins, "(%d)" % coins.size())
	others.sort()
	var expected_others: Array[String] = []
	for id in def.secret_item_ids + def.secret_memory_ids:
		expected_others.append(id)
	expected_others.sort()
	TestWorld.rec(out, "fase 01: segredo (item + memoria) bate com a definicao", others == expected_others)
	TestWorld.rec(out, "fase 01: um unico bau com o ID da definicao",
			chests.size() == 1 and String((chests[0] as Chest).chest_id) == String(def.chest_id))
	TestWorld.rec(out, "fase 01: checkpoints da cena == definicao", cps == Array(def.checkpoint_ids))
	level.queue_free()


func _teleport(level: SylvaraLevel01, tree: SceneTree, pos: Vector3, frames: int = 3) -> void:
	level.rig.body.global_position = pos
	level.rig.body.velocity = Vector3.ZERO
	for i in frames:
		await tree.physics_frame


func _attempt_rules(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel01 = _level(tree)
	await tree.physics_frame
	var c: LevelController = level.controller
	await _teleport(level, tree, Vector3(4, 1, 0))
	TestWorld.rec(out, "fase 01: tocar a moeda 1 coleta", c.session.coin_ids == ["sylvara_01_coin_01"])
	await _teleport(level, tree, Vector3(28, -3, 0))
	TestWorld.rec(out, "TC-011 fase 01: cair da ponte consome 1 vida e volta ao inicio",
			level.rig.vitals.lives == 4 and level.rig.body.global_position.x < 2.0, "(vidas=%d x=%.1f)" % [level.rig.vitals.lives, level.rig.body.global_position.x])
	TestWorld.rec(out, "TC-013 fase 01: morrer antes do checkpoint desfaz a moeda coletada", c.session.coin_ids.is_empty())
	var coin1: Pickup = null
	for node in level.find_children("*", "Pickup", true, false):
		if (node as Pickup).pickup_id == &"sylvara_01_coin_01":
			coin1 = node as Pickup
	TestWorld.rec(out, "TC-013 fase 01: a moeda reaparece no mundo", coin1.visible and not coin1.is_collected)

	await _teleport(level, tree, Vector3(4, 1, 0))
	await _teleport(level, tree, Vector3(44, 1, 0))
	TestWorld.rec(out, "checkpoint da fase 01 ativa e guarda a moeda 1", level.rig.last_checkpoint_id == &"sylvara_01_cp1"
			and c.session.coin_ids == ["sylvara_01_coin_01"])
	await _teleport(level, tree, Vector3(31.5, 1, 0))
	TestWorld.rec(out, "fase 01: moeda coletada depois do checkpoint", "sylvara_01_coin_05" in c.session.coin_ids)
	await _teleport(level, tree, Vector3(28, -3, 0))
	TestWorld.rec(out, "TC-013 fase 01: morrer depois do checkpoint volta a ele e desfaz so a coleta posterior",
			absf(level.rig.body.global_position.x - 44.0) < 1.5 and c.session.coin_ids == ["sylvara_01_coin_01"]
			and level.rig.vitals.lives == 3, "(x=%.1f)" % level.rig.body.global_position.x)
	await _teleport(level, tree, Vector3(102, 0.6, 0))
	TestWorld.rec(out, "fase 01: bau mostra o aviso de interacao", c._prompt != "")
	var done := {"n": 0, "receipt": {}}
	c.level_completed.connect(func(r: Dictionary) -> void:
		done["n"] += 1
		done["receipt"] = r)
	level.rig.body.current_intent.interact_pressed = true
	c._physics_process(0.0)
	TestWorld.rec(out, "TC-015 fase 01: abrir o bau conclui a fase uma vez", done["n"] == 1 and c.completed)
	TestWorld.rec(out, "fase 01: recibo Bronze (sem segredo): moeda 1 + bau 80",
			done["receipt"]["grade"] == RewardLedger.Grade.BRONZE and level.save["economy"]["coin_balance"] == 81,
			"(saldo=%d)" % level.save["economy"]["coin_balance"])
	TestWorld.rec(out, "fase 01: apos concluir o heroi fica travado (CUTSCENE)", level.rig.body.state == MovementState.State.CUTSCENE)
	level.queue_free()


func _barrier_and_enemy(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel01 = _level(tree)
	await tree.physics_frame
	var barrier: ImpactBarrier = level.find_children("*", "ImpactBarrier", true, false)[0] as ImpactBarrier
	var enemy: PatrolEnemy = level.find_children("*", "PatrolEnemy", true, false)[0] as PatrolEnemy
	barrier.on_impacted()
	enemy.position.x = 80.0
	await _teleport(level, tree, Vector3(28, -3, 0))
	TestWorld.rec(out, "TC-013 fase 01: barreira quebrada depois do checkpoint (sem ele) volta ao reaparecer", not barrier.is_broken)
	TestWorld.rec(out, "fase 01: inimigo volta ao inicio ao reaparecer", absf(enemy.position.x - 76.0) < 0.3, "(x=%.2f)" % enemy.position.x)
	barrier.on_impacted()
	await _teleport(level, tree, Vector3(44, 1, 0))
	await _teleport(level, tree, Vector3(28, -3, 0))
	TestWorld.rec(out, "TC-013 fase 01: barreira quebrada ANTES do checkpoint continua quebrada", barrier.is_broken)
	level.queue_free()


func _enemy_rules(tree: SceneTree, out: Array) -> void:
	var level: SylvaraLevel01 = _level(tree)
	await tree.physics_frame
	var enemy: PatrolEnemy = level.find_children("*", "PatrolEnemy", true, false)[0] as PatrolEnemy
	enemy.set_physics_process(false)
	await _teleport(level, tree, Vector3(76.0, 0.9, 0.0), 2)
	var hearts_start: int = level.rig.vitals.hearts
	TestWorld.rec(out, "inimigo: so fere em PATROL e LUNGE",
			enemy.is_harmful() and enemy.collision_layer == PhysicsLayers.HAZARD)
	for s in [PatrolEnemy.State.TELEGRAPH, PatrolEnemy.State.COOLDOWN]:
		enemy.state = s
		enemy._apply_state_look()
		level.rig.vitals.tick(5.0)
		await tree.physics_frame
		await tree.physics_frame
	TestWorld.rec(out, "inimigo: TELEGRAPH e COOLDOWN sao inofensivos (nao tiram coracao)", level.rig.vitals.hearts == hearts_start)
	enemy.state = PatrolEnemy.State.LUNGE
	enemy._apply_state_look()
	await tree.physics_frame
	await tree.physics_frame
	TestWorld.rec(out, "inimigo: LUNGE fere", level.rig.vitals.hearts == hearts_start - 1)
	level.queue_free()

	var w := _level(tree)
	await tree.physics_frame
	var e2: PatrolEnemy = w.find_children("*", "PatrolEnemy", true, false)[0] as PatrolEnemy
	await _teleport(w, tree, Vector3(78.0, 0.9, 0.0), 1)
	var seen: Array[int] = []
	for i in 240:
		await tree.physics_frame
		if seen.is_empty() or seen[-1] != e2.state:
			seen.append(e2.state)
		w.rig.body.global_position = Vector3(78.0, 0.9, 0.0)
		w.rig.body.velocity = Vector3.ZERO
	TestWorld.rec(out, "inimigo: ciclo previsivel TELEGRAPH -> LUNGE -> COOLDOWN -> PATROL -> TELEGRAPH",
			seen.size() >= 5 and seen.slice(0, 5) == [1, 2, 3, 0, 1], "(%s)" % str(seen.slice(0, 6)))
	w.queue_free()
