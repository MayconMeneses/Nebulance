class_name TestPlatformBody
extends CharacterBody3D
## Corpo provisorio da Fase Zero: valida CharacterBody3D, plano lateral e salto.
## Nao e o controller final (ver Fase 2). Le somente acoes do InputMap.

@export var run_speed: float = 6.0
@export var jump_velocity: float = 9.0
@export var gravity: float = 24.0

var _jump_requested: bool = false


func request_jump() -> void:
	_jump_requested = true


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump"):
		_jump_requested = true
	if _jump_requested and is_on_floor():
		velocity.y = jump_velocity
	_jump_requested = false

	velocity.x = Input.get_axis("move_left", "move_right") * run_speed
	velocity.z = 0.0
	move_and_slide()
