extends SceneTree
## Runner headless minimo da Fase Zero (sem plugin).
## Uso: godot --headless --path . --script res://tests/run_tests.gd
## Saida: uma linha PASS/FAIL por teste; codigo de saida 0 somente se tudo passar.

const REQUIRED_ACTIONS: Array[StringName] = [
	&"move_left", &"move_right", &"jump", &"special",
	&"swap_prev", &"swap_next", &"interact", &"pause",
]
const TEST_SCENE: String = "res://tests/scenes/test_platform_scene.tscn"

var _failures: int = 0


func _initialize() -> void:
	await _run()
	print("RESULT: %s (%d falha(s))" % ["PASS" if _failures == 0 else "FAIL", _failures])
	quit(0 if _failures == 0 else 1)


func _check(name: String, ok: bool, detail: String = "") -> void:
	if not ok:
		_failures += 1
	print("%s  %s %s" % ["PASS" if ok else "FAIL", name, detail])


func _run() -> void:
	# T1: acoes do InputMap existem e tem eventos (teclado e gamepad, sem tecla fisica no codigo).
	for action in REQUIRED_ACTIONS:
		var has: bool = InputMap.has_action(action)
		var n: int = InputMap.action_get_events(action).size() if has else 0
		_check("input_action:%s" % action, has and n >= 2, "(eventos=%d)" % n)

	# T2: movimento horizontal tem teclado E analogico.
	_check("input_action:move_left tem 3 eventos", InputMap.action_get_events(&"move_left").size() == 3)

	# T3: cena de teste carrega.
	var packed: PackedScene = load(TEST_SCENE)
	_check("scene_loads", packed != null)
	if packed == null:
		return
	var root: Node = packed.instantiate()
	get_root().add_child(root)
	var body: TestPlatformBody = root.get_node("Body") as TestPlatformBody
	_check("body_is_character_body3d", body != null)
	if body == null:
		return

	# T4: cai e pousa no piso.
	for i in 120:
		await physics_frame
	_check("lands_on_floor", body.is_on_floor(), "(y=%.3f)" % body.global_position.y)
	_check("rests_on_top_of_floor", absf(body.global_position.y - 0.8) < 0.1)

	# T5: salto sai do piso e retorna.
	var ground_y: float = body.global_position.y
	body.request_jump()
	var peak: float = ground_y
	for i in 20:
		await physics_frame
		peak = maxf(peak, body.global_position.y)
	_check("jump_rises", peak - ground_y > 0.5, "(subiu %.2f)" % (peak - ground_y))
	for i in 120:
		await physics_frame
	_check("jump_returns_to_floor", body.is_on_floor())

	# T6: plano lateral preservado (z travado).
	_check("z_plane_locked", absf(body.global_position.z) < 0.001)

	root.queue_free()
