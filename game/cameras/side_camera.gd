class_name SideCamera
extends Camera3D
## Camera lateral 2.5D: segue o alvo suavemente em X/Y e mantem Z fixo (plano de jogo). Acabamento de movimento: tremor curto nos impactos
## (pouso, dano) e leve abertura do campo de visao com a velocidade. Tudo desligado por "reduzir movimento" (Accessibility).

@export var target: Node3D
@export var offset: Vector3 = Vector3(0.0, 2.0, 12.0)
@export var follow_speed: float = 6.0
@export var look_ahead: float = 1.5
@export var min_y: float = 0.0
## Abertura extra do campo de visao (graus) a velocidade maxima de corrida.
@export var speed_fov: float = 3.0

var base_fov: float = 75.0
var shake_left: float = 0.0
var shake_amplitude: float = 0.0

var _shake_time: float = 0.0


func _ready() -> void:
	base_fov = fov


## Tremor: `amplitude` em metros de deslocamento da imagem, decaindo ate zero em `duration` segundos.
func shake(amplitude: float, duration: float) -> void:
	if Accessibility.reduce_motion:
		return
	shake_amplitude = maxf(shake_amplitude * clampf(shake_left / 0.2, 0.0, 1.0), amplitude)
	shake_left = maxf(shake_left, duration)


func _physics_process(delta: float) -> void:
	_update_shake(delta)
	if target == null:
		return
	var ahead: float = 0.0
	var body := target as CharacterBody3D
	if body != null:
		ahead = clampf(body.velocity.x / 6.0, -1.0, 1.0) * look_ahead
		var wide: float = 0.0 if Accessibility.reduce_motion else clampf(absf(body.velocity.x) / 8.0, 0.0, 1.0) * speed_fov
		fov = lerpf(fov, base_fov + wide, clampf(3.0 * delta, 0.0, 1.0))
	var goal := Vector3(target.global_position.x + ahead + offset.x,
			maxf(target.global_position.y, min_y) + offset.y, offset.z)
	global_position = global_position.lerp(goal, clampf(follow_speed * delta, 0.0, 1.0))
	global_position.z = offset.z


func _update_shake(delta: float) -> void:
	if shake_left <= 0.0:
		h_offset = 0.0
		v_offset = 0.0
		return
	shake_left = maxf(shake_left - delta, 0.0)
	_shake_time += delta
	var strength: float = shake_amplitude * clampf(shake_left / 0.2, 0.0, 1.0)
	h_offset = sin(_shake_time * 71.0) * strength
	v_offset = cos(_shake_time * 53.0) * strength
