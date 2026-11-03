class_name FlowPortal
extends RefCounted
## Portal: a fase de origem fica viva (pausada e oculta); a secreta roda por cima e o retorno preserva tudo.


static func enter(flow: GameFlow, portal_id: StringName, destination: StringName) -> void:
	if flow.origin_level != null or not LevelCatalog.has(String(destination)):
		return
	if not String(portal_id) in flow.profile["world"]["portal_ids"]:
		flow.profile["world"]["portal_ids"].append(String(portal_id))
	flow.origin_level = flow.level
	flow.origin_level.process_mode = Node.PROCESS_MODE_DISABLED
	flow.origin_level.visible = false
	flow.level = LevelCatalog.make(String(destination))
	flow.level.save = flow.profile
	flow.level.process_mode = Node.PROCESS_MODE_PAUSABLE
	flow.add_child(flow.level)
	flow.level.camera.make_current()
	flow.level.completed.connect(flow._on_secret_completed)
	flow.level.controller.sfx_requested.connect(flow.audio.play_sfx)
	flow.hud.bind(flow.level)
	GraphicsApplier.apply(flow.get_viewport(), flow.settings.data, flow.get_tree())


static func return_to_origin(flow: GameFlow) -> void:
	if flow.results != null:
		flow.results.queue_free()
		flow.results = null
	flow.level.queue_free()
	flow.level = flow.origin_level
	flow.origin_level = null
	flow.level.visible = true
	flow.level.process_mode = Node.PROCESS_MODE_PAUSABLE
	flow.level.camera.make_current()
	flow.hud.bind(flow.level)
	flow.state = GameFlow.State.LEVEL
