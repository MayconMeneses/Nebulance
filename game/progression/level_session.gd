class_name LevelSession
extends RefCounted
## Estado da TENTATIVA atual. Nada aqui vai para o save: so o RewardLedger, ao concluir a fase.
## Checkpoints tiram um snapshot; reaparecer restaura (impede duplicar coletas por morrer/reiniciar).

var coin_ids: Array[String] = []
var item_ids: Array[String] = []
var memory_ids: Array[String] = []
var lives_lost: int = 0
var damage_taken: int = 0

var _snapshot: Dictionary = {}


func collect_coin(id: String) -> bool:
	return _add(coin_ids, id)


func collect_item(id: String) -> bool:
	return _add(item_ids, id)


func collect_memory(id: String) -> bool:
	return _add(memory_ids, id)


func secret_found() -> bool:
	return not item_ids.is_empty() or not memory_ids.is_empty()


func take_snapshot() -> void:
	_snapshot = {"coins": coin_ids.duplicate(), "items": item_ids.duplicate(), "memories": memory_ids.duplicate()}


## Volta as coletas ao ultimo checkpoint (ou ao inicio, se nao houver). Vidas perdidas NAO voltam.
func restore_snapshot() -> void:
	coin_ids = _snapshot.get("coins", [] as Array[String]).duplicate()
	item_ids = _snapshot.get("items", [] as Array[String]).duplicate()
	memory_ids = _snapshot.get("memories", [] as Array[String]).duplicate()


## Criterios PROPRIOS (classe B, a balancear; ver docs/ECONOMY.md):
## Bronze = concluir; Prata = + achar o segredo; Ouro = + todas as moedas e nenhuma vida perdida.
func grade(def: LevelDefinition) -> int:
	if not secret_found():
		return RewardLedger.Grade.BRONZE
	var all_coins: bool = coin_ids.size() >= def.coin_ids.size()
	if all_coins and lives_lost == 0:
		return RewardLedger.Grade.GOLD
	return RewardLedger.Grade.SILVER


func _add(list: Array[String], id: String) -> bool:
	if id in list:
		return false
	list.append(id)
	return true
