class_name GameFlow
extends Node
## Fluxo do jogo: MainMenu -> Level (com introducao) -> Results -> MainMenu. Unico dono do perfil e do save.

enum State { MAIN_MENU, LEVEL, RESULTS }

@export var save_path: String = "user://saves/slot1.json"
@export var play_intro: bool = true

var state: State = State.MAIN_MENU
var profile: Dictionary = {}
var service: SaveService
var level: SylvaraLevel01
var menu: MainMenu
var hud: Hud
var results: ResultsScreen
var intro: ArrivalIntro
var audio: AudioDirector
var last_save_error: Error = OK

var _pause_layer: CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	service = SaveService.new(save_path)
	audio = AudioDirector.new()
	add_child(audio)
	_show_menu()


func start_new_game() -> void:
	if FileAccess.file_exists(service.path):
		service.archive_existing()
	profile = SaveData.new_game()
	last_save_error = service.save(profile)
	_start_level()


func continue_game() -> void:
	var loaded: Dictionary = service.load_save()
	if loaded["data"].is_empty():
		return
	profile = loaded["data"]
	_start_level()


func _show_menu() -> void:
	state = State.MAIN_MENU
	var loaded: Dictionary = service.load_save()
	var status: int = loaded["status"]
	menu = MainMenu.new()
	add_child(menu)
	menu.continue_pressed.connect(continue_game)
	menu.new_game_pressed.connect(start_new_game)
	menu.quit_pressed.connect(func() -> void: get_tree().quit())
	var has_data: bool = not loaded["data"].is_empty()
	menu.refresh(has_data, loaded["message"], status != SaveService.Status.FUTURE_VERSION)


func _start_level() -> void:
	if menu != null:
		menu.queue_free()
		menu = null
	state = State.LEVEL
	level = SylvaraLevel01.new()
	level.save = profile
	# O fluxo roda em ALWAYS (menu/pausa); a fase precisa ser pausavel explicitamente.
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(level)
	level.completed.connect(_on_completed)
	level.controller.sfx_requested.connect(audio.play_sfx)
	hud = Hud.new()
	add_child(hud)
	hud.bind(level)
	audio.play_music("res://assets/audio/music_sylvara.wav")
	if play_intro:
		level.rig.body.set_locked_state(MovementState.State.CUTSCENE)
		intro = ArrivalIntro.new()
		add_child(intro)
		intro.finished.connect(_on_intro_finished)


func _on_intro_finished() -> void:
	if level != null and not level.controller.completed:
		level.rig.body.set_locked_state(-1)


func _on_completed(receipt: Dictionary) -> void:
	state = State.RESULTS
	last_save_error = service.save(profile)
	results = ResultsScreen.new()
	add_child(results)
	results.show_receipt(level.definition.display_name, receipt, profile["economy"]["coin_balance"], last_save_error == OK)
	results.continue_pressed.connect(_back_to_menu)


func _back_to_menu() -> void:
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
