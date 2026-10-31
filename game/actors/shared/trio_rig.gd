class_name TrioRig
extends Node3D
## Monta o trio: um ActorController, vitais compartilhados, troca e checkpoint.

signal hero_changed(profile: HeroProfile)
signal level_restart_requested
signal checkpoint_reached(zone_id: StringName)

@export var profiles: Array[HeroProfile] = []
@export var difficulty: DifficultyProfile
@export var use_input_reader: bool = true

var body: ActorController
var vitals: TrioVitals
var checkpoint_position: Vector3 = Vector3.ZERO
var active_index: int = 0
var last_checkpoint_id: StringName = &""

var _swapper: HeroSwapper = HeroSwapper.new()
var _reader: InputReader


func _ready() -> void:
	body = ActorController.new()
	body.name = "Body"
	add_child(body)
	vitals = TrioVitals.new()
	vitals.name = "Vitals"
	add_child(vitals)
	vitals.setup(difficulty)
	body.vitals = vitals
	vitals.life_lost.connect(_on_life_lost)
	vitals.lives_exhausted.connect(_on_lives_exhausted)
	if use_input_reader:
		_reader = InputReader.new()
		add_child(_reader)
		body.intent_provider = _reader.read
	body.apply_profile(profiles[0], false)
	checkpoint_position = body.global_position


func _physics_process(_delta: float) -> void:
	var step: int = body.current_intent.swap_dir
	if step != 0:
		request_swap((active_index + step + profiles.size()) % profiles.size())
	for zone in body.overlaps(PhysicsLayers.CHECKPOINT):
		if zone is Node3D:
			checkpoint_position = (zone as Node3D).global_position
			var zone_id: StringName = zone.get("zone_id") if zone.get("zone_id") != null else &""
			if zone_id != last_checkpoint_id:
				last_checkpoint_id = zone_id
				checkpoint_reached.emit(zone_id)


func request_swap(index: int) -> HeroSwapper.Result:
	var result: HeroSwapper.Result = _swapper.swap(body, profiles[index])
	if result == HeroSwapper.Result.OK:
		active_index = index
		hero_changed.emit(profiles[index])
	return result


func _on_life_lost(_reason: StringName) -> void:
	body.respawn(checkpoint_position)


func _on_lives_exhausted() -> void:
	level_restart_requested.emit()
	vitals.reset_level()
	body.respawn(checkpoint_position)
