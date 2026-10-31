extends RefCounted
## Suite da Fase Zero (fundacao): InputMap, cena de teste, queda e salto do corpo provisorio.

const REQUIRED_ACTIONS: Array[StringName] = [
	&"move_left", &"move_right", &"jump", &"special",
	&"swap_prev", &"swap_next", &"interact", &"pause",
]
const TEST_SCENE: String = "res://tests/scenes/test_platform_scene.tscn"


func run(tree: SceneTree) -> Array:
	var out: Array = []
	for action in REQUIRED_ACTIONS:
		var has: bool = InputMap.has_action(action)
		var n: int = InputMap.action_get_events(action).size() if has else 0
		TestWorld.rec(out, "input_action:%s" % action, has and n >= 2, "(eventos=%d)" % n)
	TestWorld.rec(out, "input_action:move_left tem 3 eventos", InputMap.action_get_events(&"move_left").size() == 3)

	var packed: PackedScene = load(TEST_SCENE)
	TestWorld.rec(out, "scene_loads", packed != null)
	if packed == null:
		return out
	var root: Node = packed.instantiate()
	tree.get_root().add_child(root)
	var body: TestPlatformBody = root.get_node("Body") as TestPlatformBody
	TestWorld.rec(out, "body_is_character_body3d", body != null)
	if body == null:
		return out

	for i in 120:
		await tree.physics_frame
	TestWorld.rec(out, "lands_on_floor", body.is_on_floor(), "(y=%.3f)" % body.global_position.y)
	TestWorld.rec(out, "rests_on_top_of_floor", absf(body.global_position.y - 0.8) < 0.1)

	var ground_y: float = body.global_position.y
	body.request_jump()
	var peak: float = ground_y
	for i in 20:
		await tree.physics_frame
		peak = maxf(peak, body.global_position.y)
	TestWorld.rec(out, "jump_rises", peak - ground_y > 0.5, "(subiu %.2f)" % (peak - ground_y))
	for i in 120:
		await tree.physics_frame
	TestWorld.rec(out, "jump_returns_to_floor", body.is_on_floor())
	TestWorld.rec(out, "z_plane_locked", absf(body.global_position.z) < 0.001)
	root.queue_free()
	return out
