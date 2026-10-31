class_name GalaxyMap
extends CanvasLayer
## Mapa Galactico Vivo: 6 planetas nomeados, raizes de Caeldron e painel do planeta destacado.
## Navegavel por foco (teclado/gamepad). Sem spoilers: mostra contagens, nunca o conteudo dos segredos.

signal travel_requested(planet_id: StringName)
signal back_pressed

const CENTER: Vector2 = Vector2(400.0, 360.0)
const RADIUS: float = 250.0
const STATUS_TEXT: Array[String] = ["Bloqueado", "Disponivel", "Em perigo", "Salvo"]

var save: Dictionary = {}
var qa_mode: bool = false
var qa_progress: int = -1

var _planets: Array[PlanetDefinition] = []
var _buttons: Array[Button] = []
var _canvas: Control
var _info: Label
var _message: Label
var _travel: Button
var _selected: int = 0
var _time: float = 0.0


func show_state(real_save: Dictionary) -> void:
	save = real_save
	qa_progress = -1
	_refresh()


func select(index: int) -> void:
	_selected = index
	_refresh()


func _ready() -> void:
	_planets = GalaxyState.planets()
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.draw.connect(_draw_map)
	add_child(_canvas)
	var title := Label.new()
	title.text = "MAPA GALACTICO VIVO"
	title.position = Vector2(24.0, 16.0)
	title.add_theme_font_size_override(&"font_size", 30)
	add_child(title)
	for i in _planets.size():
		var b := Button.new()
		b.custom_minimum_size = Vector2(150.0, 44.0)
		b.position = _planet_pos(i) - Vector2(75.0, 22.0)
		b.pressed.connect(select.bind(i))
		b.focus_entered.connect(func() -> void:
			if _selected != i:
				select(i))
		add_child(b)
		_buttons.append(b)
	_info = Label.new()
	_info.position = Vector2(820.0, 90.0)
	_info.custom_minimum_size = Vector2(420.0, 0.0)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info.add_theme_font_size_override(&"font_size", 20)
	add_child(_info)
	_travel = Button.new()
	_travel.text = "Viajar"
	_travel.position = Vector2(820.0, 520.0)
	_travel.custom_minimum_size = Vector2(200.0, 44.0)
	_travel.pressed.connect(func() -> void: travel_requested.emit(_planets[_selected].planet_id))
	add_child(_travel)
	var back := Button.new()
	back.text = "Voltar"
	back.position = Vector2(1040.0, 520.0)
	back.custom_minimum_size = Vector2(160.0, 44.0)
	back.pressed.connect(func() -> void: back_pressed.emit())
	add_child(back)
	_message = Label.new()
	_message.position = Vector2(820.0, 580.0)
	_message.custom_minimum_size = Vector2(420.0, 0.0)
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_message)
	_refresh()
	_buttons[0].grab_focus()


func _process(delta: float) -> void:
	_time += delta
	if _canvas != null:
		_canvas.queue_redraw()


func _input(event: InputEvent) -> void:
	# Modo QA (so em build de desenvolvimento): F9 percorre os 7 estados de progresso, em memoria.
	if OS.has_feature("debug") and event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_F9:
		set_qa_progress((qa_progress + 1) % 7)


func set_qa_progress(seeds: int) -> void:
	qa_mode = true
	qa_progress = seeds
	_refresh()


func displayed_save() -> Dictionary:
	return GalaxyState.qa_save(qa_progress) if qa_progress >= 0 else save


func _planet_pos(i: int) -> Vector2:
	if i == _planets.size() - 1:
		return CENTER
	var angle: float = -PI / 2.0 + TAU * float(i) / float(_planets.size() - 1)
	return CENTER + Vector2(cos(angle), sin(angle)) * RADIUS


func _refresh() -> void:
	if _info == null or save.is_empty():
		return
	var shown: Dictionary = displayed_save()
	for i in _planets.size():
		var st: GalaxyState.Status = GalaxyState.status(shown, i)
		_buttons[i].text = "%s (%s)" % [_planets[i].display_name, STATUS_TEXT[st]]
	var p: PlanetDefinition = _planets[_selected]
	var status: GalaxyState.Status = GalaxyState.status(shown, _selected)
	var lines: PackedStringArray = [p.display_name + (" [MODO QA %d/6]" % qa_progress if qa_progress >= 0 else ""),
			"Estado: " + STATUS_TEXT[status], "", p.theme, "Mecanica: " + p.mechanic, "",
			"Fases: %d de %d concluidas + %d secreta" % [GalaxyState.levels_completed(shown, p), p.main_levels, p.secret_levels],
			"Guardiao: " + p.guardian_name, "Reliquia: ainda nao descoberta" if status != GalaxyState.Status.SAVED else "Reliquia: conquistada",
			"Segredos descobertos: %d" % GalaxyState.secrets_found(shown, p)]
	_info.text = "\n".join(lines)
	_travel.disabled = not GalaxyState.can_travel(shown, _selected) or qa_progress >= 0
	if status == GalaxyState.Status.LOCKED:
		_message.text = "Destrua a semente do planeta anterior para abrir esta rota."
	elif not p.playable:
		_message.text = "Planeta em producao: ainda nao ha fases jogaveis."
	elif qa_progress >= 0:
		_message.text = "Modo QA: somente visualizacao (o save real nao e alterado)."
	else:
		_message.text = ""
	_canvas.queue_redraw()


func _draw_map() -> void:
	if _planets.is_empty() or save.is_empty():
		return
	_canvas.draw_rect(Rect2(Vector2.ZERO, Vector2(1280.0, 720.0)), Color("070B1A"))
	var shown: Dictionary = displayed_save()
	var pulse: float = 0.55 if Accessibility.reduce_motion else 0.55 + 0.25 * sin(_time * 2.0)
	for i in _planets.size() - 1:
		if GalaxyState.root_visible(shown, i):
			_canvas.draw_line(CENTER, _planet_pos(i), Color(0.76, 0.24, 0.66, pulse), 5.0)
	for i in _planets.size():
		var st: GalaxyState.Status = GalaxyState.status(shown, i)
		var c: Color = _planets[i].tint
		c.a = [0.25, 0.9, 0.9, 1.0][st]
		_canvas.draw_circle(_planet_pos(i), 46.0 if i < 5 else 58.0, c)
		if i == _selected:
			_canvas.draw_arc(_planet_pos(i), 64.0, 0.0, TAU, 40, Color.WHITE, 3.0)
