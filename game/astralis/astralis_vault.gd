class_name AstralisVault
extends RefCounted
## Compartimento selado da Astralis (PDF secoes 03 e 06): seis simbolos, um por planeta, que se acendem quando a semente do planeta e
## destruida; com os seis acesos a mensagem final antiga fica disponivel. Estado DERIVADO do save (funcoes puras; nada e guardado a
## parte e nada e alterado). O texto da mensagem e PROVISORIO (o PDF nao traz o texto final).

const FINAL_MESSAGE: String = "Mensagem final (texto provisorio): a Astralis foi preservada para que alguem chegasse ate aqui. As seis sementes se apagaram. Cuidem dos mundos."


## O simbolo do planeta `index` (ordem do mapa) esta aceso?
static func symbol_lit(save: Dictionary, index: int) -> bool:
	return GalaxyState.seed_destroyed(save, GalaxyState.planets()[index])


static func lit_count(save: Dictionary) -> int:
	return GalaxyState.seeds_destroyed_count(save)


## A mensagem final so abre depois da conclusao da campanha (as seis sementes).
static func is_open(save: Dictionary) -> bool:
	return GalaxyState.campaign_complete(save)


static func symbols_text(save: Dictionary) -> String:
	var marks: PackedStringArray = []
	for i in GalaxyState.PLANET_PATHS.size():
		marks.append("[*]" if symbol_lit(save, i) else "[ ]")
	return " ".join(marks)


## Duas linhas para o mapa: os simbolos e a mensagem (selada ate a conclusao; sem revelar o texto antes).
static func panel_text(save: Dictionary) -> String:
	var head: String = "Compartimento selado da Astralis: %s  (%d de %d)" % [symbols_text(save), lit_count(save), GalaxyState.PLANET_PATHS.size()]
	return head + "\n" + (FINAL_MESSAGE if is_open(save) else "Mensagem final: selada ate a campanha terminar.")
