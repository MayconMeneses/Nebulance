class_name WindVent
extends Area3D
## Corrente de vento de Aerion (camada WIND): empurra/ergue quem planeia ou esta no ar (ver ZoneEffects). Pode ser permanente ou
## depender de um painel (`control` ativo) e de uma barreira de Rocco quebrada (`blocker`). Estado DERIVADO (nada a capturar):
## o painel e a barreira ja sao capturados no checkpoint e a corrente os acompanha a cada quadro.

@export var size: Vector3 = Vector3(6.0, 8.0, 3.0)
## Empurrao quando a corrente esta soprando (x: vento horizontal no ar; y: sustentacao do planeio).
@export var wind_on: Vector3 = Vector3(0.0, 23.0, 0.0)
@export var control: Mechanism
@export var blocker: ImpactBarrier

## Lido por ZoneEffects (mesma propriedade das zonas de nivel).
var wind_push: Vector3 = Vector3.ZERO
var gravity_scale: float = 1.0

var _mat: StandardMaterial3D
## Faixas de vento (so visual): sopram na direcao da corrente enquanto ela esta ativa; quantidade pelo perfil grafico/acessibilidade.
var streaks: CPUParticles3D


func _ready() -> void:
	collision_layer = PhysicsLayers.WIND
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	_mat = StandardMaterial3D.new()
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.emission_enabled = true
	mesh.material = _mat
	mi.mesh = mesh
	add_child(mi)
	_build_streaks()
	_apply()


func _build_streaks() -> void:
	var dir: Vector3 = wind_on.normalized() if wind_on.length() > 0.01 else Vector3.UP
	var vertical: bool = absf(dir.y) > absf(dir.x)
	var travel: float = size.y if vertical else size.x
	var speed: float = clampf(wind_on.length() * 0.2, 3.0, 8.0)
	streaks = CPUParticles3D.new()
	streaks.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	streaks.emission_box_extents = size * 0.5
	streaks.direction = dir
	streaks.spread = 4.0
	streaks.initial_velocity_min = speed * 0.8
	streaks.initial_velocity_max = speed
	streaks.gravity = Vector3.ZERO
	streaks.lifetime = clampf(travel / speed, 0.5, 2.5)
	streaks.amount = maxi(1, int(round(18.0 * GraphicsProfile.particle_scale)))
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.04, 0.6, 0.04) if vertical else Vector3(0.6, 0.04, 0.04)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.97, 1.0, 0.7)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mat
	streaks.mesh = mesh
	streaks.emitting = false
	add_child(streaks)


func is_blowing() -> bool:
	if control != null and not control.is_active:
		return false
	if blocker != null and not blocker.is_broken:
		return false
	return true


func _physics_process(_delta: float) -> void:
	_apply()


func _apply() -> void:
	var on: bool = is_blowing()
	wind_push = wind_on if on else Vector3.ZERO
	if streaks != null:
		streaks.emitting = on and GraphicsProfile.particle_scale > 0.0
	if _mat != null:
		_mat.albedo_color = Color(0.7, 0.92, 1.0, 0.16) if on else Color(0.4, 0.4, 0.5, 0.05)
		_mat.emission = Color("7FE9F5") if on else Color.BLACK
		_mat.emission_energy_multiplier = 0.25
