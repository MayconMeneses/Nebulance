class_name LevelController
extends Node
## Regras de UMA fase: coletas, checkpoint (snapshot), reaparecimento, bau e conclusao.
## Nao conhece outras fases nem o save em disco: recebe o Dictionary do perfil e devolve o recibo.

signal level_completed(receipt: Dictionary)
signal prompt_changed(text: String)
signal sfx_requested(sfx_name: StringName)

var definition: LevelDefinition
var session: LevelSession = LevelSession.new()
var rig: TrioRig
var save: Dictionary
var completed: bool = false
var start_position: Vector3 = Vector3.ZERO

var _ledger: RewardLedger = RewardLedger.new()
var _initial: Dictionary = {}
var _checkpoint_state: Dictionary = {}
var _prompt: String = ""
var _last_hearts: int = 0


func setup(p_rig: TrioRig, p_definition: LevelDefinition, p_save: Dictionary) -> void:
	rig = p_rig
	definition = p_definition
	save = p_save
	start_position = rig.body.global_position
	rig.checkpoint_reached.connect(_on_checkpoint)
	rig.vitals.life_lost.connect(_on_life_lost)
	rig.vitals.hearts_changed.connect(_on_hearts_changed)
	rig.level_restart_requested.connect(_on_restart)
	rig.hero_changed.connect(func(_p: HeroProfile) -> void: sfx_requested.emit(&"swap"))
	rig.body.state_changed.connect(_on_state_changed)
	_last_hearts = rig.vitals.hearts
	for enemy in get_tree().get_nodes_in_group(&"enemies"):
		enemy.set("target", rig.body)
	_initial = _capture_all()
	_checkpoint_state = _initial


func _physics_process(_delta: float) -> void:
	if completed or rig == null:
		return
	for node in rig.body.overlaps(PhysicsLayers.PICKUP):
		if node is Pickup and (node as Pickup).collect():
			_register_pickup(node as Pickup)
	var prompt: String = ""
	for node in rig.body.overlaps(PhysicsLayers.INTERACTABLE):
		if node is Chest and not (node as Chest).is_open:
			prompt = "Pressione E para abrir"
			if rig.body.current_intent.interact_pressed and (node as Chest).open():
				_complete()
				prompt = ""
	if prompt != _prompt:
		_prompt = prompt
		prompt_changed.emit(prompt)


func _register_pickup(pickup: Pickup) -> void:
	var id: String = String(pickup.pickup_id)
	match pickup.kind:
		Pickup.Kind.COIN: session.collect_coin(id)
		Pickup.Kind.ITEM: session.collect_item(id)
		Pickup.Kind.MEMORY: session.collect_memory(id)
	sfx_requested.emit(&"coin" if pickup.kind == Pickup.Kind.COIN else &"item")


func _complete() -> void:
	completed = true
	rig.body.set_locked_state(MovementState.State.CUTSCENE)
	sfx_requested.emit(&"chest")
	level_completed.emit(_ledger.commit_completion(save, definition, session))


func _on_checkpoint(_zone_id: StringName) -> void:
	session.take_snapshot()
	_checkpoint_state = _capture_all()
	sfx_requested.emit(&"checkpoint")


func _on_life_lost(_reason: StringName) -> void:
	session.lives_lost += 1
	session.restore_snapshot()
	_restore_all(_checkpoint_state)


## Zerar as vidas reinicia SOMENTE a fase (o perfil persistente nao e tocado).
func _on_restart() -> void:
	session = LevelSession.new()
	_restore_all(_initial)
	rig.last_checkpoint_id = &""
	rig.checkpoint_position = start_position
	rig.body.respawn(start_position)


func _on_hearts_changed(hearts: int) -> void:
	if hearts < _last_hearts:
		sfx_requested.emit(&"hurt")
	_last_hearts = hearts


func _on_state_changed(new_state: int) -> void:
	if new_state == MovementState.State.TAKEOFF:
		sfx_requested.emit(&"jump")


func _capture_all() -> Dictionary:
	var state: Dictionary = {}
	for node in get_tree().get_nodes_in_group(&"snapshotable"):
		state[String(node.get_path())] = node.call(&"capture")
	return state


func _restore_all(state: Dictionary) -> void:
	for node in get_tree().get_nodes_in_group(&"snapshotable"):
		var key: String = String(node.get_path())
		if state.has(key):
			node.call(&"restore", state[key])
