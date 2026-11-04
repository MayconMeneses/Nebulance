extends RefCounted
## Qualidade automatica e medidor de FPS (TC-069): so desce um perfil quando o jogo fica lento por duas janelas seguidas; nunca sobe,
## respeita a opcao desligada e a troca de perfil do jogador; F3/medidor so le.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _adaptive(tree, out)
	await _overlay(tree, out)
	_settings(out)
	return out


func _feed(aq: AdaptiveQuality, frames: int, delta: float) -> void:
	for i in frames:
		aq.feed(delta, 60.0)


func _adaptive(tree: SceneTree, out: Array) -> void:
	var settings: Dictionary = SettingsStore.defaults()
	settings["graphics_profile"] = "high"
	var aq := AdaptiveQuality.new()
	aq.settings = settings
	tree.get_root().add_child(aq)
	var heard: Array[String] = []
	aq.stepped_down.connect(func(id: String) -> void: heard.append(id))
	_feed(aq, AdaptiveQuality.WINDOW_FRAMES * 4, 1.0 / 60.0)
	TestWorld.rec(out, "TC-069 qualidade automatica: a 60 FPS firmes nada muda", aq.steps == 0 and heard.is_empty() and aq.current == "high")
	_feed(aq, AdaptiveQuality.WINDOW_FRAMES, 1.0 / 30.0)
	TestWorld.rec(out, "TC-069 qualidade automatica: uma janela lenta so NAO basta (evita queda por um engasgo)", aq.steps == 0)
	_feed(aq, AdaptiveQuality.WINDOW_FRAMES, 1.0 / 30.0)
	TestWorld.rec(out, "TC-069 qualidade automatica: duas janelas lentas descem Alto -> Medio e o brilho some (perfil aplicado de verdade)",
			aq.steps == 1 and aq.current == "medium" and heard == ["medium"] and GraphicsProfile.glow_on == false)
	_feed(aq, AdaptiveQuality.WINDOW_FRAMES * 4, 1.0 / 30.0)
	_feed(aq, AdaptiveQuality.WINDOW_FRAMES * 4, 1.0 / 30.0)
	TestWorld.rec(out, "TC-069 qualidade automatica: continua ate o Baixo e para ali (nunca abaixo, nunca sobe sozinha)", aq.current == "low" and aq.steps == 2 and heard == ["medium", "low"])
	settings["graphics_profile"] = "medium"
	_feed(aq, 5, 1.0 / 60.0)
	TestWorld.rec(out, "TC-069 qualidade automatica: o jogador trocar o perfil recomeca a contagem e respeita a escolha", aq.current == "medium" and aq.steps == 0)
	settings["auto_quality"] = false
	_feed(aq, AdaptiveQuality.WINDOW_FRAMES * 6, 1.0 / 20.0)
	TestWorld.rec(out, "TC-069 qualidade automatica: com a opcao desligada nunca mexe no perfil", aq.current == "medium" and aq.steps == 0)
	var cap_ok: bool = AdaptiveQuality.target_fps() <= 60.0 and AdaptiveQuality.target_fps() > 0.0
	TestWorld.rec(out, "TC-069 qualidade automatica: a taxa alvo fica entre 0 e 60 (monitor de 144 Hz nao exige 144)", cap_ok)
	GraphicsApplier.apply(tree.get_root(), SettingsStore.defaults(), tree)
	aq.queue_free()
	await tree.process_frame


func _overlay(tree: SceneTree, out: Array) -> void:
	var overlay := FpsOverlay.new()
	tree.get_root().add_child(overlay)
	for i in 10:
		await tree.process_frame
	var hidden_first: bool = not overlay.is_shown()
	overlay.toggle()
	var shown: bool = overlay.is_shown()
	var stats: Dictionary = overlay.stats()
	overlay.toggle()
	TestWorld.rec(out, "TC-069 medidor de FPS: comeca escondido, F3 (toggle) mostra e esconde, e mede quadros reais (fps e pior quadro > 0)",
			hidden_first and shown and not overlay.is_shown() and stats["fps"] > 0.0 and stats["worst_ms"] >= stats["avg_ms"])
	overlay.queue_free()
	await tree.process_frame


func _settings(out: Array) -> void:
	var s := SettingsStore.new("user://nao_existe_auto.json")
	TestWorld.rec(out, "TC-069 qualidade automatica: ligada por padrao e a chave e saneada como booleana", s.data["auto_quality"] == true)
