extends RefCounted
## S05 (Jardim Sem Gravidade): baixa gravidade, planeio de precisao, itens unicos, acesso pelo portal da fase 28 e retorno consistente.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _mechanics(tree, out)
	await _portal_flow(tree, out)
	await _bot(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _level(tree: SceneTree) -> AerionLevelS05:
	var level := AerionLevelS05.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


func _settle(tree: SceneTree, frames: int) -> void:
	for i in frames:
		await tree.physics_frame


## Queda livre durante 20 quadros a partir de y=14 (acima das ilhas); devolve quantos metros caiu.
func _drop_distance(level: AerionLevelS05, tree: SceneTree) -> float:
	var body: ActorController = level.rig.body
	body.global_position = Vector3(22.0, 14.0, 0.0)
	body.velocity = Vector3.ZERO
	for i in 20:
		await tree.physics_frame
	return 14.0 - body.global_position.y


func _mechanics(tree: SceneTree, out: Array) -> void:
	var level: AerionLevelS05 = _level(tree)
	await _settle(tree, 3)
	var body: ActorController = level.rig.body
	TestWorld.rec(out, "S05: a fase e secreta (fora da ordem principal) e esta no catalogo",
			LevelCatalog.has("aerion_s05") and not "aerion_s05" in LevelCatalog.MAIN_ORDER["aerion"])
	body.global_position = Vector3(15.0, 8.0, 0.0)
	await _settle(tree, 1)
	TestWorld.rec(out, "S05: toda a area tem gravidade baixa (escala 0,4)", is_equal_approx(ZoneEffects.gravity_scale(body), 0.4))
	body.global_position = Vector3(60.0, 8.0, 0.0)
	await _settle(tree, 1)
	TestWorld.rec(out, "S05: fora da area a gravidade e normal", is_equal_approx(ZoneEffects.gravity_scale(body), 1.0))
	var slow: float = await _drop_distance(level, tree)
	level.low_gravity.gravity_scale = 1.0
	var normal: float = await _drop_distance(level, tree)
	level.low_gravity.gravity_scale = AerionLevelS05.LOW_GRAVITY
	TestWorld.rec(out, "S05: em gravidade baixa a queda e bem mais lenta que em gravidade normal (mesmos 20 quadros)", slow > 0.1 and slow < normal * 0.6, "(baixa=%.2f m normal=%.2f m)" % [slow, normal])
	TestWorld.rec(out, "S05: cosmetico lendario, registro estelar, bau e 5 moedas com ids estaveis",
			level.definition.secret_item_ids == PackedStringArray(["aerion_s05_legendary_cosmetic"])
			and level.definition.secret_memory_ids == PackedStringArray(["memory_stellar_record_s05"]) and level.definition.coin_ids.size() == 5
			and level.definition.chest_id == &"aerion_s05_chest")
	level.queue_free()
	await _settle(tree, 3)


func _portal_flow(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("aerion_s05")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	flow.level.queue_free()
	flow.level = null
	flow._start_level("aerion_28")
	await tree.process_frame
	var origin: AerionLevel28 = flow.level as AerionLevel28
	origin.secret_panel.interact()
	await tree.physics_frame
	var open_before: bool = origin.portal.can_interact()
	origin.controller.portal_requested.emit(&"aerion_28_portal", &"aerion_s05")
	await tree.process_frame
	TestWorld.rec(out, "S05 portal: a partir da fase 28 (painel ligado) abre a S05 e pausa/oculta a fase de origem",
			open_before and flow.level is AerionLevelS05 and flow.origin_level == origin and not origin.visible
			and origin.process_mode == Node.PROCESS_MODE_DISABLED and flow.profile["world"]["portal_ids"] == ["aerion_28_portal"])
	flow.level.controller._complete()
	await tree.process_frame
	flow._return_from_portal()
	await tree.process_frame
	TestWorld.rec(out, "S05 portal: concluir a S05 grava o save e o retorno devolve a fase 28 viva com o portal ainda aberto",
			flow.level == origin and origin.visible and flow.origin_level == null and origin.portal.can_interact()
			and "aerion_s05" in flow.profile["world"]["completed_levels"])
	tree.paused = false
	flow.queue_free()
	await tree.process_frame


func _bot(tree: SceneTree, out: Array) -> void:
	var level: AerionLevelS05 = _level(tree)
	await tree.physics_frame
	var bot := LevelBotS05.new(tree, level)
	bot.trace = OS.get_cmdline_user_args().has("--trace")
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a S05 (tres saltos em gravidade baixa, planeio de precisao, salto final, bau) sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		TestWorld.rec(out, "bot: S05 com 5 moedas, cosmetico lendario e registro estelar, sem perder vidas",
				c.session.coin_ids.size() == 5 and c.session.item_ids == ["aerion_s05_legendary_cosmetic"]
				and c.session.memory_ids == ["memory_stellar_record_s05"] and c.session.lives_lost == 0,
				"(moedas=%d vidas perdidas=%d)" % [c.session.coin_ids.size(), c.session.lives_lost])
	level.queue_free()
