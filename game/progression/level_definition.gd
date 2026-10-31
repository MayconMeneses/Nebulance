class_name LevelDefinition
extends Resource
## Dados de uma fase: IDs estaveis (autorados, nunca derivados de ordem) e tabela de recompensas.
## Valores de moedas sao de TESTE (PDF: 80 / ate 110 / ate 150) e ficam em recurso, nao no codigo.

@export var level_id: StringName = &""
@export var display_name: String = ""
@export var planet_id: StringName = &""
@export var goal_text: String = ""
@export var chest_id: StringName = &""
@export var coin_ids: PackedStringArray = PackedStringArray()
@export var checkpoint_ids: PackedStringArray = PackedStringArray()
## Itens unicos escondidos (cosmeticos) e memorias de historia do segredo.
@export var secret_item_ids: PackedStringArray = PackedStringArray()
@export var secret_memory_ids: PackedStringArray = PackedStringArray()
@export var coin_value: int = 1
@export var bronze_total: int = 80
@export var silver_total: int = 110
@export var gold_total: int = 150


func chest_total(grade: int) -> int:
	match grade:
		1: return bronze_total
		2: return silver_total
		3: return gold_total
	return 0
