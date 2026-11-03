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
var liberation_plays: int = 0
## Sequencia final (morte de Caeldron) e creditos: contadores para os testes; a sequencia so toca na primeira vez (ProgressLedger).
var ending_plays: int = 0
var credits_plays: int = 0
var _ending_active: bool = false
## Consulta de atualizacao ao abrir (so o jogo real liga; testes e benchmark nao usam a rede).
@export var check_updates: bool = false
var latest_update: Dictionary = {}

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
	if check_updates and settings.data["check_updates"]:
		var checker := UpdateChecker.new()
		add_child(checker)
		checker.update_available.connect(_on_update_available)
		checker.check()


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
	FlowMenus.show_map(self)


func show_settings() -> void:
	FlowMenus.show_settings(self)


func _show_menu() -> void:
	FlowMenus.show_menu(self)


func _on_update_available(version: String, url: String) -> void:
	latest_update = {"version": version, "url": url}
	if menu != null:
		menu.show_update(version, url)


func _start_level(level_id: String = "") -> void:
	FlowLevelStart.start(self, level_id)


func _after_warmup() -> void:
	FlowLevelStart.after_warmup(self)


## Portal: a fase de origem fica viva (pausada e oculta); a secreta roda por cima e o retorno preserva tudo.
func _on_portal(portal_id: StringName, destination: StringName) -> void:
	FlowPortal.enter(self, portal_id, destination)


func _on_secret_completed(receipt: Dictionary) -> void:
	_show_results(receipt, _return_from_portal)


func _return_from_portal() -> void:
	FlowPortal.return_to_origin(self)


func _on_seed_destroyed(first_time: bool) -> void:
	FlowEnding.seed_destroyed(self, first_time)


func _play_ending() -> void:
	FlowEnding.play_ending(self)


func _show_credits(from_ending: bool) -> void:
	FlowEnding.show_credits(self, from_ending)


func _on_intro_finished() -> void:
	if level != null:
		if level.astralis != null:
			level.astralis.skip()
		if not level.controller.completed:
			level.rig.body.set_locked_state(-1)


func _on_completed(receipt: Dictionary) -> void:
	_show_results(receipt, _after_results)


func _show_results(receipt: Dictionary, on_continue: Callable) -> void:
	state = State.RESULTS
	last_save_error = service.save(profile)
	results = ResultsScreen.new()
	add_child(results)
	results.show_receipt(level.definition.display_name, receipt, profile["economy"]["coin_balance"], last_save_error == OK)
	results.continue_pressed.connect(on_continue)


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
	_ending_active = false
	_cleanup_level()
	_show_menu()


func is_paused() -> bool:
	return _pause_layer != null


func toggle_pause() -> void:
	FlowPause.toggle(self)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pause"):
		toggle_pause()
