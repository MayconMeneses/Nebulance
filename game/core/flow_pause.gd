class_name FlowPause
extends RefCounted
## Tela de pausa do fluxo (Esc/Start): alterna a pausa da arvore e monta o painel provisorio.


static func toggle(flow: GameFlow) -> void:
	if flow.state != GameFlow.State.LEVEL or flow._ending_active:
		return
	if flow._pause_layer != null:
		flow._pause_layer.queue_free()
		flow._pause_layer = null
		flow.get_tree().paused = false
		return
	flow.get_tree().paused = true
	flow._pause_layer = CanvasLayer.new()
	flow._pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	var box := VBoxContainer.new()
	box.position = Vector2(500.0, 240.0)
	flow._pause_layer.add_child(box)
	var title := Label.new()
	title.text = "PAUSADO"
	title.add_theme_font_size_override(&"font_size", 34)
	box.add_child(title)
	var resume := Button.new()
	resume.text = "Continuar"
	resume.pressed.connect(flow.toggle_pause)
	box.add_child(resume)
	var quit := Button.new()
	quit.text = "Voltar ao menu (o progresso da fase em curso nao e salvo)"
	quit.pressed.connect(flow._back_to_menu)
	box.add_child(quit)
	flow.add_child(flow._pause_layer)
	resume.grab_focus()
