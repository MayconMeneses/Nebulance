class_name LevelScene
extends Node3D
## Base de toda fase: ambiente, trio, camera, visual, efeitos, Astralis (opcional) e LevelController.
## Cada fase herda e implementa so `_definition_path()` e `_build_geometry()`.

signal completed(receipt: Dictionary)

const DATA: String = "res://game/actors/data/"

var save: Dictionary = SaveData.new_game()
var use_input_reader: bool = true
var rig: TrioRig
var controller: LevelController
var definition: LevelDefinition
var camera: SideCamera
var visual: HeroVisual
var astralis: AstralisView
var effects: EffectsDirector
var builder: SegmentBuilder


func _ready() -> void:
	definition = load(_definition_path()) as LevelDefinition
	builder = SegmentBuilder.new(self)
	_build_environment()
	_build_geometry(builder)
	if _has_astralis():
		astralis = AstralisView.new()
		add_child(astralis)
	_build_rig()
	controller = LevelController.new()
	controller.name = "LevelController"
	add_child(controller)
	controller.setup(rig, definition, save)
	effects = EffectsDirector.new()
	add_child(effects)
	effects.bind(controller, rig.body)
	controller.level_completed.connect(func(receipt: Dictionary) -> void: completed.emit(receipt))
	_after_setup()


func _definition_path() -> String:
	return ""


func _build_geometry(_b: SegmentBuilder) -> void:
	pass


func _start_position() -> Vector3:
	return Vector3(0.0, 1.0, 0.0)


func _has_astralis() -> bool:
	return false


## Gancho para fases ligarem mecanismos que precisam do controller/rig prontos.
func _after_setup() -> void:
	pass


func _build_rig() -> void:
	rig = TrioRig.new()
	var profiles: Array[HeroProfile] = []
	for id in ["rocco", "zuri", "pipa"]:
		profiles.append(load(DATA + id + ".tres") as HeroProfile)
	rig.profiles = profiles
	rig.difficulty = load(DATA + "difficulty_adventure.tres") as DifficultyProfile
	rig.use_input_reader = use_input_reader
	rig.position = _start_position()
	add_child(rig)
	visual = HeroVisual.new()
	rig.body.add_child(visual)
	visual.bind(rig.body, rig)
	camera = SideCamera.new()
	camera.target = rig.body
	camera.position = Vector3(_start_position().x, 3.0, 12.0)
	add_child(camera)


func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("0B1F2A")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("7FD6C8")
	env.ambient_light_energy = 0.7
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50.0, -30.0, 0.0)
	sun.light_color = Color("FFE9C4")
	sun.add_to_group(&"main_light")
	add_child(sun)
