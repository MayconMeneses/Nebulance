class_name ActorController
extends CharacterBody3D
## Entidade controlavel unica do trio. Heroi atual = HeroProfile + HeroAbility.
## Le somente HeroIntent (via intent_provider); nunca o Input diretamente.

signal landed
signal state_changed(new_state: int)

var profile: HeroProfile
var vitals: TrioVitals
var intent_provider: Callable = Callable()
var current_intent: HeroIntent = HeroIntent.new()
var state: int = MovementState.State.IDLE
var facing: float = 1.0
var consumed_jump: bool = false
var airborne_time: float = 0.0
var collision_shape: CollisionShape3D

var _ability: HeroAbility = HeroAbility.new()
var _coyote: float = 0.0
var _buffer: float = 0.0
var _hurt: float = 0.0
var _jumping: bool = false
var _was_on_floor: bool = false
var _locked_state: int = -1


func _ready() -> void:
	collision_layer = PhysicsLayers.HERO
	collision_mask = PhysicsLayers.WORLD
	axis_lock_linear_z = true
	if collision_shape == null:
		collision_shape = CollisionShape3D.new()
		collision_shape.shape = CapsuleShape3D.new()
		add_child(collision_shape)


func apply_profile(new_profile: HeroProfile, keep_feet: bool = true) -> void:
	if collision_shape == null:
		_ready()
	var capsule := collision_shape.shape as CapsuleShape3D
	if keep_feet:
		position.y += (new_profile.capsule_height - capsule.height) * 0.5
	capsule.radius = new_profile.capsule_radius
	capsule.height = new_profile.capsule_height
	profile = new_profile
	_ability = new_profile.ability.duplicate() as HeroAbility if new_profile.ability != null else HeroAbility.new()
	_ability.reset()


func respawn(at: Vector3) -> void:
	global_position = at
	velocity = Vector3.ZERO
	_hurt = 0.0
	_ability.reset()
	_set_state(MovementState.State.IDLE)


func set_locked_state(locked: int) -> void:
	_locked_state = locked
	if locked >= 0:
		_set_state(locked)


func overlaps(mask: int, areas: bool = true, bodies: bool = false) -> Array[Object]:
	return ShapeProbe.overlapping(get_world_3d(), collision_shape.shape, collision_shape.global_transform,
			mask, [get_rid()] as Array[RID], areas, bodies)


func wind_push() -> Vector3:
	return ZoneEffects.wind_push(self)


func take_hit(source_x: float = NAN) -> void:
	if vitals == null or not vitals.hit():
		return
	var dir: float = -facing if is_nan(source_x) else signf(global_position.x - source_x)
	var kb: Vector2 = profile.tuning.knockback
	velocity = Vector3(dir * kb.x, kb.y, 0.0)
	_hurt = profile.tuning.hurt_stun


func _physics_process(delta: float) -> void:
	if profile == null:
		return
	var tuning: MovementTuning = profile.tuning
	var blocked: bool = _hurt > 0.0 or MovementState.blocks_input(state)
	var intent: HeroIntent = HeroIntent.new() if blocked else _fetch_intent()
	current_intent = intent
	if vitals != null:
		vitals.tick(delta)
	_hurt = maxf(_hurt - delta, 0.0)
	var on_floor: bool = is_on_floor()
	_update_timers(on_floor, delta, tuning)
	consumed_jump = false
	if not _ability.controls_motion():
		_apply_gravity(delta, tuning, on_floor)
		if _hurt <= 0.0:
			_apply_horizontal(intent, delta, tuning, on_floor)
		_apply_jump(intent, tuning, on_floor)
	_ability.physics_update(self, intent, delta)
	move_and_slide()
	_ability.after_move(self)
	_after_move()


func _fetch_intent() -> HeroIntent:
	if intent_provider.is_valid():
		var value: Variant = intent_provider.call()
		if value is HeroIntent:
			return value
	return HeroIntent.new()


func _update_timers(on_floor: bool, delta: float, tuning: MovementTuning) -> void:
	_coyote = tuning.coyote_time if on_floor else maxf(_coyote - delta, 0.0)
	_buffer = maxf(_buffer - delta, 0.0)
	airborne_time = 0.0 if on_floor else airborne_time + delta
	if on_floor:
		_jumping = false


func _apply_gravity(delta: float, tuning: MovementTuning, on_floor: bool) -> void:
	if on_floor:
		velocity.y = maxf(velocity.y, 0.0)
	else:
		velocity.y = maxf(velocity.y - tuning.gravity * ZoneEffects.gravity_scale(self) * delta, -tuning.max_fall_speed)


func _apply_horizontal(intent: HeroIntent, delta: float, tuning: MovementTuning, on_floor: bool) -> void:
	var target: float = intent.move_axis * tuning.run_speed
	var rate: float = tuning.acceleration if absf(target) > 0.0 else tuning.deceleration
	if not on_floor:
		rate *= tuning.air_control
	velocity.x = move_toward(velocity.x, target, rate * delta)
	velocity.z = 0.0
	if absf(intent.move_axis) > 0.01:
		facing = signf(intent.move_axis)


func _apply_jump(intent: HeroIntent, tuning: MovementTuning, on_floor: bool) -> void:
	if intent.jump_pressed:
		_buffer = tuning.jump_buffer
	if _buffer > 0.0 and (on_floor or _coyote > 0.0):
		velocity.y = tuning.jump_velocity
		_buffer = 0.0
		_coyote = 0.0
		_jumping = true
		consumed_jump = true
	elif _jumping and not intent.jump_held and velocity.y > 0.0:
		velocity.y *= tuning.jump_cut
		_jumping = false


func _after_move() -> void:
	var on_floor: bool = is_on_floor()
	if on_floor and not _was_on_floor:
		_ability.on_landed()
		landed.emit()
	_was_on_floor = on_floor
	_check_zones()
	_update_state(on_floor)


func _check_zones() -> void:
	if vitals == null:
		return
	if not overlaps(PhysicsLayers.ABYSS).is_empty():
		vitals.fall()
	elif not overlaps(PhysicsLayers.HAZARD).is_empty():
		take_hit()


func _update_state(on_floor: bool) -> void:
	if _locked_state >= 0:
		_set_state(_locked_state)
	elif _hurt > 0.0:
		_set_state(MovementState.State.HURT)
	elif _ability.is_active():
		_set_state(MovementState.State.SPECIAL)
	elif consumed_jump:
		_set_state(MovementState.State.TAKEOFF)
	elif not on_floor:
		_set_state(MovementState.State.AIRBORNE if velocity.y > 0.0 else MovementState.State.FALL)
	else:
		_set_state(MovementState.State.RUN if absf(velocity.x) > 0.1 else MovementState.State.IDLE)


func _set_state(new_state: int) -> void:
	if new_state != state:
		state = new_state
		state_changed.emit(new_state)
