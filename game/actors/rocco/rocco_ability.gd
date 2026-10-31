class_name RoccoAbility
extends HeroAbility
## Investida curta: so aciona alvos marcados (grupo impact_target). Nunca quebra parede comum.

@export var dash_speed: float = 14.0
@export var dash_time: float = 0.25
@export var cooldown: float = 0.6

var _time_left: float = 0.0
var _cooldown_left: float = 0.0
var _dir: float = 1.0


func reset() -> void:
	_time_left = 0.0
	_cooldown_left = 0.0


func controls_motion() -> bool:
	return _time_left > 0.0


func is_active() -> bool:
	return _time_left > 0.0


func physics_update(body: ActorController, intent: HeroIntent, delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if _time_left > 0.0:
		_time_left -= delta
	elif intent.special_pressed and _cooldown_left <= 0.0:
		_dir = body.facing
		_time_left = dash_time
		_cooldown_left = cooldown
	if _time_left > 0.0:
		body.velocity.x = _dir * dash_speed
		body.velocity.y = 0.0


func after_move(body: ActorController) -> void:
	if _time_left <= 0.0:
		return
	for i in body.get_slide_collision_count():
		var target := body.get_slide_collision(i).get_collider() as Node
		if target != null and target.is_in_group(&"impact_target") and target.has_method(&"on_impacted"):
			target.call(&"on_impacted")
