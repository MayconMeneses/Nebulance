class_name HeroAbility
extends Resource
## Base das habilidades. O estado de execucao vive numa copia (duplicate) por heroi ativo.


## Verdadeiro quando a habilidade assume o movimento (dash, escalada): o controller nao aplica gravidade/controle.
func controls_motion() -> bool:
	return false


## Verdadeiro quando a habilidade esta em uso (estado SPECIAL).
func is_active() -> bool:
	return false


func reset() -> void:
	pass


func on_landed() -> void:
	pass


func physics_update(_body: ActorController, _intent: HeroIntent, _delta: float) -> void:
	pass


func after_move(_body: ActorController) -> void:
	pass
