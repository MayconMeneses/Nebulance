class_name ZuriAbility
extends HeroAbility
## Salto duplo (uma vez por tempo no ar) e escalada somente em superficies marcadas (CLIMBABLE).

@export_range(0.0, 1.5) var air_jump_factor: float = 0.9
@export var climb_speed: float = 3.0

var _air_jump_used: bool = false
var _climbing: bool = false


func reset() -> void:
	_air_jump_used = false
	_climbing = false


func on_landed() -> void:
	_air_jump_used = false


func controls_motion() -> bool:
	return _climbing


func is_active() -> bool:
	return _climbing


func physics_update(body: ActorController, intent: HeroIntent, _delta: float) -> void:
	_climbing = intent.special_held and not body.overlaps(PhysicsLayers.CLIMBABLE).is_empty()
	if _climbing:
		body.velocity = Vector3(0.0, climb_speed, 0.0)
		return
	if not body.is_on_floor() and intent.jump_pressed and not body.consumed_jump and not _air_jump_used:
		body.velocity.y = body.profile.tuning.jump_velocity * air_jump_factor * body.gravity_dir
		_air_jump_used = true
