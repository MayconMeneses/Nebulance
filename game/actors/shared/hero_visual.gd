class_name HeroVisual
extends Node3D
## Visual 3D de um heroi (modelo .glb + AnimationPlayer). Separado da fisica: sem colisao, sem logica de jogo.
## O modelo olha para +X; virar para a esquerda = girar 180 graus em Y (nunca scale.x = -1).

const MODEL_DIR: String = "res://assets/models/"
const BLEND_TIME: float = 0.1
const STATE_CLIPS: Dictionary = {
	MovementState.State.IDLE: &"idle",
	MovementState.State.RUN: &"run",
	MovementState.State.TAKEOFF: &"jump",
	MovementState.State.AIRBORNE: &"jump",
	MovementState.State.FALL: &"fall",
	MovementState.State.LAND: &"land",
	MovementState.State.SPECIAL: &"special",
	MovementState.State.INTERACT: &"idle",
	MovementState.State.HURT: &"hurt",
	MovementState.State.DEAD: &"hurt",
	MovementState.State.CUTSCENE: &"celebrate",
}

var hero_id: StringName = &""
var facing_target: float = 1.0
var current_clip: StringName = &""
var model: Node3D
var player: AnimationPlayer
var uses_fallback: bool = false
## Visual vestido (cosmetico): devolve o id do item do heroi pedido ("" = original). So colore; nao muda fisica nem habilidades.
var outfit_provider: Callable = Callable()
var outfit_id: String = ""

var _body: ActorController
var _profile: HeroProfile


func bind(body: ActorController, rig: TrioRig) -> void:
	_body = body
	body.state_changed.connect(set_state)
	rig.hero_changed.connect(show_hero)
	show_hero(rig.profiles[rig.active_index])


func show_hero(profile: HeroProfile) -> void:
	_profile = profile
	hero_id = profile.hero_id
	if model != null:
		model.queue_free()
		model = null
		player = null
	var path: String = "%s%s.glb" % [MODEL_DIR, String(profile.hero_id)]
	uses_fallback = not ResourceLoader.exists(path)
	model = _fallback(profile) if uses_fallback else (load(path) as PackedScene).instantiate() as Node3D
	add_child(model)
	position = Vector3(0.0, -profile.capsule_height * 0.5, 0.0)
	player = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	current_clip = &""
	_play(&"idle")
	refresh_outfit()


## Reaplica o cosmetico do heroi ativo no modelo atual (brilho translucido sobre todas as malhas).
func refresh_outfit() -> void:
	outfit_id = String(outfit_provider.call(hero_id)) if outfit_provider.is_valid() else ""
	if model == null:
		return
	var overlay: StandardMaterial3D = null
	if outfit_id != "":
		var color: Color = CosmeticCatalog.tint_of(outfit_id)
		overlay = StandardMaterial3D.new()
		overlay.albedo_color = Color(color.r, color.g, color.b, 0.45)
		overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		overlay.emission_enabled = true
		overlay.emission = color
		overlay.emission_energy_multiplier = 0.6
	for n in model.find_children("*", "GeometryInstance3D", true, false):
		(n as GeometryInstance3D).material_overlay = overlay


func set_state(state: int) -> void:
	_play(STATE_CLIPS.get(state, &"idle"))


func has_clip(clip: StringName) -> bool:
	return player != null and player.has_animation(clip)


func _process(delta: float) -> void:
	if _body != null:
		facing_target = _body.facing
		if player != null and current_clip == &"run" and _profile != null:
			player.speed_scale = clampf(absf(_body.velocity.x) / _profile.tuning.run_speed, 0.5, 1.4)
		elif player != null:
			player.speed_scale = 1.0
	var target_y: float = 0.0 if facing_target >= 0.0 else PI
	rotation.y = lerp_angle(rotation.y, target_y, clampf(18.0 * delta, 0.0, 1.0))
	if _body != null and _profile != null:
		# Teto como piso (gravidade invertida): o modelo vira de cabeca para baixo e os pes ficam no alto da capsula.
		var upside_down: bool = _body.gravity_dir < 0.0
		rotation.x = lerp_angle(rotation.x, PI if upside_down else 0.0, clampf(18.0 * delta, 0.0, 1.0))
		position.y = -_profile.capsule_height * 0.5 * _body.gravity_dir


func _play(clip: StringName) -> void:
	if player == null or clip == current_clip or not player.has_animation(clip):
		return
	current_clip = clip
	player.play(clip, BLEND_TIME)


func _fallback(profile: HeroProfile) -> Node3D:
	var holder := Node3D.new()
	var mi := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = profile.capsule_radius
	capsule.height = profile.capsule_height
	mi.mesh = capsule
	mi.position.y = profile.capsule_height * 0.5
	holder.add_child(mi)
	return holder
