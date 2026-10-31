class_name SaveData
extends RefCounted
## Esquema SaveGameV1 (PDF secao 13) como Dictionary puro (JSON, so chaves String).
## Estado de TENTATIVA (vidas/coracoes da fase em curso) nao e persistido nesta fase.

const SCHEMA_VERSION: int = 1
const MAX_GRADE: int = 3

const STRING_LISTS: Dictionary = {
	"world": ["completed_levels", "seed_destroyed_ids", "boss_freed_ids", "unlocked_routes", "portal_ids"],
	"economy": ["claimed_transaction_ids", "claimed_chest_ids", "owned_items", "collected_coin_ids"],
	"story": ["memories", "rescued_creatures", "trophies"],
}


static func new_game() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"current_planet_id": "sylvara",
		"current_level_id": "sylvara_01",
		"checkpoint_id": "",
		"world": {"completed_levels": [], "seed_destroyed_ids": [], "boss_freed_ids": [],
				"unlocked_routes": [], "portal_ids": []},
		"economy": {"coin_balance": 0, "claimed_transaction_ids": [], "claimed_chest_ids": [],
				"best_grade_by_level": {}, "owned_items": [], "collected_coin_ids": []},
		"identity": {"equipped_outfits": {}, "astralis_paint_id": ""},
		"story": {"memories": [], "rescued_creatures": [], "trophies": []},
		"settings": {"audio": {}, "video": {}, "accessibility": {}, "controls": {}},
	}


## JSON devolve numeros como float; converte para int os campos inteiros conhecidos (se integrais).
static func normalize(data: Dictionary) -> void:
	_to_int(data, "schema_version")
	var economy: Variant = data.get("economy")
	if economy is Dictionary:
		_to_int(economy, "coin_balance")
		var grades: Variant = economy.get("best_grade_by_level")
		if grades is Dictionary:
			for key in grades:
				_to_int(grades, key)


## Retorna "" se valido, ou a descricao do primeiro problema.
static func validate(data: Dictionary) -> String:
	if typeof(data.get("schema_version")) != TYPE_INT:
		return "schema_version ausente ou nao inteiro"
	for key in ["current_planet_id", "current_level_id", "checkpoint_id"]:
		if typeof(data.get(key)) != TYPE_STRING:
			return "%s deve ser texto" % key
	for section in ["world", "economy", "identity", "story", "settings"]:
		if typeof(data.get(section)) != TYPE_DICTIONARY:
			return "secao %s ausente" % section
	for section in STRING_LISTS:
		for list_key in STRING_LISTS[section]:
			var list: Variant = data[section].get(list_key)
			if typeof(list) != TYPE_ARRAY:
				return "%s.%s deve ser lista" % [section, list_key]
			for item in list:
				if typeof(item) != TYPE_STRING:
					return "%s.%s tem item nao textual" % [section, list_key]
	var economy: Dictionary = data["economy"]
	if typeof(economy.get("coin_balance")) != TYPE_INT or economy["coin_balance"] < 0:
		return "coin_balance deve ser inteiro >= 0"
	if typeof(economy.get("best_grade_by_level")) != TYPE_DICTIONARY:
		return "best_grade_by_level deve ser dicionario"
	for level_id in economy["best_grade_by_level"]:
		var grade: Variant = economy["best_grade_by_level"][level_id]
		if typeof(grade) != TYPE_INT or grade < 0 or grade > MAX_GRADE:
			return "classificacao invalida em %s" % level_id
	return ""


static func _to_int(dict: Dictionary, key: Variant) -> void:
	var value: Variant = dict.get(key)
	if typeof(value) == TYPE_FLOAT and is_equal_approx(value, roundf(value)):
		dict[key] = int(value)
