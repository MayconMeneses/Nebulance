extends Node
## Benchmark de jogo real: um bot joga a fase 01 inteira (HUD e audio ativos) e mede o tempo de quadro.
## Uso (build exportado):  nebulance.exe -- --bench [--profile=low|medium|high] [--uncapped] [--passes=N]
## --passes=N joga a fase N vezes no MESMO processo e reporta cada passada separada: se os picos somem na 2a passada, e custo de PRIMEIRO USO
## (compilacao de shader no Compatibility); se continuam, e custo por evento (criar/liberar objetos, audio, fisica).
## Usa um save SEPARADO (user://saves/bench_slot.json); nunca toca o save do jogador.

var _times: PackedFloat32Array = PackedFloat32Array()
var _recording: bool = false
var _mode: String = ""
var _passes: int = 1
var _done_passes: int = 0
var _lines: Array = []
var _bot: LevelBot


func _ready() -> void:
	# Nos adicionados durante o primeiro _ready da cena principal ainda nao receberam _ready.
	await get_tree().process_frame
	var flow := GameFlow.new()
	flow.save_path = "user://saves/bench_slot.json"
	flow.settings_path = "user://bench_settings.json"
	flow.play_intro = false
	flow.dev_hooks = false
	flow.warmup_frames = 24
	add_child(flow)
	_apply_cli(flow)
	var all_finished: bool = true
	for pass_index in _passes:
		if pass_index > 0:
			await _reset_level(flow)
		flow.start_new_game(true)
		# So mede DEPOIS do aquecimento (o aquecimento fica atras da tela de carregamento).
		while flow.find_children("*", "ShaderWarmup", false, false).size() > 0:
			await get_tree().process_frame
		_bot = LevelBot.new(get_tree(), flow.level)
		_times = PackedFloat32Array()
		_recording = true
		var finished: bool = await _bot.play()
		_recording = false
		all_finished = all_finished and finished
		_summarize(pass_index + 1, finished, _bot.stage)
	_report(all_finished)


## Remove a fase e o HUD da passada anterior (o fluxo nao libera sozinho ao reiniciar).
func _reset_level(flow: GameFlow) -> void:
	if flow.level != null and is_instance_valid(flow.level):
		flow.level.queue_free()
	if flow.hud != null and is_instance_valid(flow.hud):
		flow.hud.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


## --profile=low|medium|high, --uncapped (vsync desligado, sem limite de FPS) e --passes=N. Usa arquivo de config proprio do benchmark.
func _apply_cli(flow: GameFlow) -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--profile="):
			flow.settings.data["graphics_profile"] = arg.trim_prefix("--profile=")
		elif arg == "--uncapped":
			flow.settings.data["vsync"] = false
			flow.settings.data["max_fps"] = 0
		elif arg.begins_with("--passes="):
			_passes = maxi(1, int(arg.trim_prefix("--passes=")))
	_mode = "%s%s" % [flow.settings.data["graphics_profile"], "_sem_vsync" if not flow.settings.data["vsync"] else "_vsync"]


func _process(delta: float) -> void:
	if _recording:
		_times.append(delta)
		if delta > 0.05:
			# Quadro anterior: scripts, fisica e o resto (render/driver) em ms, para separar custo de script do de GPU/driver.
			_lines.append("HITCH passada=%d quadro %d (%.1f s) %.0f ms [script %.0f fisica %.0f] etapa=%s" % [_done_passes + 1, _times.size(), _times_total(),
					delta * 1000.0, Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
					_bot.stage if _bot != null else "?"])


func _times_total() -> float:
	var t: float = 0.0
	for x in _times:
		t += x
	return t


func _summarize(pass_number: int, finished: bool, stage: String) -> void:
	_done_passes = pass_number
	var sorted: Array = Array(_times)
	sorted.sort()
	var total: float = 0.0
	for t in sorted:
		total += t
	var hitches: int = 0
	for t in sorted:
		hitches += 1 if t > 0.05 else 0
	var p99: float = sorted[int(sorted.size() * 0.99)]
	_lines.append("BENCH_LEVEL passada=%d modo=%s completou=%s etapa=%s frames=%d avg_fps=%.1f p1_low_fps=%.1f worst_ms=%.1f picos_acima_50ms=%d gpu=%s renderer=%s" % [
			pass_number, _mode, str(finished), stage, sorted.size(), sorted.size() / total, 1.0 / p99, sorted[-1] * 1000.0, hitches,
			RenderingServer.get_video_adapter_name(), RenderingServer.get_current_rendering_method()])


func _report(finished: bool) -> void:
	var f := FileAccess.open("user://bench_level.txt", FileAccess.WRITE)
	for line in _lines:
		print(line)
		f.store_line(line)
	f.close()
	get_tree().quit(0 if finished else 1)
