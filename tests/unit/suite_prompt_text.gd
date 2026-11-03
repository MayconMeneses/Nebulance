extends RefCounted
## Dica de interacao do HUD: tecla atual (inclusive remapeada) no teclado, botao INTERAGIR com os controles de toque, texto alheio intacto.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_localize(out)
	await _hud(tree, out)
	_all_prompts_start_with_prefix(out)
	return out


func _localize(out: Array) -> void:
	TestWorld.rec(out, "dica: teclado mostra a tecla atual de interagir no lugar do E fixo",
			PromptText.localize("Pressione E para abrir", "F", false) == "Pressione F para abrir")
	TestWorld.rec(out, "dica: teclado sem remapeamento fica igual ao texto original",
			PromptText.localize("Pressione E para abrir", "E", false) == "Pressione E para abrir")
	TestWorld.rec(out, "dica: toque troca por Toque em INTERAGIR (frase completa preservada)",
			PromptText.localize("Pressione E para levar a Comporta 2 ao nivel 3", "E", true) == "Toque em INTERAGIR para levar a Comporta 2 ao nivel 3")
	TestWorld.rec(out, "dica: formas 'Pressione E:' e 'Pressione E (..)' tambem sao convertidas",
			PromptText.localize("Pressione E: Golpe Triade", "E", true) == "Toque em INTERAGIR: Golpe Triade"
			and PromptText.localize("Pressione E (ative os dois)", "Q", false) == "Pressione Q (ative os dois)")
	TestWorld.rec(out, "dica: texto que nao comeca com o prefixo, vazio ou 'Pressione Enter' nao e alterado",
			PromptText.localize("", "F", true) == "" and PromptText.localize("Coletado", "F", true) == "Coletado"
			and PromptText.localize("Pressione Enter", "F", true) == "Pressione Enter")
	TestWorld.rec(out, "dica: troca de heroi cita as teclas no teclado e os botoes no toque",
			PromptText.swap_hint("Q", "R", false) == "Q/R troca" and PromptText.swap_hint("Q", "R", true).contains("HEROI"))


func _hud(tree: SceneTree, out: Array) -> void:
	var level := SylvaraLevel01.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	var hud := Hud.new()
	tree.get_root().add_child(hud)
	hud.touch = true
	hud.bind(level)
	await tree.process_frame
	level.controller.prompt_changed.emit("Pressione E para abrir")
	var label: Label = hud.find_children("*", "Label", true, false).filter(func(l: Node) -> bool: return (l as Label).text.begins_with("Toque")).front()
	TestWorld.rec(out, "dica: HUD com toque mostra 'Toque em INTERAGIR' quando a fase pede interacao", label != null and label.text == "Toque em INTERAGIR para abrir")
	hud.touch = false
	level.controller.prompt_changed.emit("Pressione E para abrir")
	TestWorld.rec(out, "dica: HUD sem toque volta a citar a tecla de interagir",
			hud.find_children("*", "Label", true, false).any(func(l: Node) -> bool:
				return (l as Label).text == "Pressione %s para abrir" % KeyBindings.key_name(&"interact")))
	hud.queue_free()
	level.queue_free()
	await tree.process_frame


## Contrato: todo texto de interacao do jogo comeca com "Pressione E" (e assim e convertido) -- um texto fora do padrao ficaria preso ao teclado.
func _all_prompts_start_with_prefix(out: Array) -> void:
	var bad: PackedStringArray = []
	var stack: Array[String] = ["res://game"]
	while not stack.is_empty():
		var dir: String = stack.pop_back()
		for sub in DirAccess.get_directories_at(dir):
			stack.append(dir + "/" + sub)
		for f in DirAccess.get_files_at(dir):
			if not f.ends_with(".gd"):
				continue
			for line in FileAccess.get_file_as_string(dir + "/" + f).split("\n"):
				var t: String = line.strip_edges()
				if t.contains("prompt_text = \"") and not t.contains("= \"Pressione E"):
					bad.append("%s/%s" % [dir, f])
	TestWorld.rec(out, "dica: todo prompt_text literal das fases segue o padrao 'Pressione E ...' (convertivel)", bad.is_empty(), "(%s)" % ", ".join(bad))
