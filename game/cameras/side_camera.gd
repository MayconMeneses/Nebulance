class_name SideCamera
extends Camera3D
## Camera lateral 2.5D: segue o alvo suavemente em X/Y e mantem Z fixo (plano de jogo).

@export var target: Node3D
@export var offset: Vector3 = Vector3(0.0, 2.0, 12.0)
@export var follow_speed: float = 6.0
@export var look_ahead: float = 1.5
@export var min_y: float = 0.0


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var ahead: float = 0.0
	var body := target as CharacterBody3D
	if body != null:
		ahead = clampf(body.velocity.x / 6.0, -1.0, 1.0) * look_ahead
	var goal := Vector3(target.global_position.x + ahead + offset.x,
			maxf(target.global_position.y, min_y) + offset.y, offset.z)
	global_position = global_position.lerp(goal, clampf(follow_speed * delta, 0.0, 1.0))
	global_position.z = offset.z
