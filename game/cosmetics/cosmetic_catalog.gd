class_name CosmeticCatalog
extends RefCounted
## Cosmeticos: itens unicos do save (`economy.owned_items`) que podem ser vestidos. So mudam a COR do modelo (um brilho translucido):
## nunca alteram atributos, habilidades nem colisao. A escolha e por heroi e vive em `identity.equipped_outfits` (hero_id -> id do item).

const NONE: String = ""

## id do item -> {name, color}. A ordem do dicionario e a ordem do espelho.
const CATALOG: Dictionary = {
	"sylvara_01_glow_scarf": {"name": "Cachecol Luminoso", "color": Color(0.35, 0.95, 0.55)},
	"sylvara_s01_leaf_crown": {"name": "Coroa de Folhas", "color": Color(0.55, 0.85, 0.25)},
	"cristalia_s02_explorer_lens": {"name": "Lente de Exploradora", "color": Color(0.55, 0.75, 1.0)},
	"mecatron_s03_tech_accessory": {"name": "Acessorio Tecnologico", "color": Color(1.0, 0.6, 0.2)},
	"aquarys_s04_expedition_badge": {"name": "Insignia da Expedicao", "color": Color(0.2, 0.85, 0.9)},
	"aerion_s05_legendary_cosmetic": {"name": "Lendario de Aerion", "color": Color(1.0, 0.85, 0.3)},
	"umbraxis_33_crew_suit": {"name": "Traje da Tripulacao", "color": Color(0.85, 0.35, 0.95)},
	"umbraxis_s06_expedition_suit": {"name": "Traje da Primeira Expedicao", "color": Color(0.95, 0.95, 1.0)},
}


## Cosmeticos que o jogador possui, na ordem do catalogo.
static func available(save: Dictionary) -> Array[String]:
	var owned: Array = save["economy"]["owned_items"]
	var out: Array[String] = []
	for id in CATALOG:
		if id in owned:
			out.append(id)
	return out


## O que `hero_id` veste ("" = visual original). Item que nao e possuido volta ao original.
static func equipped(save: Dictionary, hero_id: StringName) -> String:
	var outfits: Variant = save["identity"].get("equipped_outfits", {})
	var id: String = NONE
	if outfits is Dictionary:
		id = String(outfits.get(String(hero_id), NONE))
	return id if id in available(save) else NONE


## Veste `id` ("" tira) em `hero_id`. So aceita item possuido; devolve se aplicou.
static func equip(save: Dictionary, hero_id: StringName, id: String) -> bool:
	if id != NONE and not id in available(save):
		return false
	if typeof(save["identity"].get("equipped_outfits")) != TYPE_DICTIONARY:
		save["identity"]["equipped_outfits"] = {}
	save["identity"]["equipped_outfits"][String(hero_id)] = id
	return true


## Proximo visual do ciclo [original, ...possuidos] depois do que `hero_id` veste.
static func next_after(save: Dictionary, hero_id: StringName) -> String:
	var cycle: Array[String] = [NONE]
	cycle.append_array(available(save))
	var at: int = cycle.find(equipped(save, hero_id))
	return cycle[(at + 1) % cycle.size()]


static func display_name(id: String) -> String:
	if id == NONE:
		return "Original"
	return String(CATALOG.get(id, {}).get("name", id))


static func tint_of(id: String) -> Color:
	if id == NONE or not CATALOG.has(id):
		return Color(1, 1, 1, 0)
	return CATALOG[id]["color"] as Color
