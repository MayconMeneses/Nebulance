class_name PipaAbility
extends HeroAbility
## Planeio com duracao limitada e queda maxima reduzida; correntes de ar (WIND) dao sustentacao.

@export var glide_fall_speed: float = 2.0
@export var glide_duration: float = 1.5

var _time_left: float = 0.0
var _gliding: bool = false


func reset() -> void:
	_time_left = glide_duration
	_gliding = false


func on_landed() -> void:
	_time_left = glide_duration


func is_active() -> bool:
	return _gliding


func physics_update(body: ActorController, intent: HeroIntent, delta: float) -> void:
	_gliding = intent.special_held and not body.is_on_floor() and body.velocity.y <= 0.0 and _time_left > 0.0
	if not _gliding:
		return
	_time_left -= delta
	body.velocity.y = maxf(body.velocity.y + body.wind_push().y * delta, -glide_fall_speed)
