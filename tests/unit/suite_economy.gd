extends RefCounted
## RewardLedger e LevelSession: TC-015 a TC-017 (bau garantido, repeticao, melhora) e coletas por tentativa.


func run(_tree: SceneTree) -> Array:
	var out: Array = []
	_basic_and_repeat(out)
	_upgrade(out)
	_attempt_state(out)
	_cheats_and_items(out)
	return out


func _def() -> LevelDefinition:
	var d := LevelDefinition.new()
	d.level_id = &"t_level"
	d.chest_id = &"t_chest"
	d.coin_ids = PackedStringArray(["c1", "c2", "c3"])
	d.secret_item_ids = PackedStringArray(["scarf"])
	d.secret_memory_ids = PackedStringArray(["symbol"])
	return d


func _session(coins: Array, secret: bool, lost: int = 0) -> LevelSession:
	var s := LevelSession.new()
	for c in coins:
		s.collect_coin(c)
	if secret:
		s.collect_item("scarf")
		s.collect_memory("symbol")
	s.lives_lost = lost
	return s


func _basic_and_repeat(out: Array) -> void:
	var save: Dictionary = SaveData.new_game()
	var ledger := RewardLedger.new()
	var r: Dictionary = ledger.commit_completion(save, _def(), _session(["c1"], false))
	TestWorld.rec(out, "TC-015 bau da fase sempre entrega a recompensa garantida (Bronze = 80)",
			r["chest_coins"] == 80 and r["grade"] == RewardLedger.Grade.BRONZE, "(bau=%d)" % r["chest_coins"])
	TestWorld.rec(out, "economia: moeda coletada credita 1; saldo = 81", save["economy"]["coin_balance"] == 81)
	TestWorld.rec(out, "economia: fase fica registrada como concluida", "t_level" in save["world"]["completed_levels"])
	var again: Dictionary = ledger.commit_completion(save, _def(), _session(["c1"], false))
	TestWorld.rec(out, "TC-016 repetir o mesmo resultado nao duplica moedas",
			save["economy"]["coin_balance"] == 81 and again["chest_coins"] == 0 and again["pickup_coins"] == 0,
			"(saldo=%d)" % save["economy"]["coin_balance"])
	TestWorld.rec(out, "TC-016 bau registrado uma unica vez", save["economy"]["claimed_chest_ids"] == ["t_chest"])


func _upgrade(out: Array) -> void:
	var save: Dictionary = SaveData.new_game()
	var ledger := RewardLedger.new()
	ledger.commit_completion(save, _def(), _session([], false))
	var silver: Dictionary = ledger.commit_completion(save, _def(), _session([], true, 1))
	TestWorld.rec(out, "TC-017 Bronze -> Prata credita so a diferenca (30)", silver["chest_coins"] == 30 and silver["upgraded"],
			"(credito=%d)" % silver["chest_coins"])
	var gold: Dictionary = ledger.commit_completion(save, _def(), _session(["c1", "c2", "c3"], true, 0))
	TestWorld.rec(out, "TC-017 Prata -> Ouro credita so a diferenca (40) mais 3 moedas",
			gold["chest_coins"] == 40 and gold["pickup_coins"] == 3 and save["economy"]["coin_balance"] == 80 + 30 + 40 + 3,
			"(saldo=%d)" % save["economy"]["coin_balance"])
	var balance: int = save["economy"]["coin_balance"]
	ledger.commit_completion(save, _def(), _session([], false))
	TestWorld.rec(out, "TC-017 classificacao inferior depois do Ouro nao credita nem rebaixa",
			save["economy"]["coin_balance"] == balance and save["economy"]["best_grade_by_level"]["t_level"] == RewardLedger.Grade.GOLD)
	TestWorld.rec(out, "economia: Prata exige segredo; Ouro exige tudo e nenhuma vida perdida",
			_session(["c1", "c2", "c3"], true, 1).grade(_def()) == RewardLedger.Grade.SILVER
			and _session(["c1"], true, 0).grade(_def()) == RewardLedger.Grade.SILVER
			and _session(["c1", "c2", "c3"], false, 0).grade(_def()) == RewardLedger.Grade.BRONZE)


func _attempt_state(out: Array) -> void:
	var s := LevelSession.new()
	s.collect_coin("c1")
	s.take_snapshot()
	s.collect_coin("c2")
	s.lives_lost += 1
	s.restore_snapshot()
	TestWorld.rec(out, "tentativa: morrer antes do proximo checkpoint desfaz a coleta feita depois do snapshot",
			s.coin_ids == ["c1"] and s.lives_lost == 1)
	s.collect_coin("c2")
	s.collect_coin("c2")
	TestWorld.rec(out, "tentativa: coletar de novo a mesma moeda conta uma vez", s.coin_ids == ["c1", "c2"])
	var save: Dictionary = SaveData.new_game()
	RewardLedger.new().commit_completion(save, _def(), s)
	TestWorld.rec(out, "tentativa: morrer e recoletar credita a moeda uma unica vez (saldo = 80 + 2)", save["economy"]["coin_balance"] == 82,
			"(saldo=%d)" % save["economy"]["coin_balance"])


func _cheats_and_items(out: Array) -> void:
	var save: Dictionary = SaveData.new_game()
	var ledger := RewardLedger.new()
	var s := _session(["c1", "inventada"], true)
	var r: Dictionary = ledger.commit_completion(save, _def(), s)
	TestWorld.rec(out, "economia: ID de moeda que nao pertence a fase e ignorado", r["pickup_coins"] == 1)
	TestWorld.rec(out, "economia: item e memoria unicos entram uma vez",
			save["economy"]["owned_items"] == ["scarf"] and save["story"]["memories"] == ["symbol"])
	ledger.commit_completion(save, _def(), s)
	TestWorld.rec(out, "economia: item unico nao duplica ao repetir", save["economy"]["owned_items"] == ["scarf"])
	var svc := SaveService.new(TmpDir.fresh("economy") + "/save.json")
	svc.save(save)
	var loaded: Dictionary = svc.load_save()["data"]
	var balance: int = loaded["economy"]["coin_balance"]
	ledger.commit_completion(loaded, _def(), s)
	TestWorld.rec(out, "TC-016 idempotencia sobrevive a salvar e carregar", loaded["economy"]["coin_balance"] == balance)
	TmpDir.remove(TmpDir.ROOT)
