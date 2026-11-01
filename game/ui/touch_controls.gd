class_name TouchControls
extends CanvasLayer
## Controles de toque na tela: cada botao aperta/solta UMA acao do InputMap, entao a logica de jogo nao muda. Multitoque: cada dedo
## segura o seu botao; deslizar de um botao para outro troca a acao. Mouse real tambem funciona (testar no PC); toques emulados como
## mouse sao ignorados para nao duplicar. Ao sair da arvore, solta tudo (nada fica "preso").

var scale_factor: float = 1.0
var opacity: float = 0.4
var mirror: bool = false

var _buttons: Dictionary = {}
var _fingers: Dictionary = {}


func configure(settings: Dictionary) -> void:
	scale_factor = TouchLayout.SIZE_SCALES[clampi(int(settings.get("touch_size", 1)), 0, TouchLayout.SIZE_SCALES.size() - 1)]
	opacity = TouchLayout.OPACITIES[clampi(int(settings.get("touch_opacity", 1)), 0, TouchLayout.OPACITIES.size() - 1)]
	mirror = settings.get("touch_mirror", false) == true


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	var rects: Dictionary = TouchLayout.rects(scale_factor, mirror)
	for e in TouchLayout.ENTRIES:
		var panel := Panel.new()
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var r: Rect2 = rects[e[0]]
		panel.position = r.position
		panel.size = r.size
		var label := Label.new()
		label.text = e[1]
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override(&"font_size", int(24.0 * scale_factor))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(label)
		add_child(panel)
		_buttons[e[0]] = panel
		_paint(e[0], false)


func is_held(action: StringName) -> bool:
	return action in _fingers.values()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_press(touch.index, touch.position)
		else:
			_release(touch.index)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _fingers.has(drag.index):
			_move(drag.index, drag.position)
	elif event is InputEventMouseButton and (event as InputEventMouseButton).device != InputEvent.DEVICE_ID_EMULATION:
		var click := event as InputEventMouseButton
		if click.button_index == MOUSE_BUTTON_LEFT:
			if click.pressed:
				_press(-1, click.position)
			else:
				_release(-1)
	elif event is InputEventMouseMotion and (event as InputEventMouseMotion).device != InputEvent.DEVICE_ID_EMULATION:
		if _fingers.has(-1):
			_move(-1, (event as InputEventMouseMotion).position)


func _action_at(pos: Vector2) -> StringName:
	for action in _buttons:
		if (_buttons[action] as Panel).get_global_rect().has_point(pos):
			return action
	return &""


func _press(finger: int, pos: Vector2) -> void:
	var action: StringName = _action_at(pos)
	if action == &"" or _fingers.has(finger):
		return
	_fingers[finger] = action
	_set_action(action, true)


func _move(finger: int, pos: Vector2) -> void:
	var now: StringName = _action_at(pos)
	var before: StringName = _fingers[finger]
	if now == before:
		return
	_fingers.erase(finger)
	_sync(before)
	if now != &"":
		_fingers[finger] = now
		_set_action(now, true)


func _release(finger: int) -> void:
	if not _fingers.has(finger):
		return
	var action: StringName = _fingers[finger]
	_fingers.erase(finger)
	_sync(action)


## Solta a acao so se nenhum outro dedo ainda a segura.
func _sync(action: StringName) -> void:
	if not is_held(action):
		_set_action(action, false)


func _set_action(action: StringName, pressed: bool) -> void:
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)
	_paint(action, pressed)


func _paint(action: StringName, pressed: bool) -> void:
	var panel: Panel = _buttons.get(action)
	if panel == null:
		return
	var box := StyleBoxFlat.new()
	box.bg_color = Color(1.0, 1.0, 1.0, minf(opacity * (1.7 if pressed else 1.0), 0.9))
	box.set_corner_radius_all(int(panel.size.y * 0.3))
	box.border_color = Color(1.0, 1.0, 1.0, 0.9)
	box.set_border_width_all(2)
	panel.add_theme_stylebox_override(&"panel", box)


func _exit_tree() -> void:
	for finger in _fingers.keys():
		Input.action_release(_fingers[finger])
	_fingers.clear()
