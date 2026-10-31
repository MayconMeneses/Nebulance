class_name PolarityPlatform
extends AnimatableBody3D
## Plataforma de polaridade: com o controle (Mecanismo) desligado fica na origem; ligado, vai ate o outro polo ao longo de `axis`,
## a velocidade fixa. Elevador e trilho horizontal sao a mesma peca. Posicao em [0,1] capturavel (checkpoint/reinicio).

@export var size: Vector3 = Vector3(3.0, 0.4, 3.0)
@export var axis: Vector3 = Vector3(0.0, 6.0, 0.0)
@export var speed: float = 3.0
var control: Mechanism

var progress: float = 0.0
var _origin: Vector3
var _material: StandardMaterial3D


func _ready() -> void:
	add_to_group(&"snapshotable")
	sync_to_physics = true
	collision_layer = PhysicsLayers.WORLD
	collision_mask = 0
	_origin = position
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material = _material
	mi.mesh = mesh
	add_child(mi)
	_apply()


func target() -> float:
	return 1.0 if control != null and control.is_active else 0.0


func _physics_process(delta: float) -> void:
	var step: float = speed * delta / maxf(axis.length(), 0.001)
	progress = move_toward(progress, target(), step)
	_apply()


func capture() -> Variant:
	return progress


func restore(state: Variant) -> void:
	progress = float(state)
	_apply()


func _apply() -> void:
	position = _origin + axis * progress
	if _material != null:
		var c: Color = Color("F08A3B") if target() > 0.5 else Color("5AA9E6")
		_material.albedo_color = c
		_material.emission = c
