class_name TestWorld
extends RefCounted
## Monta um mundo de teste descartavel: piso, trio e entrada roteirizada.

const DATA: String = "res://game/actors/data/"

var tree: SceneTree
var root: Node3D
var rig: TrioRig
var body: ActorController
var input: ScriptedInput = ScriptedInput.new()


static func create(scene_tree: SceneTree, hero: int = 0, difficulty: String = "adventure",
		start: Vector3 = Vector3(0.0, 1.0, 0.0), floor_x0: float = -20.0, floor_x1: float = 20.0) -> TestWorld:
	var w := TestWorld.new()
	w.tree = scene_tree
	w.root = Node3D.new()
	scene_tree.get_root().add_child(w.root)
	w.add_box(Vector3((floor_x0 + floor_x1) * 0.5, -0.5, 0.0), Vector3(floor_x1 - floor_x0, 1.0, 4.0), PhysicsLayers.WORLD)
	w.rig = TrioRig.new()
	var profiles: Array[HeroProfile] = []
	for id in ["rocco", "zuri", "pipa"]:
		profiles.append(load(DATA + id + ".tres") as HeroProfile)
	w.rig.profiles = profiles
	w.rig.difficulty = load(DATA + "difficulty_%s.tres" % difficulty) as DifficultyProfile
	w.rig.use_input_reader = false
	w.rig.position = start
	w.root.add_child(w.rig)
	w.body = w.rig.body
	w.body.intent_provider = w.input.read
	if hero != 0:
		w.rig.request_swap(hero)
	return w


static func rec(out: Array, test_name: String, ok: bool, detail: String = "") -> void:
	out.append([test_name, ok, detail])


func step(frames: int) -> void:
	for i in frames:
		await tree.physics_frame


func feet_y() -> float:
	return body.global_position.y - (body.collision_shape.shape as CapsuleShape3D).height * 0.5


func add_box(pos: Vector3, size: Vector3, layer: int) -> StaticBody3D:
	var sb := StaticBody3D.new()
	sb.collision_layer = layer
	sb.collision_mask = 0
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	cs.shape = box
	sb.add_child(cs)
	sb.position = pos
	root.add_child(sb)
	return sb


func add_barrier(pos: Vector3, size: Vector3) -> ImpactBarrier:
	var barrier := ImpactBarrier.new()
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	cs.shape = box
	barrier.add_child(cs)
	barrier.position = pos
	root.add_child(barrier)
	return barrier


func add_zone(layer: int, pos: Vector3, size: Vector3, wind: Vector3 = Vector3.ZERO) -> LevelZone:
	var zone := LevelZone.new()
	zone.zone_layer = layer
	zone.size = size
	zone.wind_push = wind
	zone.position = pos
	root.add_child(zone)
	return zone


func dispose() -> void:
	root.queue_free()
