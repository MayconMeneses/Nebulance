class_name MovementTuning
extends Resource
## Parametros de movimento de um heroi (valores iniciais sujeitos a playtest).

@export var run_speed: float = 6.0
@export var acceleration: float = 40.0
@export var deceleration: float = 50.0
@export_range(0.0, 1.0) var air_control: float = 0.6
@export var jump_velocity: float = 9.0
@export var gravity: float = 24.0
@export var max_fall_speed: float = 20.0
@export_range(0.0, 1.0) var jump_cut: float = 0.5
@export var coyote_time: float = 0.1
@export var jump_buffer: float = 0.1
@export var knockback: Vector2 = Vector2(4.0, 5.0)
@export var hurt_stun: float = 0.25
