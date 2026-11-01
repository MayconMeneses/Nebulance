class_name EchoStone
extends Area3D
## Pedra-eco de Umbraxis: uma de varias candidatas e a VERDADEIRA; as outras sao ilusoes. A diferenca e sempre uma EVIDENCIA observavel:
## - cue BLINK: a real e estavel, a ilusao pisca (alterna a cada 0,3 s; com "reduzir flashes" a ilusao fica parada, mais fraca);
## - cue SHAPE: a real e uma coluna cheia, a ilusao e fina e oca (forma, sem alternar nada).
## Tocar (E) a real avisa `real_touched` e estabiliza as plataformas de ruptura com o mesmo `link_id`. Tocar uma ilusao tira um coracao
## e avisa `wrong_touched`. Estado capturavel (a pedra real resolvida).

signal real_touched(stone: EchoStone)
signal wrong_touched(stone: EchoStone)

enum Cue { BLINK, SHAPE }

const BLINK_PERIOD: float = 0.3

@export var is_real: bool = false
@export var cue: Cue = Cue.BLINK
@export var link_id: StringName = &""

var enabled: bool = true
var solved: bool = false
var vitals: TrioVitals
var elapsed: float = 0.0

var _mesh_instance: MeshInstance3D
var _material: StandardMaterial3D


func _ready() -> void:
	add_to_group(&"snapshotable")
	add_to_group(&"echo_stones")
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 1.8, 1.6)
	shape.shape = box
	add_child(shape)
	_mesh_instance = MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.4
	mesh.bottom_radius = 0.4
	mesh.height = 1.4
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material = _material
	_mesh_instance.mesh = mesh
	add_child(_mesh_instance)
	_paint()


## Evidencia visual (BLINK): a real nunca alterna.
func steady() -> bool:
	return is_real or cue != Cue.BLINK or int(elapsed / BLINK_PERIOD) % 2 == 0


## Evidencia de forma (SHAPE): escala da coluna; a real e cheia (1,1,1), a ilusao e fina (0,35 de largura).
func body_scale() -> Vector3:
	return Vector3.ONE if (is_real or cue != Cue.SHAPE) else Vector3(0.35, 1.0, 0.35)


func can_interact() -> bool:
	return enabled and not solved and not _group_solved()


func prompt() -> String:
	return "Pressione E para tocar a pedra-eco"


func interact() -> void:
	if not can_interact():
		return
	if is_real:
		solved = true
		for platform in get_tree().get_nodes_in_group(&"rupture_platforms"):
			if link_id != &"" and platform.link_id == link_id:
				platform.stabilize()
		real_touched.emit(self)
	else:
		if vitals != null:
			vitals.hit()
		wrong_touched.emit(self)


func _group_solved() -> bool:
	if link_id == &"":
		return false
	for other in get_tree().get_nodes_in_group(&"echo_stones"):
		if other != self and other.link_id == link_id and other.solved:
			return true
	return false


func _physics_process(delta: float) -> void:
	elapsed += delta
	_paint()


func capture() -> Variant:
	return solved


func restore(state: Variant) -> void:
	solved = bool(state)
	elapsed = 0.0
	_paint()


func _paint() -> void:
	if _material == null:
		return
	var calm: bool = Accessibility.reduce_flashing
	var bright: bool = is_real or (not calm and steady())
	var c: Color = Color("C084FC") if bright else Color("56DDB5")
	if solved:
		c = Color("23CFF5")
	_material.albedo_color = c
	_material.emission = c
	_material.emission_energy_multiplier = 0.4 if (calm and not is_real) else 1.0
	_mesh_instance.scale = body_scale()
