extends RefCounted
## Fase 13 (O Porto das Engrenagens): esteiras (sentido e arrasto), elevador por alavanca, reinicio e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> MecatronLevel13:
	var level := MecatronLevel13.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel13 = _level(tree)
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "TC-058 fase 13: as esteiras tem sentidos opostos e velocidade constante",
			level.conveyor_with.constant_linear_velocity.x > 0.0 and level.conveyor_against.constant_linear_velocity.x < 0.0)
	var body: ActorController = level.rig.body
	body.respawn(Vector3(19.0, 1.0, 0.0))
	await level.get_tree().physics_frame
	var x0: float = body.global_position.x
	for i in 60:
		await tree.physics_frame
	TestWorld.rec(out, "TC-058 fase 13: parado sobre a esteira o heroi e arrastado no sentido dela", body.is_on_floor() and body.global_position.x - x0 > 2.0,
			"(dx=%.2f)" % (body.global_position.x - x0))
	body.respawn(Vector3(40.0, 1.0, 0.0))
	await tree.physics_frame
	x0 = body.global_position.x
	for i in 60:
		await tree.physics_frame
	TestWorld.rec(out, "TC-058 fase 13: na esteira contraria o arrasto e para tras", body.global_position.x - x0 < -2.0,
			"(dx=%.2f)" % (body.global_position.x - x0))
	body.respawn(Vector3(8.0, 1.0, 0.0))
	for i in 40:
		await tree.physics_frame
	x0 = body.global_position.x
	for i in 40:
		await tree.physics_frame
	TestWorld.rec(out, "fase 13: fora da esteira nao ha arrasto", absf(body.global_position.x - x0) < 0.05)
	TestWorld.rec(out, "fase 13: o elevador comeca embaixo e a alavanca desligada", level.elevator.progress == 0.0 and not level.lever.is_active)
	level.lever.interact()
	for i in 200:
		await tree.physics_frame
	TestWorld.rec(out, "TC-041 fase 13: ligar a alavanca leva o elevador ao topo (6 m) a velocidade fixa", level.elevator.progress == 1.0
			and is_equal_approx(level.elevator.position.y, 5.8))
	level.lever.interact()
	for i in 200:
		await tree.physics_frame
	TestWorld.rec(out, "TC-041 fase 13: a alavanca alterna (polaridade): desligar traz o elevador de volta", level.elevator.progress == 0.0 and not level.lever.is_active)
	level.lever.interact()
	for i in 40:
		await tree.physics_frame
	var mid: float = level.elevator.progress
	level.rig.body.global_position = Vector3(30.0, 1.0, 0.0)
	level.controller._on_life_lost(&"test")
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "TC-041 fase 13: reaparecer reinicia alavanca e elevador (idempotente)", mid > 0.0 and not level.lever.is_active and level.elevator.progress == 0.0)
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel13 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot13.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 13 (esteiras, elevador, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f)" % [bot.stage, bot.x(), bot.body.global_position.y])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 13 com 9 moedas e o componente TecnoGear, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["mecatron_13_techgear_part"] and c.session.lives_lost == 0
				and level.save["economy"]["best_grade_by_level"].get("mecatron_13") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
