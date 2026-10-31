class_name Hud
extends CanvasLayer
## HUD: vidas (patinhas) e coracoes separados, heroi ativo, moedas, meta e dica contextual.

var _level: LevelScene
var _lives_box: HBoxContainer
var _hearts_box: HBoxContainer
var _hero_label: Label
var _coins_label: Label
var _goal_label: Label
var _prompt_label: Label


func bind(level: LevelScene) -> void:
	_level = level
	level.controller.prompt_changed.connect(func(text: String) -> void: _prompt_label.text = text)


func _ready() -> void:
	var top := VBoxContainer.new()
	top.position = Vector2(16.0, 10.0)
	add_child(top)
	_hero_label = _label(top)
	_lives_box = _icon_row(top, "Vidas")
	_hearts_box = _icon_row(top, "Coracoes")
	_coins_label = _label(top)
	_goal_label = _label(top)
	_prompt_label = Label.new()
	_prompt_label.position = Vector2(480.0, 600.0)
	_prompt_label.add_theme_font_size_override(&"font_size", 28)
	add_child(_prompt_label)


func _process(_delta: float) -> void:
	if _level == null or _level.rig == null:
		return
	var rig: TrioRig = _level.rig
	_hero_label.text = "Heroi: %s   (%s/%s troca)" % [rig.body.profile.display_name, KeyBindings.key_name(&"swap_prev"), KeyBindings.key_name(&"swap_next")]
	_fill(_lives_box, rig.vitals.lives, rig.difficulty.lives_per_level, Color("F08A3B"))
	_fill(_hearts_box, rig.vitals.hearts, rig.difficulty.hearts_per_attempt, Color("DE5145"))
	_coins_label.text = "Moedas: %d / %d" % [_level.controller.session.coin_ids.size(), _level.definition.coin_ids.size()]
	_goal_label.text = "Meta: " + _level.definition.goal_text


func _label(parent: Control) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override(&"font_size", 20)
	parent.add_child(l)
	return l


func _icon_row(parent: Control, title: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	var t := Label.new()
	t.text = title + ":"
	t.custom_minimum_size = Vector2(90.0, 0.0)
	row.add_child(t)
	parent.add_child(row)
	return row


## Icones: cheios na cor do tipo; vazios em cinza. Forma diferente por tipo (acessibilidade): vida = quadrado, coracao = losango.
func _fill(row: HBoxContainer, current: int, maximum: int, color: Color) -> void:
	while row.get_child_count() - 1 < maximum:
		var icon := ColorRect.new()
		icon.custom_minimum_size = Vector2(18.0, 18.0)
		if row == _hearts_box:
			icon.rotation = PI / 4.0
			icon.pivot_offset = Vector2(9.0, 9.0)
		row.add_child(icon)
	for i in maximum:
		(row.get_child(i + 1) as ColorRect).color = color if i < current else Color(0.25, 0.25, 0.3)
