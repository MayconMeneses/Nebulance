class_name FlowMenus
extends RefCounted
## Telas do fluxo (Mapa Galactico, Configuracoes e menu principal). O GameFlow continua dono do estado: aqui so se monta e liga cada tela.


static func show_map(flow: GameFlow) -> void:
	if flow.menu != null:
		flow.menu.queue_free()
		flow.menu = null
	flow.state = GameFlow.State.MAP
	flow.map = GalaxyMap.new()
	flow.add_child(flow.map)
	flow.map.show_state(flow.profile)
	flow.map.travel_requested.connect(func(planet_id: StringName) -> void: flow._start_level(LevelCatalog.next_for(flow.profile, String(planet_id))))
	flow.map.back_pressed.connect(flow._back_to_menu)
	flow.map.credits_requested.connect(func() -> void: flow._show_credits(false))


static func show_settings(flow: GameFlow) -> void:
	if flow.menu != null:
		flow.menu.queue_free()
		flow.menu = null
	flow.settings_menu = SettingsMenu.new()
	flow.settings_menu.setup(flow.settings)
	flow.add_child(flow.settings_menu)
	flow.settings_menu.changed.connect(func(data: Dictionary) -> void: GraphicsApplier.apply(flow.get_viewport(), data, flow.get_tree()))
	flow.settings_menu.back_pressed.connect(func() -> void:
		flow.settings_menu.queue_free()
		flow.settings_menu = null
		flow._show_menu())


static func show_menu(flow: GameFlow) -> void:
	flow.state = GameFlow.State.MAIN_MENU
	var loaded: Dictionary = flow.service.load_save()
	var status: int = loaded["status"]
	flow.menu = MainMenu.new()
	flow.add_child(flow.menu)
	flow.menu.continue_pressed.connect(flow.continue_game)
	flow.menu.new_game_pressed.connect(flow.start_new_game)
	flow.menu.settings_pressed.connect(flow.show_settings)
	flow.menu.quit_pressed.connect(func() -> void: flow.get_tree().quit())
	var has_data: bool = not loaded["data"].is_empty()
	flow.menu.refresh(has_data, loaded["message"], status != SaveService.Status.FUTURE_VERSION)
	if not flow.latest_update.is_empty():
		flow.menu.show_update(flow.latest_update["version"], flow.latest_update["url"])
