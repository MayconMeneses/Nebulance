class_name SaveService
extends RefCounted
## Salvamento local versionado: JSON, escrita temporaria + verificacao + backup + substituicao.
## Nunca executa conteudo do save (so JSON.parse_string). O caminho e parametro (testes nao tocam o save real).

enum Status { OK, NO_FILE, RECOVERED_FROM_BACKUP, CORRUPT, FUTURE_VERSION }

var path: String
## Falso apos carregar um save de versao futura: impede sobrescrever dados que este jogo nao entende.
var writable: bool = true


func _init(save_path: String) -> void:
	path = save_path


func backup_path() -> String:
	return path + ".bak"


func temp_path() -> String:
	return path + ".tmp"


func save(data: Dictionary) -> Error:
	if not writable:
		return ERR_LOCKED
	var problem: String = SaveData.validate(data)
	if problem != "":
		push_warning("Save recusado: " + problem)
		return ERR_INVALID_DATA
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var tmp := FileAccess.open(temp_path(), FileAccess.WRITE)
	if tmp == null:
		return FileAccess.get_open_error()
	tmp.store_string(JSON.stringify(data, "\t"))
	tmp.flush()
	tmp.close()
	if _read_valid(temp_path()).is_empty():
		DirAccess.remove_absolute(temp_path())
		return ERR_FILE_CORRUPT
	if FileAccess.file_exists(path) and not _read_valid(path).is_empty():
		DirAccess.copy_absolute(path, backup_path())
	if DirAccess.rename_absolute(temp_path(), path) != OK:
		DirAccess.remove_absolute(path)
		return DirAccess.rename_absolute(temp_path(), path)
	return OK


## Retorna {"status": Status, "data": Dictionary, "message": String}.
func load_save() -> Dictionary:
	if not FileAccess.file_exists(path) and not FileAccess.file_exists(backup_path()):
		return _result(Status.NO_FILE, {}, "Nenhum save encontrado.")
	var main: Variant = _parse(path)
	if main is Dictionary:
		var main_version: int = int(main.get("schema_version", 0)) if typeof(main.get("schema_version")) in [TYPE_INT, TYPE_FLOAT] else 0
		if main_version > SaveData.SCHEMA_VERSION:
			writable = false
			return _result(Status.FUTURE_VERSION, {}, "Save de versao mais nova (%d); jogo em modo somente leitura." % main_version)
		var checked: Dictionary = _validated(main)
		if not checked.is_empty():
			return _result(Status.OK, checked, "")
	var backup: Dictionary = _read_valid(backup_path())
	if not backup.is_empty():
		return _result(Status.RECOVERED_FROM_BACKUP, backup, "Save principal invalido; recuperado do backup.")
	return _result(Status.CORRUPT, {}, "Save e backup invalidos; arquivos preservados sem alteracao.")


## Move o save principal invalido para um nome de quarentena (nunca apaga).
func quarantine() -> String:
	var n: int = 1
	while FileAccess.file_exists("%s.corrupt-%d" % [path, n]):
		n += 1
	var target: String = "%s.corrupt-%d" % [path, n]
	if FileAccess.file_exists(path):
		DirAccess.rename_absolute(path, target)
	return target


func _read_valid(file_path: String) -> Dictionary:
	var parsed: Variant = _parse(file_path)
	return _validated(parsed) if parsed is Dictionary else {}


func _validated(parsed: Dictionary) -> Dictionary:
	SaveData.normalize(parsed)
	return parsed if SaveData.validate(parsed) == "" else {}


func _parse(file_path: String) -> Variant:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return null
	return JSON.parse_string(file.get_as_text())


func _result(status: Status, data: Dictionary, message: String) -> Dictionary:
	return {"status": status, "data": data, "message": message}
