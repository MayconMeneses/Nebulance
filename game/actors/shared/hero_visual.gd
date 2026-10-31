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
