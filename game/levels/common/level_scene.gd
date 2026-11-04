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
var palette: Dictionary = {}


func _ready() -> void:
	definition = load(_definition_path()) as LevelDefinition
	var planet_id: StringName = definition.planet_id if definition != null else &""
	palette = PlanetPalette.of(planet_id, PlanetPalette.restored(save, planet_id))
	builder = SegmentBuilder.new(self)
	builder.trim_color = palette["trim"]
	_build_environment()
	_build_geometry(builder)
	_build_backdrop()
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
	visual.outfit_provider = func(hero: StringName) -> String: return CosmeticCatalog.equipped(save, hero)
	visual.bind(rig.body, rig)
	camera = SideCamera.new()
	camera.target = rig.body
	camera.position = Vector3(_start_position().x, 3.0, 12.0)
	add_child(camera)
	_build_ambience()
	rig.body.landed.connect(func() -> void: camera.shake(0.07, 0.16))
	var hearts: Array[int] = [rig.vitals.hearts]
	rig.vitals.hearts_changed.connect(func(now: int) -> void:
		if now < hearts[0]:
			camera.shake(0.22, 0.3)
		hearts[0] = now)


func _build_environment() -> void:
	var we := WorldEnvironment.new()
	we.environment = LevelAtmosphere.environment(palette)
	we.add_to_group(LevelAtmosphere.GROUP)
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50.0, -30.0, 0.0)
	sun.light_color = palette["sun"]
	sun.light_energy = palette["sun_energy"]
	# Sombra barata: uma so camada ortogonal e alcance curto (a camera lateral so ve a vizinhanca do heroi).
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 45.0
	sun.add_to_group(&"main_light")
	add_child(sun)


## Clima do planeta (particulas), planeta gigante no ceu e vinheta: tudo preso a camera; so aparencia.
func _build_ambience() -> void:
	var planet_id: StringName = definition.planet_id if definition != null else &""
	var weather := AmbientWeather.new()
	camera.add_child(weather)
	weather.setup(planet_id)
	if PlanetPalette.TINTS.has(planet_id):
		var sky := SkyPlanet.new()
		camera.add_child(sky)
		sky.setup(planet_id, PlanetPalette.restored(save, planet_id))
	add_child(ScreenVignette.new())


## Fundo de profundidade (pilones, aneis e estrelas) ao longo do comprimento da fase; so decoracao.
func _build_backdrop() -> void:
	var backdrop := FuturisticBackdrop.new()
	backdrop.style = BackdropStyles.style_of(definition.planet_id if definition != null else &"")
	add_child(backdrop)
	var from_x: float = builder.min_x if builder.min_x < INF else 0.0
	var to_x: float = builder.max_x if builder.max_x > -INF else 60.0
	backdrop.build(from_x, to_x, palette, String(definition.level_id) if definition != null else "level")
