extends RefCounted
## Fase 17 (A Forja Autonoma): combinacao esteira + prensas + polaridade, painel escondido abre o portal da S03, reinicio e bot completo.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _bot(tree, out)
	return out


func _level(tree: SceneTree) -> MecatronLevel17:
	var level := MecatronLevel17.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel17 = _level(tree)
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "fase 17: o portal da S03 comeca fechado e a alavanca escondida desligada",
			not level.portal.can_interact() and not level.secret_lever.is_active and level.portal.destination_level_id == &"mecatron_s03")
	TestWorld.rec(out, "fase 17: as duas prensas tem fases diferentes (nunca descem juntas)", level.presses.size() == 2 and level.presses[0].phase != level.presses[1].phase)
	level.secret_lever.interact()
	TestWorld.rec(out, "TC-044 fase 17: a alavanca escondida abre o portal da Oficina Zero", level.portal.can_interact())
	level.rig.body.global_position = Vector3(30.0, 1.0, 0.0)
	level.controller._on_life_lost(&"test")
	for i in 3:
		await tree.physics_frame
	TestWorld.rec(out, "fase 17: sem checkpoint passado, reaparecer devolve alavanca e portal ao estado inicial",
			not level.secret_lever.is_active and not level.portal.can_interact())
	TestWorld.rec(out, "fase 17: a S03 existe no catalogo", LevelCatalog.has("mecatron_s03"))
	level.queue_free()


func _bot(tree: SceneTree, out: Array) -> void:
	var level: MecatronLevel17 = _level(tree)
	await tree.physics_frame
	var bot := LevelBot17.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 17 (painel escondido, esteira, prensas, elevadores, esteira invertida) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		var missing: PackedStringArray = []
		for id in level.definition.coin_ids:
			if not id in c.session.coin_ids:
				missing.append(id)
		TestWorld.rec(out, "bot: fase 17 com 9 moedas, nucleo, arquivo da expedicao e portal aberto, sem perder vidas, Ouro",
				c.session.coin_ids.size() == 9 and c.session.item_ids == ["mecatron_17_forge_core"] and c.session.lives_lost == 0
				and "memory_failed_expedition_17" in c.session.memory_ids and level.portal.can_interact()
				and level.save["economy"]["best_grade_by_level"].get("mecatron_17") == RewardLedger.Grade.GOLD,
				"(moedas=%d faltam=%s vidas perdidas=%d)" % [c.session.coin_ids.size(), ",".join(missing), c.session.lives_lost])
	level.queue_free()
