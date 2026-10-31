class_name RupturePlatform
extends StaticBody3D
## Plataforma de ruptura (Sylvara): alterna SOLIDA/INTANGIVEL em ciclo deterministico, com aviso visual antes de sumir.
## `stabilize()` a mantem solida (feito pelo Estabilizador). Estado capturavel para o checkpoint.

@export var link_id: StringName = &""
@export var size: Vector3 = Vector3(3.0, 0.4, 3.0)
@export var solid_time: float = 2.2
@export var gone_time: float = 1.4
@export var warning_time: float = 0.6
@export var phase_offset: float = 0.0

var stabilized: bool = false
var elapsed: float = 0.0

var _shape: CollisionShape3D
var _material: StandardMaterial3D


func _ready() -> void:
	add_to_group(&"snapshotable")
	add_to_group(&"rupture_platforms")
	collision_mask = 0
	_shape = CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	_shape.shape = box
	add_child(_shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material = _material
	mi.mesh = mesh
	add_child(mi)
	_apply()


func is_solid() -> bool:
	return stabilized or fposmod(elapsed + phase_offset, solid_time + gone_time) < solid_time


func is_warning() -> bool:
	if stabilized:
		return false
	var t: float = fposmod(elapsed + phase_offset, solid_time + gone_time)
	return t < solid_time and t >= solid_time - warning_time


## Segundos ate a plataforma deixar de ser solida (0 se ja intangivel; muito grande se estabilizada).
func solid_remaining() -> float:
	if stabilized:
		return 999.0
	var t: float = fposmod(elapsed + phase_offset, solid_time + gone_time)
	return maxf(solid_time - t, 0.0)


func stabilize() -> void:
	stabilized = true
	_apply()


func _physics_process(delta: float) -> void:
	elapsed += delta
	_apply()


func capture() -> Variant:
	return {"elapsed": elapsed, "stabilized": stabilized}


func restore(state: Variant) -> void:
	elapsed = state["elapsed"]
	stabilized = state["stabilized"]
	_apply()


func _apply() -> void:
	var solid: bool = is_solid()
	collision_layer = PhysicsLayers.WORLD if solid else 0
	var color: Color = Color("3FD08A")
	if stabilized:
		color = Color("23CFF5")
	elif is_warning():
		color = Color("FFB02E")
	elif not solid:
		color = Color(0.55, 0.3, 0.9, 0.25)
	if _material != null:
		_material.albedo_color = color
		_material.emission = color
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if not solid else BaseMaterial3D.TRANSPARENCY_DISABLED
