extends RefCounted
## NOTA: a entrega de eventos pelo motor (Viewport.push_input) nao funciona no modo headless (nem para mouse), entao esse caminho esta NOT_RUN
## aqui e precisa ser conferido num aparelho/janela real; os testes chamam _input diretamente.
## Controles de toque: disposicao, multitoque, deslize entre botoes, mouse real x emulado, jogo de verdade pela camada de toque, configuracoes.

const MOVE_RIGHT := &"move_right"


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_layout(out)
	await _input_paths(tree, out)
	await _gameplay(tree, out)
	await _settings_and_flow(tree, out)
	return out


func _layout(out: Array) -> void:
	var ok_inside: bool = true
	var ok_apart: bool = true
	for scale_factor in TouchLayout.SIZE_SCALES:
		for mirror in [false, true]:
			var rects: Dictionary = TouchLayout.rects(scale_factor, mirror)
			var all: Array = rects.values()
			for i in all.size():
				var r: Rect2 = all[i]
				ok_inside = ok_inside and Rect2(Vector2.ZERO, TouchLayout.VIEW).encloses(r)
				for j in range(i + 1, all.size()):
					ok_apart = ok_apart and not r.intersects(all[j])
	TestWorld.rec(out, "toque: todos os botoes ficam dentro da tela em todos os tamanhos e lados", ok_inside)
	TestWorld.rec(out, "toque: nenhum botao se sobrepoe a outro (cada dedo tem alvo proprio)", ok_apart)
	var covered: Array = []
	for e in TouchLayout.ENTRIES:
		covered.append(e[0])
	var needed: bool = true
	for a in KeyBindings.ACTIONS:
		needed = needed and a in covered
	TestWorld.rec(out, "toque: as 8 acoes do jogo (andar, pular, habilidade, interagir, trocar x2, pausa) tem botao", needed and covered.size() == KeyBindings.ACTIONS.size())
	var normal: Dictionary = TouchLayout.rects(1.0, false)
	var flipped: Dictionary = TouchLayout.rects(1.0, true)
	TestWorld.rec(out, "toque: padrao = andar a esquerda e pular a direita; modo canhoto inverte",
			normal[&"move_left"].position.x < 640.0 and normal[&"jump"].position.x > 640.0
			and flipped[&"move_left"].position.x > 640.0 and flipped[&"jump"].position.x < 640.0)
	var big: Dictionary = TouchLayout.rects(1.3, false)
	TestWorld.rec(out, "toque: tamanho Grande aumenta os botoes (alvo de toque >= 90 px mesmo no Pequeno)",
			big[&"jump"].size.x > normal[&"jump"].size.x and TouchLayout.rects(0.8, false)[&"jump"].size.x >= 90.0)
	var smallest: float = 9999.0
	for r in TouchLayout.rects(0.8, false).values():
		smallest = minf(smallest, minf(r.size.x, r.size.y))
	TestWorld.rec(out, "toque: o menor botao no menor tamanho ainda tem pelo menos 48 px (alvo minimo de toque)", smallest >= 48.0, "(%.0f px)" % smallest)
	TestWorld.rec(out, "toque: automatico so aparece em aparelho com tela de toque; sempre/nunca ignoram o aparelho",
			TouchLayout.should_show("auto", true) and not TouchLayout.should_show("auto", false) and TouchLayout.should_show("on", false)
			and not TouchLayout.should_show("off", true))


func _touch(index: int, pos: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.index = index
	e.position = pos
	e.pressed = pressed
	return e


func _drag(index: int, pos: Vector2) -> InputEventScreenDrag:
	var e := InputEventScreenDrag.new()
	e.index = index
	e.position = pos
	return e


func _center(controls: TouchControls, action: StringName) -> Vector2:
	return (controls._buttons[action] as Panel).get_global_rect().get_center()


func _make(tree: SceneTree) -> TouchControls:
	var controls := TouchControls.new()
	tree.get_root().add_child(controls)
	return controls


func _input_paths(tree: SceneTree, out: Array) -> void:
	var c: TouchControls = _make(tree)
	await tree.process_frame
	c._input(_touch(0, _center(c, &"jump"), true))
	TestWorld.rec(out, "toque: tocar em PULAR aperta a acao jump", Input.is_action_pressed(&"jump") and c.is_held(&"jump"))
	c._input(_touch(0, _center(c, &"jump"), false))
	TestWorld.rec(out, "toque: soltar o dedo solta a acao", not Input.is_action_pressed(&"jump"))
	c._input(_touch(0, _center(c, MOVE_RIGHT), true))
	c._input(_touch(1, _center(c, &"jump"), true))
	TestWorld.rec(out, "toque: multitoque - andar e pular ao mesmo tempo", Input.is_action_pressed(MOVE_RIGHT) and Input.is_action_pressed(&"jump"))
	c._input(_touch(0, _center(c, MOVE_RIGHT), false))
	TestWorld.rec(out, "toque: soltar um dedo nao solta o botao do outro", not Input.is_action_pressed(MOVE_RIGHT) and Input.is_action_pressed(&"jump"))
	c._input(_touch(1, _center(c, &"jump"), false))
	c._input(_touch(0, _center(c, &"move_left"), true))
	c._input(_drag(0, _center(c, MOVE_RIGHT)))
	TestWorld.rec(out, "toque: deslizar do botao esquerdo para o direito troca a acao sem soltar o dedo", not Input.is_action_pressed(&"move_left")
			and Input.is_action_pressed(MOVE_RIGHT))
	c._input(_drag(0, Vector2(640.0, 300.0)))
	TestWorld.rec(out, "toque: arrastar para fora de qualquer botao solta a acao", not Input.is_action_pressed(MOVE_RIGHT))
	c._input(_touch(0, Vector2(640.0, 300.0), true))
	TestWorld.rec(out, "toque: tocar fora dos botoes nao faz nada", not Input.is_action_pressed(&"jump") and not Input.is_action_pressed(MOVE_RIGHT))
	c._input(_touch(0, _center(c, &"special"), true))
	c._input(_touch(1, _center(c, &"special"), true))
	c._input(_touch(0, _center(c, &"special"), false))
	TestWorld.rec(out, "toque: dois dedos no mesmo botao - soltar um mantem a acao ate soltar o outro", Input.is_action_pressed(&"special"))
	c._input(_touch(1, _center(c, &"special"), false))
	TestWorld.rec(out, "toque: soltando o ultimo dedo a acao solta", not Input.is_action_pressed(&"special"))
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = _center(c, &"interact")
	click.pressed = true
	c._input(click)
	TestWorld.rec(out, "toque: mouse real tambem funciona (testar no PC)", Input.is_action_pressed(&"interact"))
	click.pressed = false
	c._input(click)
	var fake := InputEventMouseButton.new()
	fake.button_index = MOUSE_BUTTON_LEFT
	fake.device = InputEvent.DEVICE_ID_EMULATION
	fake.position = _center(c, &"interact")
	fake.pressed = true
	c._input(fake)
	TestWorld.rec(out, "toque: mouse emulado a partir do toque e ignorado (nao duplica o toque)", not Input.is_action_pressed(&"interact"))
	c._input(_touch(0, _center(c, &"pause"), true))
	c.queue_free()
	await tree.process_frame
	await tree.process_frame
	TestWorld.rec(out, "toque: fechar a camada com um dedo apertado solta tudo (nada fica preso)", not Input.is_action_pressed(&"pause"))


func _gameplay(tree: SceneTree, out: Array) -> void:
	var level := SylvaraLevel01.new()
	level.use_input_reader = true
	tree.get_root().add_child(level)
	var c := TouchControls.new()
	level.add_child(c)
	for i in 30:
		await tree.physics_frame
	var x0: float = level.rig.body.global_position.x
	c._input(_touch(0, _center(c, MOVE_RIGHT), true))
	for i in 60:
		await tree.physics_frame
	var x1: float = level.rig.body.global_position.x
	TestWorld.rec(out, "toque: segurar o botao de andar move o heroi de verdade (pelo InputReader)", x1 - x0 > 3.0, "(dx=%.2f)" % (x1 - x0))
	c._input(_touch(1, _center(c, &"jump"), true))
	var left_floor: bool = false
	for i in 20:
		await tree.physics_frame
		left_floor = left_floor or not level.rig.body.is_on_floor()
	TestWorld.rec(out, "toque: o botao PULAR faz o heroi saltar", left_floor)
	c._input(_touch(0, _center(c, MOVE_RIGHT), false))
	c._input(_touch(1, _center(c, &"jump"), false))
	level.queue_free()
	for i in 3:
		await tree.physics_frame


func _settings_and_flow(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("touch")
	var file := FileAccess.open(dir + "/s.json", FileAccess.WRITE)
	file.store_string('{"version":1,"touch_mode":"xyz","touch_size":9,"touch_opacity":"alta","touch_mirror":"sim"}')
	file.close()
	var s := SettingsStore.new(dir + "/s.json")
	s.load_settings()
	TestWorld.rec(out, "toque: configuracoes invalidas no arquivo voltam ao padrao (auto, medio, medio, destro)",
			s.data["touch_mode"] == "auto" and s.data["touch_size"] == 1 and s.data["touch_opacity"] == 1 and s.data["touch_mirror"] == false)
	s.data["touch_mode"] = "on"
	s.data["touch_size"] = 2
	s.data["touch_mirror"] = true
	s.save_settings()
	var s2 := SettingsStore.new(dir + "/s.json")
	s2.load_settings()
	TestWorld.rec(out, "toque: modo, tamanho e lado sobrevivem ao recarregar", s2.data["touch_mode"] == "on" and s2.data["touch_size"] == 2 and s2.data["touch_mirror"] == true)
	var c := TouchControls.new()
	c.configure(s2.data)
	tree.get_root().add_child(c)
	await tree.process_frame
	var jump_rect: Rect2 = (c._buttons[&"jump"] as Panel).get_global_rect()
	TestWorld.rec(out, "toque: configuracao Grande + canhoto vira botao maior no lado esquerdo", jump_rect.size.x > 200.0 and jump_rect.position.x < 640.0)
	c.queue_free()
	await tree.process_frame
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/s.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	TestWorld.rec(out, "toque: modo Sempre cria a camada de toque junto da fase", not flow.level.find_children("*", "TouchControls", false, false).is_empty())
	flow.settings.data["touch_mode"] = "off"
	flow.level.queue_free()
	flow.level = null
	flow._start_level("sylvara_01")
	await tree.process_frame
	TestWorld.rec(out, "toque: modo Nunca nao cria a camada", flow.level.find_children("*", "TouchControls", false, false).is_empty())
	tree.paused = false
	flow.queue_free()
	await tree.process_frame
	TmpDir.remove(TmpDir.ROOT)
