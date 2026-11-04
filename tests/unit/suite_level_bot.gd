extends RefCounted
## Prova de completabilidade: um bot joga a fase 01 do inicio ao bau so com intents (sem teleporte).


func run(tree: SceneTree) -> Array:
	var out: Array = []
	var level := SylvaraLevel01.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	await tree.physics_frame
	var bot := LevelBot.new(tree, level)
	var used: Dictionary = {level.rig.body.profile.hero_id: true}
	level.rig.hero_changed.connect(func(p: HeroProfile) -> void: used[p.hero_id] = true)
	var finished: bool = await bot.play()
	var c: LevelController = level.controller
	TestWorld.rec(out, "bot: completa a fase 01 do inicio ao bau sem teleporte", finished,
			"(etapa=%s x=%.1f y=%.1f heroi=%s)" % [bot.stage, bot.x(), bot.body.global_position.y, level.rig.body.profile.hero_id])
	if finished:
		TestWorld.rec(out, "bot: coletou as 9 moedas", c.session.coin_ids.size() == 9, "(%d)" % c.session.coin_ids.size())
		TestWorld.rec(out, "bot: achou o segredo (item e memoria)", c.session.item_ids.size() == 1 and c.session.memory_ids.size() == 1)
		TestWorld.rec(out, "bot: nenhuma vida perdida", c.session.lives_lost == 0, "(vidas=%d)" % level.rig.vitals.lives)
		TestWorld.rec(out, "bot: classificacao Ouro e saldo 150 + 9 moedas",
				level.save["economy"]["best_grade_by_level"].get("sylvara_01") == RewardLedger.Grade.GOLD
				and level.save["economy"]["coin_balance"] == 159, "(saldo=%d)" % level.save["economy"]["coin_balance"])
		## Antes validava o heroi ATIVO no fim (Pipa); o trecho extra termina com outro heroi, entao agora confere que os tres foram usados.
		TestWorld.rec(out, "bot: usou os tres herois (Rocco quebrou a barreira, Zuri subiu, Pipa planou)",
				used.has(&"rocco") and used.has(&"zuri") and used.has(&"pipa"), "(%s)" % ",".join(PackedStringArray(used.keys().map(func(k: Variant) -> String: return String(k)))))
	level.queue_free()
	return out
