class_name HeroProfile
extends Resource
## Dados de um heroi: colisao, movimento e habilidade. Sem logica.

@export var hero_id: StringName = &""
@export var display_name: String = ""
@export var tuning: MovementTuning
@export var capsule_radius: float = 0.4
@export var capsule_height: float = 1.6
@export var ability: HeroAbility
