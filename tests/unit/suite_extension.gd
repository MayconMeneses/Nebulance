extends RefCounted
## TC-076 Trecho extra das fases (fase ~2x maior, ver LevelExtension): cada fase recebe um trecho que parte do bau antigo, o bau novo fica pelo menos
## 2x mais longe do que o original e o BOT atravessa o trecho so com intents (sem perder vida). O inicio do trecho e posto no ponto de partida
## do bot so para isolar o teste: o caminho ate la ja e coberto pelo bot da propria fase (suites por fase), que agora termina chamando o trecho.
## Fora do trecho: chefes (06/12/18/24/30/36), segredos e as fases em LevelExtension.EXCLUDED.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	var only: String = OS.get_environment("NEB_EXT_ONLY")
	for planet in LevelCatalog.MAIN_ORDER:
		for id in LevelCatalog.MAIN_ORDER[planet]:
			if only != "" and id != only:
				continue
			await _level(tree, out, String(id))
	if only == "":
		_exclusions(out)
	return out


func _level(tree: SceneTree, out: Array, id: String) -> void:
	if not LevelExtension.applies(StringName(id)):
		return
	var level: LevelScene = LevelCatalog.make(id)
	level.use_input_reader = false
	tree.get_root().add_child(level)
	await tree.physics_frame
	var ext: Dictionary = level.extension
	var chest: Chest = level.find_children("*", "Chest", true, false)[0] as Chest
	var original: float = float(ext.get("original", 1.0e9))
	TestWorld.rec(out, "TC-076 %s: o bau novo fica pelo menos 2x mais longe que o original (e a rota tem passos)" % id,
			chest.position.x >= 2.0 * original and (ext.get("route", []) as Array).size() > 0, "(bau %.0f, antes %.0f)" % [chest.position.x, original])
	var start: Vector3 = ext["start"]
	var bot := LevelBot.new(tree, level)
	level.rig.body.respawn(Vector3(start.x + 1.0, start.y + 1.0, 0.0))
	await bot.frames(20)
	var ok: bool = await ExtensionRunner.finish(bot)
	TestWorld.rec(out, "TC-076 %s: o bot atravessa o trecho extra so com intents e abre o bau sem perder vida" % id,
			ok and level.controller.completed and level.controller.session.lives_lost == 0,
			"(etapa=%s x=%.1f vidas perdidas=%d)" % [bot.stage, bot.x(), level.controller.session.lives_lost])
	level.queue_free()
	await tree.process_frame


func _exclusions(out: Array) -> void:
	var ids: Array = []
	for planet in LevelCatalog.MAIN_ORDER:
		for id in LevelCatalog.MAIN_ORDER[planet]:
			if LevelExtension.applies(StringName(id)):
				ids.append(id)
	TestWorld.rec(out, "TC-076 recebem trecho as 28 fases principais que nao sao chefe nem excecao (36 - 6 chefes - umbraxis_32 e umbraxis_35)", ids.size() == 28, "(%d)" % ids.size())
	var bosses_out: bool = true
	for id in ["sylvara_06", "cristalia_12", "mecatron_18", "aquarys_24", "aerion_30", "umbraxis_36", "umbraxis_32", "umbraxis_35", "sylvara_s01", "umbraxis_s06"]:
		bosses_out = bosses_out and not LevelExtension.applies(StringName(id))
	TestWorld.rec(out, "TC-076 chefes, segredos e as duas excecoes ficam sem trecho extra", bosses_out)
