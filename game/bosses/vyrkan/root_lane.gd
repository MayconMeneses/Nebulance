class_name RootLane
extends Area3D
## Faixa de ataque de um chefe. So FERE no estado ACTIVE; no TELEGRAPH e so um aviso visual (amarelo). O PERFIL define o volume dentro
## da coluna da faixa (largura e profundidade nao mudam): ROOT = erupcao baixa de 3 m (plataformas altas sao refugio); cada chefe tem um
## perfil proprio para as faixas de assinatura a partir da fase 2 (mordida alta, petalas no ar, espinhos rasteiros, onda baixa, rajada
## alta, fenda). O volume avisado (caixa translucida) e o volume que fere: nada de dano por sobreposicao ambigua.

enum State { IDLE, TELEGRAPH, ACTIVE, RECOVER }

## Perfis: (y minimo, y maximo) do volume, em metros acima do piso.
const PROFILES: Dictionary = {
	&"root": Vector2(0.0, 3.0), &"bite": Vector2(0.0, 8.0), &"petal": Vector2(2.0, 6.5), &"spike": Vector2(0.0, 0.9),
	&"wave": Vector2(0.0, 1.6), &"gust": Vector2(0.0, 12.0), &"rift": Vector2(0.0, 5.0),
}
const DEPTH: float = 3.0

@export var lane_index: int = 0
@export var width: float = 3.0

var state: State = State.IDLE
var remaining: float = 0.0
var profile: StringName = &"root"

var _material: StandardMaterial3D
var _box: BoxShape3D
var _shape: CollisionShape3D
var _mesh: BoxMesh
var _mesh_instance: MeshInstance3D


func _ready() -> void:
	collision_mask = 0
	_shape = CollisionShape3D.new()
	_box = BoxShape3D.new()
	_shape.shape = _box
	add_child(_shape)
	_mesh_instance = MeshInstance3D.new()
	_mesh = BoxMesh.new()
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	_mesh.material = _material
	_mesh_instance.mesh = _mesh
	add_child(_mesh_instance)
	set_profile(profile)
	set_state(State.IDLE, 0.0)


## Troca o volume da faixa (nao mexe no estado do ciclo). Perfil desconhecido volta a ROOT.
func set_profile(id: StringName) -> void:
	profile = id if PROFILES.has(id) else &"root"
	var span: Vector2 = PROFILES[profile]
	var height: float = span.y - span.x
	_box.size = Vector3(width, height, DEPTH)
	_shape.position.y = span.x + height * 0.5
	if profile == &"root":
		_mesh.size = Vector3(width, 0.2, DEPTH)
		_mesh_instance.position.y = 0.1
	else:
		_mesh.size = _box.size
		_mesh_instance.position.y = _shape.position.y


## O ponto (em coordenadas do mundo) esta dentro do volume que fere quando a faixa esta ACTIVE?
func covers(point: Vector3) -> bool:
	var local: Vector3 = point - global_position
	return absf(local.x) <= _box.size.x * 0.5 and absf(local.y - _shape.position.y) <= _box.size.y * 0.5 and absf(local.z) <= DEPTH * 0.5


func set_state(new_state: State, time: float) -> void:
	state = new_state
	remaining = time
	collision_layer = PhysicsLayers.HAZARD if state == State.ACTIVE else 0
	var c: Color = [Color(0.3, 0.2, 0.35), Color("FFE14A"), Color("E0302C"), Color("5E5A70")][state]
	_material.emission = c if state != State.IDLE else Color.BLACK
	if profile != &"root":
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		c.a = [0.05, 0.3, 0.6, 0.1][state]
	_material.albedo_color = c
