class_name ConveyorBelt
extends StaticBody3D
## Esteira: carrega o heroi que esta em cima (velocidade constante do corpo). O sentido e fixo, ou invertido por um Mecanismo
## (`control`). O sentido e sempre derivado do estado do mecanismo; nada a capturar aqui. Setas indicam o sentido.

@export var size: Vector3 = Vector3(6.0, 0.4, 3.0)
@export var speed: float = 3.0
## +1 = para a direita, -1 = para a esquerda (antes de qualquer inversao).
@export var direction: float = 1.0
var control: Mechanism

var _arrows: Array[MeshInstance3D] = []


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("5B6573")
	mesh.material = mat
	mi.mesh = mesh
	add_child(mi)
	var count: int = maxi(int(size.x / 1.6), 1)
	for i in count:
		var arrow := MeshInstance3D.new()
		var prism := PrismMesh.new()
		prism.size = Vector3(0.6, 0.6, 0.1)
		var amat := StandardMaterial3D.new()
		amat.albedo_color = Color("F08A3B")
		amat.emission_enabled = true
		amat.emission = Color("F08A3B")
		prism.material = amat
		arrow.mesh = prism
		arrow.position = Vector3(-size.x * 0.5 + (i + 0.5) * size.x / count, size.y * 0.5 + 0.02, size.z * 0.5 + 0.06)
		add_child(arrow)
		_arrows.append(arrow)
	_update()


func effective_direction() -> float:
	if control != null and control.is_active:
		return -direction
	return direction


func _physics_process(_delta: float) -> void:
	_update()


func _update() -> void:
	var dir: float = effective_direction()
	constant_linear_velocity = Vector3(dir * speed, 0.0, 0.0)
	for a in _arrows:
		a.rotation_degrees.z = -90.0 if dir > 0.0 else 90.0
