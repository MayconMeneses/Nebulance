class_name FlowLevelStart
extends RefCounted
## Abertura de uma fase pelo fluxo: instancia, liga sinais, HUD, controles de toque, aquecimento de shaders e introducao.


static func start(flow: GameFlow, level_id: String) -> void:
	if flow.menu != null:
		flow.menu.queue_free()
		flow.menu = null
	if flow.map != null:
		flow.map.queue_free()
		flow.map = null
	flow.state = GameFlow.State.LEVEL
	var id: String = level_id if level_id != "" else LevelCatalog.next_for(flow.profile, "sylvara")
	flow.level = LevelCatalog.make(id)
	flow.level.save = flow.profile
	# O fluxo roda em ALWAYS (menu/pausa); a fase precisa ser pausavel explicitamente.
	flow.level.process_mode = Node.PROCESS_MODE_PAUSABLE
	flow.add_child(flow.level)
	GraphicsApplier.apply(flow.get_viewport(), flow.settings.data, flow.get_tree())
	flow.level.completed.connect(flow._on_completed)
	flow.level.controller.sfx_requested.connect(flow.audio.play_sfx)
	flow.level.controller.portal_requested.connect(flow._on_portal)
	if flow.level.has_signal("seed_destroyed"):
		flow.level.connect("seed_destroyed", flow._on_seed_destroyed)
	flow.hud = Hud.new()
	flow.add_child(flow.hud)
	var show_touch: bool = TouchLayout.should_show(flow.settings.data["touch_mode"], DisplayServer.is_touchscreen_available())
	flow.hud.touch = show_touch
	flow.hud.bind(flow.level)
	if show_touch:
		var touch := TouchControls.new()
		touch.configure(flow.settings.data)
		flow.level.add_child(touch)
		touch.process_mode = Node.PROCESS_MODE_ALWAYS
	flow.audio.play_music(AudioDirector.music_for(flow.level.definition.planet_id))
	if flow.warmup_frames > 0:
		flow.level.rig.body.set_locked_state(MovementState.State.CUTSCENE)
		var warm := ShaderWarmup.new()
		flow.add_child(warm)
		warm.finished.connect(flow._after_warmup)
		warm.run(flow.level, flow.warmup_frames)
	else:
		after_warmup(flow)


static func after_warmup(flow: GameFlow) -> void:
	if flow.level == null or not is_instance_valid(flow.level):
		return
	if flow.warmup_frames > 0 and not flow.play_intro:
		flow.level.rig.body.set_locked_state(-1)
	if flow.play_intro:
		flow.level.rig.body.set_locked_state(MovementState.State.CUTSCENE)
		if flow.level.astralis != null:
			flow.level.astralis.arrive(ArrivalIntro.DURATION - 0.5)
		flow.intro = ArrivalIntro.new()
		flow.add_child(flow.intro)
		flow.intro.finished.connect(flow._on_intro_finished)
