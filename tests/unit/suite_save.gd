extends RefCounted
## SaveService: ida e volta, escrita atomica, backup, corrupcao, versao futura (TC-020, TC-021).

const S := SaveService.Status


func run(_tree: SceneTree) -> Array:
	var out: Array = []
	_roundtrip(out)
	_missing_and_garbage(out)
	_backup_and_recovery(out)
	_invalid_and_future(out)
	_extras(out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _sample() -> Dictionary:
	var d: Dictionary = SaveData.new_game()
	d["economy"]["coin_balance"] = 42
	d["economy"]["owned_items"] = ["sylvara_glow_scarf"]
	d["world"]["completed_levels"] = ["sylvara_01"]
	return d


func _roundtrip(out: Array) -> void:
	var svc := SaveService.new(TmpDir.fresh("roundtrip") + "/save.json")
	TestWorld.rec(out, "save: grava dados validos", svc.save(_sample()) == OK)
	var r: Dictionary = svc.load_save()
	TestWorld.rec(out, "TC-020 save: carrega com status OK", r["status"] == S.OK)
	TestWorld.rec(out, "TC-020 save: moedas e itens recuperados",
			r["data"]["economy"]["coin_balance"] == 42 and r["data"]["economy"]["owned_items"] == ["sylvara_glow_scarf"])
	TestWorld.rec(out, "save: inteiros voltam como int (nao float)",
			typeof(r["data"]["economy"]["coin_balance"]) == TYPE_INT and typeof(r["data"]["schema_version"]) == TYPE_INT)
	var again: Dictionary = svc.load_save()
	TestWorld.rec(out, "save: carregamento repetido e identico", again["data"] == r["data"])


func _missing_and_garbage(out: Array) -> void:
	var dir: String = TmpDir.fresh("missing")
	var svc := SaveService.new(dir + "/save.json")
	TestWorld.rec(out, "save: arquivo ausente -> NO_FILE", svc.load_save()["status"] == S.NO_FILE)
	TmpDir.write(dir + "/save.json", "{ isto nao e json")
	var r: Dictionary = svc.load_save()
	TestWorld.rec(out, "save: JSON invalido sem backup -> CORRUPT", r["status"] == S.CORRUPT)
	TestWorld.rec(out, "save: CORRUPT preserva o arquivo original", TmpDir.read(dir + "/save.json") == "{ isto nao e json")
	TmpDir.write(dir + "/save.json", "")
	TestWorld.rec(out, "save: arquivo vazio -> CORRUPT", svc.load_save()["status"] == S.CORRUPT)


func _backup_and_recovery(out: Array) -> void:
	var dir: String = TmpDir.fresh("backup")
	var svc := SaveService.new(dir + "/save.json")
	svc.save(_sample())
	TestWorld.rec(out, "save: primeiro save nao cria backup", not FileAccess.file_exists(svc.backup_path()))
	var second: Dictionary = _sample()
	second["economy"]["coin_balance"] = 99
	svc.save(second)
	TestWorld.rec(out, "TC-021 save: segundo save cria backup do anterior", FileAccess.file_exists(svc.backup_path()))
	TestWorld.rec(out, "save: substituicao atomica atualiza o arquivo principal (Windows)", svc.load_save()["data"]["economy"]["coin_balance"] == 99)
	var full: String = TmpDir.read(svc.path)
	TmpDir.write(svc.path, full.substr(0, full.length() / 2))
	var r: Dictionary = svc.load_save()
	TestWorld.rec(out, "TC-021 save: principal truncado recupera do backup", r["status"] == S.RECOVERED_FROM_BACKUP
			and r["data"]["economy"]["coin_balance"] == 42, "(moedas=%s)" % str(r["data"].get("economy", {}).get("coin_balance")))
	TestWorld.rec(out, "TC-021 save: recuperacao nao altera o arquivo corrompido", TmpDir.read(svc.path) == full.substr(0, full.length() / 2))
	var moved: String = svc.quarantine()
	TestWorld.rec(out, "save: quarentena move (nao apaga) o arquivo invalido",
			FileAccess.file_exists(moved) and not FileAccess.file_exists(svc.path))


func _invalid_and_future(out: Array) -> void:
	var dir: String = TmpDir.fresh("invalid")
	var svc := SaveService.new(dir + "/save.json")
	svc.save(_sample())
	var before: String = TmpDir.read(svc.path)
	var bad: Dictionary = _sample()
	bad["economy"]["coin_balance"] = -5
	TestWorld.rec(out, "save: recusa moedas negativas e nao altera o arquivo", svc.save(bad) == ERR_INVALID_DATA and TmpDir.read(svc.path) == before)
	var bad2: Dictionary = _sample()
	bad2["world"]["completed_levels"] = [1, 2]
	TestWorld.rec(out, "save: recusa lista com tipos errados", svc.save(bad2) == ERR_INVALID_DATA)
	var bad3: Dictionary = _sample()
	bad3["economy"]["best_grade_by_level"] = {"sylvara_01": 9}
	TestWorld.rec(out, "save: recusa classificacao fora de 0..3", svc.save(bad3) == ERR_INVALID_DATA)

	var fdir: String = TmpDir.fresh("future")
	var fsvc := SaveService.new(fdir + "/save.json")
	var fut: Dictionary = _sample()
	fut["schema_version"] = 2
	TmpDir.write(fsvc.path, JSON.stringify(fut))
	var r: Dictionary = fsvc.load_save()
	TestWorld.rec(out, "save: versao futura -> FUTURE_VERSION e somente leitura", r["status"] == S.FUTURE_VERSION and not fsvc.writable)
	var raw: String = TmpDir.read(fsvc.path)
	TestWorld.rec(out, "save: versao futura NAO e sobrescrita (ERR_LOCKED)", fsvc.save(_sample()) == ERR_LOCKED and TmpDir.read(fsvc.path) == raw)


func _extras(out: Array) -> void:
	var dir: String = TmpDir.fresh("extras")
	var svc := SaveService.new(dir + "/save.json")
	TmpDir.write(svc.temp_path(), "lixo de uma escrita interrompida")
	TestWorld.rec(out, "save: .tmp sobrando nao e lido como save", svc.load_save()["status"] == S.NO_FILE)
	TestWorld.rec(out, "save: salvar apos queda no meio da escrita funciona", svc.save(_sample()) == OK and svc.load_save()["status"] == S.OK)
	var floaty: Dictionary = _sample()
	TmpDir.write(svc.path, JSON.stringify(floaty).replace("\"coin_balance\":42", "\"coin_balance\":42.0"))
	TestWorld.rec(out, "save: numero 42.0 do JSON e normalizado para int", svc.load_save()["data"]["economy"]["coin_balance"] == 42)
	TestWorld.rec(out, "save: save real do usuario nao e tocado pelos testes", not svc.path.begins_with("user://save"))
