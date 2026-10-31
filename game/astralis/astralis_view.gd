class_name AstralisView
extends Node3D
## Astralis em 3D (modelo unico reutilizado: introducao, menu e mapa). Pousa em `rest_position`.
## Pular e valido a qualquer momento e nao concede nem altera nada: so posiciona a nave.

signal arrived

const MODEL: String = "res://assets/models/astralis.glb"

@export var rest_position: Vector3 = Vector3(-5.0, 2.4, -4.5)
@export var rest_tilt_deg: float = 6.0

var is_arriving: bool = false
var model: Node3D
var glow: OmniLight3D

var _tween: Tween
var _engine: CPUParticles3D


func _ready() -> void:
	model = (load(MODEL) as PackedScene).instantiate() as Node3D
	add_child(model)
	glow = OmniLight3D.new()
	glow.light_color = Color("23CFF5")
	glow.omni_range = 6.0
	glow.light_energy = 1.2
	glow.position = Vector3(-3.2, 0.0, 0.0)
	add_child(glow)
	_engine = CPUParticles3D.new()
	_engine.position = Vector3(-3.1, 0.0, 0.0)
	_engine.amount = maxi(int(24.0 * GraphicsProfile.particle_scale), 1) if GraphicsProfile.particle_scale > 0.0 else 1
	_engine.emitting = GraphicsProfile.particle_scale > 0.0
	_engine.direction = Vector3(-1.0, 0.0, 0.0)
	_engine.spread = 8.0
	_engine.initial_velocity_min = 3.0
	_engine.initial_velocity_max = 5.0
	_engine.lifetime = 0.6
	_engine.gravity = Vector3.ZERO
	var mesh := SphereMesh.new()
	mesh.radius = 0.08
	mesh.height = 0.16
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("23CFF5")
	mat.emission_enabled = true
	mat.emission = Color("23CFF5")
	mesh.material = mat
	_engine.mesh = mesh
	add_child(_engine)
	place_at_rest()


func place_at_rest() -> void:
	position = rest_position
	rotation_degrees = Vector3(0.0, 0.0, rest_tilt_deg)


## Chegada: desce de longe ate pousar. Retorna imediatamente; emite `arrived` ao terminar (ou ao pular).
func arrive(duration: float = 3.5) -> void:
	is_arriving = true
	position = rest_position + Vector3(-40.0, 22.0, -10.0)
	rotation_degrees = Vector3(0.0, 0.0, 20.0)
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.set_parallel(true)
	_tween.tween_property(self, "position", rest_position, duration)
	_tween.tween_property(self, "rotation_degrees", Vector3(0.0, 0.0, rest_tilt_deg), duration)
	_tween.finished.connect(_finish, CONNECT_ONE_SHOT)


func skip() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	place_at_rest()
	_finish()


func _finish() -> void:
	if is_arriving:
		is_arriving = false
		arrived.emit()
