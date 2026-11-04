class_name HeroAura
extends Node3D
## Luz propria do heroi ativo (cor do heroi, acende as pecas ao redor) e poeira nos pes ao correr no chao. So aparencia: sem colisao.
## "Reduzir movimento" e a escala de particulas do perfil grafico (0 = nada) apagam a poeira; a luz continua.

const COLORS: Dictionary = {&"rocco": Color("F08A3B"), &"zuri": Color("56DDB5"), &"pipa": Color("5BB8FF")}
const RUN_SPEED: float = 3.0

var light: OmniLight3D
var dust: CPUParticles3D
var tint: Color = Color.WHITE

var _body: ActorController


func bind(body: ActorController, rig: TrioRig) -> void:
	_body = body
	rig.hero_changed.connect(func(profile: HeroProfile) -> void: set_hero(profile.hero_id))
	set_hero(rig.profiles[rig.active_index].hero_id)


func set_hero(hero_id: StringName) -> void:
	tint = COLORS.get(hero_id, Color.WHITE)
	if light != null:
		light.light_color = tint


## Poeira so correndo no chao, com movimento e particulas ligados.
static func dust_active(speed_x: float, on_floor: bool) -> bool:
	return on_floor and absf(speed_x) > RUN_SPEED and not Accessibility.reduce_motion and GraphicsProfile.particle_scale > 0.0


func _ready() -> void:
	light = OmniLight3D.new()
	light.light_color = tint
	light.light_energy = 0.7
	light.omni_range = 5.0
	light.shadow_enabled = false
	light.position = Vector3(0.0, 0.4, 0.8)
	add_child(light)
	dust = CPUParticles3D.new()
	dust.position = Vector3(0.0, -0.8, 0.0)
	dust.amount = maxi(int(14.0 * GraphicsProfile.particle_scale), 1)
	dust.lifetime = 0.45
	dust.local_coords = false
	dust.emitting = false
	dust.direction = Vector3(0.0, 1.0, 0.0)
	dust.spread = 50.0
	dust.initial_velocity_min = 0.4
	dust.initial_velocity_max = 1.2
	dust.gravity = Vector3(0.0, 0.5, 0.0)
	var puff := SphereMesh.new()
	puff.radius = 0.09
	puff.height = 0.18
	puff.radial_segments = 6
	puff.rings = 3
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.75, 0.85, 0.95, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff.material = mat
	dust.mesh = puff
	dust.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(dust)


func _physics_process(_delta: float) -> void:
	if _body != null:
		dust.emitting = dust_active(_body.velocity.x, _body.is_on_floor())
