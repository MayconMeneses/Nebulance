class_name LevelCatalog
extends RefCounted
## Catalogo de fases implementadas: id -> cena de fase. Unico lugar que conhece os scripts de cada fase.

const SCRIPTS: Dictionary = {
	"sylvara_01": "res://game/levels/sylvara/sylvara_01.gd",
	"sylvara_02": "res://game/levels/sylvara/sylvara_02.gd",
	"sylvara_03": "res://game/levels/sylvara/sylvara_03.gd",
	"sylvara_04": "res://game/levels/sylvara/sylvara_04.gd",
	"sylvara_05": "res://game/levels/sylvara/sylvara_05.gd",
	"sylvara_06": "res://game/levels/sylvara/sylvara_06.gd",
	"sylvara_s01": "res://game/levels/sylvara/sylvara_s01.gd",
	"cristalia_07": "res://game/levels/cristalia/cristalia_07.gd",
	"cristalia_08": "res://game/levels/cristalia/cristalia_08.gd",
	"cristalia_09": "res://game/levels/cristalia/cristalia_09.gd",
	"cristalia_10": "res://game/levels/cristalia/cristalia_10.gd",
	"cristalia_11": "res://game/levels/cristalia/cristalia_11.gd",
	"cristalia_12": "res://game/levels/cristalia/cristalia_12.gd",
	"cristalia_s02": "res://game/levels/cristalia/cristalia_s02.gd",
	"mecatron_13": "res://game/levels/mecatron/mecatron_13.gd",
	"mecatron_14": "res://game/levels/mecatron/mecatron_14.gd",
	"mecatron_15": "res://game/levels/mecatron/mecatron_15.gd",
	"mecatron_16": "res://game/levels/mecatron/mecatron_16.gd",
	"mecatron_17": "res://game/levels/mecatron/mecatron_17.gd",
	"mecatron_18": "res://game/levels/mecatron/mecatron_18.gd",
	"aquarys_19": "res://game/levels/aquarys/aquarys_19.gd",
	"aquarys_20": "res://game/levels/aquarys/aquarys_20.gd",
	"aquarys_21": "res://game/levels/aquarys/aquarys_21.gd",
	"aquarys_22": "res://game/levels/aquarys/aquarys_22.gd",
	"aquarys_s04": "res://game/levels/aquarys/aquarys_s04.gd",
	"mecatron_s03": "res://game/levels/mecatron/mecatron_s03.gd",
}
## Ordem de jogo das fases PRINCIPAIS por planeta (as secretas so entram por portal).
const MAIN_ORDER: Dictionary = {"sylvara": ["sylvara_01", "sylvara_02", "sylvara_03", "sylvara_04", "sylvara_05", "sylvara_06"],
		"cristalia": ["cristalia_07", "cristalia_08", "cristalia_09", "cristalia_10", "cristalia_11", "cristalia_12"],
		"mecatron": ["mecatron_13", "mecatron_14", "mecatron_15", "mecatron_16", "mecatron_17", "mecatron_18"],
		"aquarys": ["aquarys_19", "aquarys_20", "aquarys_21", "aquarys_22"]}


static func has(level_id: String) -> bool:
	return SCRIPTS.has(level_id)


static func make(level_id: String) -> LevelScene:
	return (load(SCRIPTS[level_id]) as GDScript).new() as LevelScene


## Proxima fase principal ainda nao concluida do planeta (ou a primeira, se todas ja foram concluidas).
static func next_for(save: Dictionary, planet_id: String) -> String:
	var order: Array = MAIN_ORDER.get(planet_id, [])
	for id in order:
		if not id in save["world"]["completed_levels"]:
			return id
	return order[0] if not order.is_empty() else ""
