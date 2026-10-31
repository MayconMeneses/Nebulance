extends Node
## Benchmark de jogo real: um bot joga a fase 01 inteira (HUD e audio ativos) e mede o tempo de quadro.
## Uso (build exportado):  nebulance.exe res://tests/scenes/bench.tscn
## Usa um save SEPARADO (user://saves/bench_slot.json); nunca toca o save do jogador.

var _times: PackedFloat32Array = PackedFloat32Array()
var _recording: bool = false
var _mode: String = ""


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
	flow.start_new_game(true)
	var bot := LevelBot.new(get_tree(), flow.level)
	_recording = true
	var finished: bool = await bot.play()
	_recording = false
	_report(finished, bot.stage)


## --profile=low|medium|high e --uncapped (vsync desligado, sem limite de FPS). Usa arquivo de config proprio do benchmark.
func _apply_cli(flow: GameFlow) -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--profile="):
			flow.settings.data["graphics_profile"] = arg.trim_prefix("--profile=")
		elif arg == "--uncapped":
			flow.settings.data["vsync"] = false
			flow.settings.data["max_fps"] = 0
	_mode = "%s%s" % [flow.settings.data["graphics_profile"], "_sem_vsync" if not flow.settings.data["vsync"] else "_vsync"]


func _process(delta: float) -> void:
	if _recording:
		_times.append(delta)


func _report(finished: bool, stage: String) -> void:
	var sorted: Array = Array(_times)
	sorted.sort()
	var total: float = 0.0
	for t in sorted:
		total += t
	var p99: float = sorted[int(sorted.size() * 0.99)]
	var line: String = "BENCH_LEVEL modo=%s completou=%s etapa=%s frames=%d avg_fps=%.1f p1_low_fps=%.1f worst_ms=%.1f gpu=%s renderer=%s" % [
			_mode, str(finished), stage, sorted.size(), sorted.size() / total, 1.0 / p99, sorted[-1] * 1000.0,
			RenderingServer.get_video_adapter_name(), RenderingServer.get_current_rendering_method()]
	print(line)
	var f := FileAccess.open("user://bench_level.txt", FileAccess.WRITE)
	f.store_line(line)
	f.close()
	get_tree().quit(0 if finished else 1)
