class_name RewardLedger
extends RefCounted
## Unica porta para creditar recompensas. Transacoes idempotentes por ID deterministico.
## Opera sobre o Dictionary do save (nao escreve em disco; quem chama salva).

enum Grade { NONE, BRONZE, SILVER, GOLD }


## Conclui a fase: credita moedas unicas, a DIFERENCA do bau e itens/memorias unicos. Retorna o recibo.
func commit_completion(save: Dictionary, def: LevelDefinition, session: LevelSession) -> Dictionary:
	var eco: Dictionary = save["economy"]
	var grade: int = session.grade(def)
	var receipt: Dictionary = {"grade": grade, "pickup_coins": 0, "chest_coins": 0,
			"new_items": [], "new_memories": [], "new_rescues": [], "upgraded": false}

	for coin_id in session.coin_ids:
		if coin_id in def.coin_ids and _claim(eco, "coin:%s" % coin_id):
			eco["coin_balance"] += def.coin_value
			receipt["pickup_coins"] += def.coin_value

	var level_key: String = String(def.level_id)
	var previous: int = eco["best_grade_by_level"].get(level_key, Grade.NONE)
	if grade > previous and _claim(eco, "chest:%s:%d" % [level_key, grade]):
		var credit: int = def.chest_total(grade) - def.chest_total(previous)
		eco["coin_balance"] += credit
		receipt["chest_coins"] = credit
		receipt["upgraded"] = previous != Grade.NONE
		eco["best_grade_by_level"][level_key] = grade
	if String(def.chest_id) != "" and not String(def.chest_id) in eco["claimed_chest_ids"]:
		eco["claimed_chest_ids"].append(String(def.chest_id))

	for item_id in session.item_ids:
		if item_id in def.secret_item_ids and not item_id in eco["owned_items"]:
			eco["owned_items"].append(item_id)
			receipt["new_items"].append(item_id)
	for memory_id in session.memory_ids:
		if memory_id in def.secret_memory_ids and not memory_id in save["story"]["memories"]:
			save["story"]["memories"].append(memory_id)
			receipt["new_memories"].append(memory_id)

	for rescue_id in session.rescued_ids:
		if rescue_id in def.rescue_ids and not rescue_id in save["story"]["rescued_creatures"]:
			save["story"]["rescued_creatures"].append(rescue_id)
			receipt["new_rescues"].append(rescue_id)

	if not level_key in save["world"]["completed_levels"]:
		save["world"]["completed_levels"].append(level_key)
	return receipt


## Retorna true somente na primeira vez que a transacao e registrada.
func _claim(eco: Dictionary, transaction_id: String) -> bool:
	if transaction_id in eco["claimed_transaction_ids"]:
		return false
	eco["claimed_transaction_ids"].append(transaction_id)
	return true
