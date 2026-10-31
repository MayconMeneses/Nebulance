class_name GameFlow
extends Node
## Fluxo do jogo: MainMenu -> Level (com introducao) -> Results -> MainMenu. Unico dono do perfil e do save.

enum State { MAIN_MENU, MAP, LEVEL, RESULTS }

const BENCH_SCENE: String = "res://tests/scenes/bench.tscn"

@export var save_path: String = "user://saves/slot1.json"
@export var settings_path: String = "user://settings.json"
@export var play_intro: bool = true
## Quadros de aquecimento de shaders atras da tela de carregamento (0 = sem aquecimento; o jogo real usa 24 via main.tscn).
@export var warmup_frames: int = 0
## Falso no fluxo criado pelo proprio benchmark (evita criar benchmark dentro de benchmark).
var dev_hooks: bool = true

var state: State = State.MAIN_MENU
var profile: Dictionary = {}
var service: SaveService
var level: LevelScene
var menu: MainMenu
var hud: Hud
var results: ResultsScreen
var intro: ArrivalIntro
var audio: AudioDirector
var last_save_error: Error = OK
var settings: SettingsStore
var settings_menu: SettingsMenu
var map: GalaxyMap
var origin_level: LevelScene
var reaction_plays: int = 0

var _pause_layer: CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Gancho de desenvolvimento: "--bench" roda o benchmark de jogo real (so se a cena existir no pacote).
	if dev_hooks and "--bench" in OS.get_cmdline_user_args() and ResourceLoader.exists(BENCH_SCENE):
		add_child((load(BENCH_SCENE) as PackedScene).instantiate())
		return
	service = SaveService.new(save_path)
	settings = SettingsStore.new(settings_path)
	settings.load_settings()
	KeyBindings.apply(settings.data["keys"])
	GraphicsApplier.apply(get_viewport(), settings.data, get_tree())
	audio = AudioDirector.new()
	add_child(audio)
	_show_menu()


## skip_map: usado pelos testes para ir direto a fase (o fluxo normal passa pelo Mapa Galactico).
func start_new_game(skip_map: bool = false) -> void:
	if FileAccess.file_exists(service.path):
		service.archive_existing()
	profile = SaveData.new_game()
	last_save_error = service.save(profile)
	_start_level() if skip_map else _show_map()


func continue_game(skip_map: bool = false, level_id: String = "") -> void:
	var loaded: Dictionary = service.load_save()
	if loaded["data"].is_empty():
		return
	profile = loaded["data"]
	_start_level(level_id) if skip_map else _show_map()


func _show_map() -> void:
	if menu != null:
		menu.queue_free()
		menu = null
	state = State.MAP
	map = GalaxyMap.new()
	add_child(map)
	map.show_state(profile)
	map.travel_requested.connect(func(planet_id: StringName) -> void: _start_level(LevelCatalog.next_for(profile, String(planet_id))))
	map.back_pressed.connect(_back_to_menu)


func show_settings() -> void:
	if menu != null:
		menu.queue_free()
		menu = null
	settings_menu = SettingsMenu.new()
	settings_menu.setup(settings)
	add_child(settings_menu)
	settings_menu.changed.connect(func(data: Dictionary) -> void: GraphicsApplier.apply(get_viewport(), data, get_tree()))
	settings_menu.back_pressed.connect(func() -> void:
		settings_menu.queue_free()
		settings_menu = null
		_show_menu())


func _show_menu() -> void:
	state = State.MAIN_MENU
	var loaded: Dictionary = service.load_save()
	var status: int = loaded["status"]
	menu = MainMenu.new()
	add_child(menu)
	menu.continue_pressed.connect(continue_game)
	menu.new_game_pressed.connect(start_new_game)
	menu.settings_pressed.connect(show_settings)
	menu.quit_pressed.connect(func() -> void: get_tree().quit())
	var has_data: bool = not loaded["data"].is_empty()
	menu.refresh(has_data, loaded["message"], status != SaveService.Status.FUTURE_VERSION)


func _start_level(level_id: String = "") -> void:
	if menu != null:
		menu.queue_free()
		menu = null
	if map != null:
		map.queue_free()
		map = null
	state = State.LEVEL
	var id: String = level_id if level_id != "" else LevelCatalog.next_for(profile, "sylvara")
	level = LevelCatalog.make(id)
	level.save = profile
	# O fluxo roda em ALWAYS (menu/pausa); a fase precisa ser pausavel explicitamente.
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(level)
	GraphicsApplier.apply(get_viewport(), settings.data, get_tree())
	level.completed.connect(_on_completed)
	level.controller.sfx_requested.connect(audio.play_sfx)
	level.controller.portal_requested.connect(_on_portal)
	if level.has_signal("seed_destroyed"):
		level.connect("seed_destroyed", _on_seed_destroyed)
	hud = Hud.new()
	add_child(hud)
	hud.bind(level)
	audio.play_music("res://assets/audio/music_sylvara.wav")
	if warmup_frames > 0:
		level.rig.body.set_locked_state(MovementState.State.CUTSCENE)
		var warm := ShaderWarmup.new()
		add_child(warm)
		warm.finished.connect(_after_warmup)
		warm.run(level, warmup_frames)
	else:
		_after_warmup()


func _after_warmup() -> void:
	if level == null or not is_instance_valid(level):
		return
	if warmup_frames > 0 and not play_intro:
		level.rig.body.set_locked_state(-1)
	if play_intro:
		level.rig.body.set_locked_state(MovementState.State.CUTSCENE)
		if level.astralis != null:
			level.astralis.arrive(ArrivalIntro.DURATION - 0.5)
		intro = ArrivalIntro.new()
		add_child(intro)
		intro.finished.connect(_on_intro_finished)


## Portal: a fase de origem fica viva (pausada e oculta); a secreta roda por cima e o retorno preserva tudo.
func _on_portal(portal_id: StringName, destination: StringName) -> void:
	if origin_level != null or not LevelCatalog.has(String(destination)):
		return
	if not String(portal_id) in profile["world"]["portal_ids"]:
		profile["world"]["portal_ids"].append(String(portal_id))
	origin_level = level
	origin_level.process_mode = Node.PROCESS_MODE_DISABLED
	origin_level.visible = false
	level = LevelCatalog.make(String(destination))
	level.save = profile
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(level)
	level.camera.make_current()
	level.completed.connect(_on_secret_completed)
	level.controller.sfx_requested.connect(audio.play_sfx)
	hud.bind(level)
	GraphicsApplier.apply(get_viewport(), settings.data, get_tree())


func _on_secret_completed(receipt: Dictionary) -> void:
	state = State.RESULTS
	last_save_error = service.save(profile)
	results = ResultsScreen.new()
	add_child(results)
	results.show_receipt(level.definition.display_name, receipt, profile["economy"]["coin_balance"], last_save_error == OK)
	results.continue_pressed.connect(_return_from_portal)


func _return_from_portal() -> void:
	if results != null:
		results.queue_free()
		results = null
	level.queue_free()
	level = origin_level
	origin_level = null
	level.visible = true
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	level.camera.make_current()
	hud.bind(level)
	state = State.LEVEL


## A destruicao da semente e salva NA HORA (nao so ao abrir o bau); a reacao de Caeldron toca so na primeira vez.
func _on_seed_destroyed(first_time: bool) -> void:
	last_save_error = service.save(profile)
	if first_time:
		reaction_plays += 1
		var reaction := CaeldronReaction.new()
		var custom: Variant = level.get("reaction_message")
		if custom is String and custom != "":
			reaction.message = custom
		add_child(reaction)


func _on_intro_finished() -> void:
	if level != null:
		if level.astralis != null:
			level.astralis.skip()
		if not level.controller.completed:
			level.rig.body.set_locked_state(-1)


func _on_completed(receipt: Dictionary) -> void:
	state = State.RESULTS
	last_save_error = service.save(profile)
	results = ResultsScreen.new()
	add_child(results)
	results.show_receipt(level.definition.display_name, receipt, profile["economy"]["coin_balance"], last_save_error == OK)
	results.continue_pressed.connect(_after_results)


func _after_results() -> void:
	_cleanup_level()
	_show_map()


func _cleanup_level() -> void:
	for node in [results, hud, level, intro, _pause_layer]:
		if node != null and is_instance_valid(node):
			node.queue_free()
	results = null
	hud = null
	level = null
	_pause_layer = null
	get_tree().paused = false
	audio.stop_music()


func _back_to_menu() -> void:
	if map != null:
		map.queue_free()
		map = null
	for node in [results, hud, level, intro, _pause_layer]:
		if node != null and is_instance_valid(node):
			node.queue_free()
	results = null
	hud = null
	level = null
	_pause_layer = null
	get_tree().paused = false
	audio.stop_music()
	_show_menu()


func is_paused() -> bool:
	return _pause_layer != null


func toggle_pause() -> void:
	if state != State.LEVEL:
		return
	if _pause_layer != null:
		_pause_layer.queue_free()
		_pause_layer = null
		get_tree().paused = false
		return
	get_tree().paused = true
	_pause_layer = CanvasLayer.new()
	_pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	var box := VBoxContainer.new()
	box.position = Vector2(500.0, 240.0)
	_pause_layer.add_child(box)
	var title := Label.new()
	title.text = "PAUSADO"
	title.add_theme_font_size_override(&"font_size", 34)
	box.add_child(title)
	var resume := Button.new()
	resume.text = "Continuar"
	resume.pressed.connect(toggle_pause)
	box.add_child(resume)
	var quit := Button.new()
	quit.text = "Voltar ao menu (o progresso da fase em curso nao e salvo)"
	quit.pressed.connect(_back_to_menu)
	box.add_child(quit)
	add_child(_pause_layer)
	resume.grab_focus()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pause"):
		toggle_pause()
