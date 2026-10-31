extends Node3D
## Cena de playtest do nucleo de controles (graybox). Teclado/gamepad via InputMap.
## Modo benchmark: executavel com  -- --bench  (entrada roteirizada; grava e imprime FPS).

const DATA: String = "res://game/actors/data/"
const BENCH_WARMUP: float = 2.0
const BENCH_SECONDS: float = 15.0

var rig: TrioRig
var _label: Label
var _visual: HeroVisual
var _bench: bool = false
var _bench_time: float = 0.0
var _frame_times: PackedFloat32Array = PackedFloat32Array()
var _script_input: ScriptedInput = ScriptedInput.new()


func _ready() -> void:
	_bench = "--bench" in OS.get_cmdline_user_args()
	_build_level()
	_build_rig()
	var cam := SideCamera.new()
	cam.target = rig.body
	cam.position = Vector3(0.0, 3.0, 12.0)
	add_child(cam)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50.0, -30.0, 0.0)
	add_child(sun)
	var layer := CanvasLayer.new()
	_label = Label.new()
	_label.position = Vector2(16.0, 12.0)
	layer.add_child(_label)
	add_child(layer)


func _process(delta: float) -> void:
	_label.text = "Heroi: %s   Vidas: %d   Coracoes: %d   Estado: %s\nA/D mover  Espaco pular  Shift habilidade  Q/R trocar  FPS: %d" % [
			rig.body.profile.display_name, rig.vitals.lives, rig.vitals.hearts,
			MovementState.State.keys()[rig.body.state], Engine.get_frames_per_second()]
	if _bench:
		_run_bench(delta)


func _build_rig() -> void:
	rig = TrioRig.new()
	var profiles: Array[HeroProfile] = []
	for id in ["rocco", "zuri", "pipa"]:
		profiles.append(load(DATA + id + ".tres") as HeroProfile)
	rig.profiles = profiles
	rig.difficulty = load(DATA + "difficulty_adventure.tres") as DifficultyProfile
	rig.use_input_reader = not _bench
	rig.position = Vector3(0.0, 1.0, 0.0)
	add_child(rig)
	_visual = HeroVisual.new()
	rig.body.add_child(_visual)
	_visual.bind(rig.body, rig)
	if _bench:
		rig.body.intent_provider = _script_input.read


func _build_level() -> void:
	_box(Vector3(2.0, -0.5, 0.0), Vector3(24.0, 1.0, 4.0))
	_box(Vector3(40.0, -0.5, 0.0), Vector3(44.0, 1.0, 4.0))
	_zone(PhysicsLayers.ABYSS, Vector3(16.0, -3.0, 0.0), Vector3(6.0, 2.0, 4.0), Color(0.6, 0.0, 0.0, 0.3))
	_zone(PhysicsLayers.CHECKPOINT, Vector3(8.0, 1.5, 0.0), Vector3(1.0, 3.0, 3.0), Color(0.2, 0.8, 1.0, 0.3))
	var barrier := ImpactBarrier.new()
	_add_shape(barrier, Vector3(1.5, 3.0, 3.0), Color(0.9, 0.5, 0.1))
	barrier.position = Vector3(24.0, 1.5, 0.0)
	add_child(barrier)
	_box(Vector3(31.0, 2.0, 0.0), Vector3(6.0, 1.0, 4.0))
	_box(Vector3(46.0, 3.5, 0.0), Vector3(8.0, 1.0, 4.0))
	_zone(PhysicsLayers.CLIMBABLE, Vector3(41.5, 2.25, 0.0), Vector3(1.2, 4.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	_zone(PhysicsLayers.HAZARD, Vector3(36.0, 0.5, 0.0), Vector3(2.0, 1.0, 3.0), Color(0.9, 0.1, 0.1, 0.5))
	_zone(PhysicsLayers.WIND, Vector3(54.0, 6.0, 0.0), Vector3(4.0, 12.0, 3.0), Color(0.7, 0.9, 1.0, 0.25), Vector3(0.0, 23.0, 0.0))


func _box(pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = PhysicsLayers.WORLD
	body.collision_mask = 0
	_add_shape(body, size, Color(0.35, 0.4, 0.5))
	body.position = pos
	add_child(body)


func _add_shape(parent: Node3D, size: Vector3, color: Color) -> void:
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	cs.shape = box
	parent.add_child(cs)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material = mat
	mi.mesh = mesh
	parent.add_child(mi)


func _zone(layer: int, pos: Vector3, size: Vector3, color: Color, wind: Vector3 = Vector3.ZERO) -> void:
	var zone := LevelZone.new()
	zone.zone_layer = layer
	zone.size = size
	zone.wind_push = wind
	zone.position = pos
	add_child(zone)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mat
	mi.mesh = mesh
	zone.add_child(mi)


func _run_bench(delta: float) -> void:
	_bench_time += delta
	_script_input.move_axis = 1.0
	if int(_bench_time * 60.0) % 90 == 0:
		_script_input.press_jump()
	if _bench_time > BENCH_WARMUP:
		_frame_times.append(delta)
	if _bench_time >= BENCH_WARMUP + BENCH_SECONDS:
		_report_bench()


func _report_bench() -> void:
	var sorted: Array = Array(_frame_times)
	sorted.sort()
	var total: float = 0.0
	for t in sorted:
		total += t
	var p99: float = sorted[int(sorted.size() * 0.99)]
	var line: String = "BENCH frames=%d avg_fps=%.1f p1_low_fps=%.1f worst_ms=%.1f gpu=%s renderer=%s" % [
			sorted.size(), sorted.size() / total, 1.0 / p99, sorted[-1] * 1000.0,
			RenderingServer.get_video_adapter_name(), RenderingServer.get_current_rendering_method()]
	print(line)
	var f := FileAccess.open("user://bench.txt", FileAccess.WRITE)
	f.store_line(line)
	f.close()
	get_tree().quit(0)
