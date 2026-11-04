class_name FuturisticTheme
extends RefCounted
## Tema da interface (menus, configuracoes, mapa, HUD): paineis de vidro escuro com borda e brilho ciano, botoes com foco bem visivel.
## Contraste do texto sobre o fundo >= 7:1 (conferido em teste). Aplicado ao Window raiz pelo autoload UiTheme. So aparencia.

const ACCENT: Color = Color("23CFF5")
const PANEL_BG: Color = Color(0.03, 0.06, 0.14, 0.82)
const TEXT: Color = Color("EAF7FF")
const TEXT_DISABLED: Color = Color("8FA3B3")


static func build() -> Theme:
	var theme := Theme.new()
	for type_name in ["Label", "Button", "CheckBox", "OptionButton", "CheckButton"]:
		theme.set_color(&"font_color", type_name, TEXT)
	theme.set_color(&"font_color_hover", "Button", Color.WHITE)
	theme.set_color(&"font_color_focus", "Button", Color.WHITE)
	theme.set_color(&"font_disabled_color", "Button", TEXT_DISABLED)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		theme.set_stylebox(state, "Button", _button_box(state))
	theme.set_stylebox(&"panel", "PanelContainer", _panel_box(0.7))
	theme.set_type_variation(&"HudPanel", &"PanelContainer")
	theme.set_stylebox(&"panel", "HudPanel", _panel_box(0.55))
	return theme


static func _panel_box(alpha: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(PANEL_BG.r, PANEL_BG.g, PANEL_BG.b, alpha)
	box.border_color = Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.7)
	box.border_width_left = 3
	box.border_width_bottom = 1
	box.set_corner_radius_all(8)
	box.set_content_margin_all(10)
	box.shadow_color = Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.18)
	box.shadow_size = 6
	return box


static func _button_box(state: String) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	# O fundo fica sempre escuro (contraste do texto >= 7:1); o ESTADO aparece na borda, no brilho e na espessura.
	var bright: float = {"normal": 0.0, "hover": 0.0, "pressed": -0.02, "focus": 0.0, "disabled": -0.02}[state]
	box.bg_color = Color(0.04 + bright * 0.5, 0.09 + bright, 0.18 + bright * 1.5, 0.85)
	var edge: float = 0.35 if state == "normal" else (0.0 if state == "disabled" else 1.0)
	box.border_color = Color(ACCENT.r, ACCENT.g, ACCENT.b, maxf(edge, 0.15))
	box.set_border_width_all(3 if state == "focus" else 1)
	box.set_corner_radius_all(6)
	box.content_margin_left = 14.0
	box.content_margin_right = 14.0
	box.content_margin_top = 6.0
	box.content_margin_bottom = 6.0
	if state == "focus" or state == "hover":
		box.shadow_color = Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.4)
		box.shadow_size = 8
	return box
