class_name ProgressLedger
extends RefCounted
## Transacoes de PROGRESSO da campanha (alem das recompensas de fase). A destruicao de uma semente e UMA transacao
## idempotente (`seed:<planeta>`): grava semente, guardiao libertado, reliquia e memoria da Astralis uma unica vez.
## Nao ha flag separada de "Caeldron reagiu": a reacao so toca quando `first_time` e verdadeiro.

const ENDING_TX: String = "ending:caeldron_death"
const FINAL_MESSAGE_ID: String = "astralis_final_message"
const CAMPAIGN_TROPHY_ID: String = "trophy_campaign_complete"


## Retorna {"first_time": bool}. Chamar de novo com a mesma semente nao altera nada.
func commit_seed(save: Dictionary, planet: PlanetDefinition, relic_id: String, memory_id: String) -> Dictionary:
	var tx: String = "seed:%s" % planet.planet_id
	var eco: Dictionary = save["economy"]
	if tx in eco["claimed_transaction_ids"]:
		return {"first_time": false}
	eco["claimed_transaction_ids"].append(tx)
	_add(save["world"]["seed_destroyed_ids"], String(planet.seed_id))
	_add(save["world"]["boss_freed_ids"], planet.guardian_name.to_lower())
	_add(eco["owned_items"], relic_id)
	_add(save["story"]["memories"], memory_id)
	return {"first_time": true}


## Fim da campanha: transacao UNICA e idempotente (`ending:caeldron_death`), so valida com as seis sementes destruidas. Grava a mensagem
## final antiga da Astralis e o trofeu; a sequencia final (cutscene + creditos) so toca quando `first_time` e verdadeiro.
func claim_campaign_end(save: Dictionary) -> Dictionary:
	if not GalaxyState.campaign_complete(save):
		return {"first_time": false}
	var eco: Dictionary = save["economy"]
	if ENDING_TX in eco["claimed_transaction_ids"]:
		return {"first_time": false}
	eco["claimed_transaction_ids"].append(ENDING_TX)
	_add(save["story"]["memories"], FINAL_MESSAGE_ID)
	_add(save["story"]["trophies"], CAMPAIGN_TROPHY_ID)
	return {"first_time": true}


func is_seed_destroyed(save: Dictionary, planet: PlanetDefinition) -> bool:
	return String(planet.seed_id) in save["world"]["seed_destroyed_ids"]


func _add(list: Array, id: String) -> void:
	if not id in list:
		list.append(id)
