class_name TrioVitals
extends Node
## Vidas e coracoes COMPARTILHADOS pelo trio (nao pertencem a nenhum heroi).

signal hearts_changed(hearts: int)
signal lives_changed(lives: int)
signal life_lost(reason: StringName)
signal lives_exhausted

@export var difficulty: DifficultyProfile
@export var invulnerability_time: float = 1.2
@export var respawn_grace: float = 1.0

var lives: int = 0
var hearts: int = 0
var _invulnerable_left: float = 0.0


func setup(profile: DifficultyProfile) -> void:
	difficulty = profile
	reset_level()


func reset_level() -> void:
	lives = difficulty.lives_per_level
	hearts = difficulty.hearts_per_attempt
	_invulnerable_left = 0.0
	lives_changed.emit(lives)
	hearts_changed.emit(hearts)


func tick(delta: float) -> void:
	_invulnerable_left = maxf(_invulnerable_left - delta, 0.0)


func is_invulnerable() -> bool:
	return _invulnerable_left > 0.0


## Retorna true se o dano foi aplicado (false durante a invulnerabilidade).
func hit(amount: int = 1) -> bool:
	if is_invulnerable() or lives <= 0:
		return false
	hearts = maxi(hearts - amount, 0)
	hearts_changed.emit(hearts)
	_invulnerable_left = invulnerability_time
	if hearts == 0:
		_lose_life(&"hearts")
	return true


## Queda em abismo: consome uma vida, mesmo durante a invulnerabilidade.
func fall() -> void:
	if lives > 0:
		_lose_life(&"abyss")


func _lose_life(reason: StringName) -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		lives = 0
		lives_exhausted.emit()
		return
	hearts = difficulty.hearts_per_attempt
	hearts_changed.emit(hearts)
	_invulnerable_left = respawn_grace
	life_lost.emit(reason)
