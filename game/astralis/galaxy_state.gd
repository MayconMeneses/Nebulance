class_name GalaxyState
extends RefCounted
## Estado do Mapa Galactico DERIVADO do save (funcoes puras; nada e guardado em separado).

enum Status { LOCKED, AVAILABLE, IN_DANGER, SAVED }

const PLANET_PATHS: Array[String] = [
	"res://game/astralis/data/sylvara.tres", "res://game/astralis/data/cristalia.tres",
	"res://game/astralis/data/mecatron.tres", "res://game/astralis/data/aquarys.tres",
	"res://game/astralis/data/aerion.tres", "res://game/astralis/data/umbraxis.tres",
]


static func planets() -> Array[PlanetDefinition]:
	var out: Array[PlanetDefinition] = []
	for path in PLANET_PATHS:
		out.append(load(path) as PlanetDefinition)
	return out


static func seed_destroyed(save: Dictionary, planet: PlanetDefinition) -> bool:
	return String(planet.seed_id) in save["world"]["seed_destroyed_ids"]


## Bloqueado ate a semente do planeta anterior ser destruida. Disponivel = sem progresso; em perigo = com progresso; salvo = semente destruida.
static func status(save: Dictionary, index: int) -> Status:
	var all: Array[PlanetDefinition] = planets()
	if seed_destroyed(save, all[index]):
		return Status.SAVED
	if index > 0 and not seed_destroyed(save, all[index - 1]):
		return Status.LOCKED
	return Status.IN_DANGER if levels_completed(save, all[index]) > 0 else Status.AVAILABLE


## A raiz de Caeldron que liga Umbraxis ao planeta so some quando a semente dele e destruida.
static func root_visible(save: Dictionary, index: int) -> bool:
	return not seed_destroyed(save, planets()[index])


static func levels_completed(save: Dictionary, planet: PlanetDefinition) -> int:
	var count: int = 0
	for level_id in save["world"]["completed_levels"]:
		if String(level_id).begins_with(String(planet.planet_id) + "_"):
			count += 1
	return count


static func secrets_found(save: Dictionary, planet: PlanetDefinition) -> int:
	var count: int = 0
	for id in planet.secret_ids:
		if id in save["economy"]["owned_items"] or id in save["story"]["memories"]:
			count += 1
	return count


static func can_travel(save: Dictionary, index: int) -> bool:
	return planets()[index].playable and status(save, index) != Status.LOCKED


## Modo QA: save EM MEMORIA com as primeiras `seeds` sementes destruidas (0..6). Nunca toca o save real.
static func qa_save(seeds: int) -> Dictionary:
	var save: Dictionary = SaveData.new_game()
	var all: Array[PlanetDefinition] = planets()
	for i in clampi(seeds, 0, all.size()):
		save["world"]["seed_destroyed_ids"].append(String(all[i].seed_id))
		save["world"]["completed_levels"].append("%s_06" % all[i].planet_id)
	return save
