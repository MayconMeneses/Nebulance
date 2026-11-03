class_name EffectsDirector
extends Node3D
## Efeitos de particulas pontuais (CPUParticles3D). Quantidade escalada pelo perfil grafico; escala 0 = sem efeitos.
## Puramente visual: nao altera estado de jogo.

const KINDS: Dictionary = {
	&"coin": {"amount": 10, "color": Color("EDB85E"), "speed": 3.0, "life": 0.45},
	&"item": {"amount": 16, "color": Color("56DDB5"), "speed": 3.5, "life": 0.6},
	&"checkpoint": {"amount": 24, "color": Color("23CFF5"), "speed": 4.5, "life": 0.7},
	&"chest": {"amount": 30, "color": Color("EDB85E"), "speed": 5.0, "life": 0.9},
	&"hurt": {"amount": 12, "color": Color("DE5145"), "speed": 4.0, "life": 0.4},
	&"land": {"amount": 8, "color": Color("B9C2CC"), "speed": 2.0, "life": 0.35},
}
const SFX_TO_KIND: Dictionary = {&"coin": &"coin", &"item": &"item", &"checkpoint": &"checkpoint", &"chest": &"chest", &"hurt": &"hurt"}

var active: int = 0
var spawned_total: int = 0

var _body: ActorController


func bind(controller: LevelController, body: ActorController) -> void:
	_body = body
	controller.sfx_requested.connect(_on_sfx)
	body.landed.connect(func() -> void: burst(&"land", body.global_position + Vector3(0.0, -body.collision_shape.shape.get("height") * 0.5 * body.gravity_dir, 0.0)))


func burst(kind: StringName, at: Vector3) -> CPUParticles3D:
	var scale: float = GraphicsProfile.particle_scale
	var spec: Dictionary = KINDS.get(kind, {})
	if scale <= 0.0 or spec.is_empty():
		return null
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.explosiveness = 0.9
	p.amount = maxi(1, int(round(float(spec["amount"]) * scale)))
	p.lifetime = spec["life"]
	p.direction = Vector3.UP
	p.spread = 180.0 if kind != &"land" else 70.0
	p.initial_velocity_min = spec["speed"] * 0.5
	p.initial_velocity_max = spec["speed"]
	p.gravity = Vector3(0.0, -6.0, 0.0)
	var mesh := SphereMesh.new()
	mesh.radius = 0.06
	mesh.height = 0.12
	var mat := StandardMaterial3D.new()
	mat.albedo_color = spec["color"]
	mat.emission_enabled = true
	mat.emission = spec["color"]
	mesh.material = mat
	p.mesh = mesh
	p.position = at
	add_child(p)
	p.emitting = true
	active += 1
	spawned_total += 1
	p.finished.connect(func() -> void:
		active -= 1
		p.queue_free())
	return p


func _on_sfx(sfx_name: StringName) -> void:
	if _body != null and SFX_TO_KIND.has(sfx_name):
		burst(SFX_TO_KIND[sfx_name], _body.global_position)
