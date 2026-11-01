class_name WaterBody
extends Node3D
## Reservatorio de Aquarys SEM fisica de fluidos: o nivel e um inteiro discreto (0..max_level) escolhido por comportas; a altura da
## superficie sobe/desce a velocidade fixa ate o nivel-alvo. Plataformas flutuantes e passarelas leem o nivel. Estado capturavel.

signal level_changed(level: int)

@export var base_y: float = -1.2
@export var step: float = 0.6
@export var max_level: int = 2
@export var rise_speed: float = 1.5
@export var initial_level: int = 0
@export var surface_size: Vector2 = Vector2(40.0, 3.0)

var level: int = 0
var height: float = 0.0

var _surface: MeshInstance3D


func _ready() -> void:
	add_to_group(&"snapshotable")
	level = initial_level
	height = target_height()
	_surface = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(surface_size.x, 0.1, surface_size.y)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.14, 0.81, 0.96, 0.45)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color("23CFF5")
	mat.emission_energy_multiplier = 0.4
	mesh.material = mat
	_surface.mesh = mesh
	add_child(_surface)
	_apply()


func target_height() -> float:
	return base_y + step * level


func set_level(new_level: int) -> void:
	var clamped: int = clampi(new_level, 0, max_level)
	if clamped == level:
		return
	level = clamped
	level_changed.emit(level)


func is_settled() -> bool:
	return is_equal_approx(height, target_height())


func _physics_process(delta: float) -> void:
	height = move_toward(height, target_height(), rise_speed * delta)
	_apply()


func capture() -> Variant:
	return level


func restore(saved: Variant) -> void:
	level = int(saved)
	height = target_height()
	_apply()
	level_changed.emit(level)


func _apply() -> void:
	if _surface != null:
		_surface.position.y = height
