class_name PlanetDefinition
extends Resource
## Dados de um planeta (texto vindo do PDF secoes 03 e 08). Sem logica.

@export var planet_id: StringName = &""
@export var display_name: String = ""
@export var theme: String = ""
@export var mechanic: String = ""
@export var guardian_name: String = ""
@export var seed_id: StringName = &""
@export var main_levels: int = 6
@export var secret_levels: int = 1
## Se ha fases jogaveis implementadas (ate o planeta ser produzido, a viagem fica bloqueada).
@export var playable: bool = false
@export var tint: Color = Color.WHITE
## IDs de segredo conhecidos do planeta (para contar descobertas sem revelar o conteudo).
@export var secret_ids: PackedStringArray = PackedStringArray()
