extends RefCounted
## Tema futurista da interface (TC-072): paineis de vidro e botoes com borda/brilho, contraste do texto >= 7:1, aplicado a todas as telas
## pelo autoload e usado pelo painel do HUD.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _theme(tree, out)
	return out


func _contrast(a: Color, b: Color) -> float:
	var la: float = a.get_luminance()
	var lb: float = b.get_luminance()
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


func _theme(tree: SceneTree, out: Array) -> void:
	var theme: Theme = FuturisticTheme.build()
	var normal := theme.get_stylebox(&"normal", &"Button") as StyleBoxFlat
	var focus := theme.get_stylebox(&"focus", &"Button") as StyleBoxFlat
	TestWorld.rec(out, "TC-072 tema: botoes com borda e cantos arredondados, e o foco e mais forte (borda grossa e brilho) para teclado/controle",
			normal != null and focus != null and normal.border_width_left == 1 and focus.border_width_left == 3 and focus.shadow_size > 0 and normal.corner_radius_top_left > 0)
	var worst: float = 99.0
	for bg in [FuturisticTheme.PANEL_BG, normal.bg_color, focus.bg_color, (theme.get_stylebox(&"pressed", &"Button") as StyleBoxFlat).bg_color]:
		var opaque := Color(bg.r, bg.g, bg.b, 1.0)
		worst = minf(worst, _contrast(FuturisticTheme.TEXT, opaque))
	TestWorld.rec(out, "TC-072 tema: o texto claro sobre qualquer fundo de painel/botao tem contraste >= 7:1 (acessibilidade)", worst >= 7.0, "(pior contraste=%.1f)" % worst)
	TestWorld.rec(out, "TC-072 tema: o painel do HUD existe como variacao (HudPanel) e o autoload aplicou o tema ao Window raiz",
			theme.get_type_variation_base(&"HudPanel") == &"PanelContainer" and tree.get_root().theme != null
			and tree.get_root().theme.get_stylebox(&"normal", &"Button") is StyleBoxFlat)
	var hud := Hud.new()
	tree.get_root().add_child(hud)
	await tree.process_frame
	var panels: Array = hud.find_children("*", "PanelContainer", true, false)
	TestWorld.rec(out, "TC-072 tema: o HUD mostra suas informacoes dentro do painel de vidro", panels.size() == 1 and (panels[0] as PanelContainer).theme_type_variation == &"HudPanel")
	hud.queue_free()
	await tree.process_frame
