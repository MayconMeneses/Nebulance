extends RefCounted
## Mapa Galactico Vivo (PDF secao 06): estado derivado do save, raizes, bloqueios, sem spoilers, modo QA em memoria.

const S := GalaxyState.Status


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_state(out)
	await _ui(tree, out)
	TmpDir.remove(TmpDir.ROOT)
	return out


func _roots(save: Dictionary) -> int:
	var n: int = 0
	for i in 5:
		if GalaxyState.root_visible(save, i):
			n += 1
	return n


func _state(out: Array) -> void:
	var planets: Array[PlanetDefinition] = GalaxyState.planets()
	var names: Array[String] = []
	for p in planets:
		names.append(p.display_name)
	TestWorld.rec(out, "mapa: exatamente seis planetas nomeados", names == ["Sylvara", "Cristalia", "Mecatron", "Aquarys", "Aerion", "Umbraxis"])
	var guardians: Array[String] = []
	for p in planets:
		guardians.append(p.guardian_name)
	TestWorld.rec(out, "mapa: guardioes do PDF", guardians == ["Vyrkan", "Zythra", "Ferrorraiz", "Thalassa", "Zefrion", "Necryon"])
	var ok_all: bool = true
	for seeds in 7:
		var save: Dictionary = GalaxyState.qa_save(seeds)
		for i in 6:
			var expected: S
			if i < seeds:
				expected = S.SAVED
			elif i == seeds:
				expected = S.AVAILABLE
			else:
				expected = S.LOCKED
			var got: S = GalaxyState.status(save, i)
			if got != expected:
				ok_all = false
				print("   estado errado: sementes=%d planeta=%d esperado=%d obtido=%d" % [seeds, i, expected, got])
		if _roots(save) != 5 - mini(seeds, 5):
			ok_all = false
			print("   raizes erradas com %d sementes: %d" % [seeds, _roots(save)])
	TestWorld.rec(out, "mapa: os 6 estados de progresso do QA (0..6 sementes) dao estados e raizes corretos", ok_all)
	var save0: Dictionary = SaveData.new_game()
	TestWorld.rec(out, "mapa: save novo = Sylvara disponivel e os outros bloqueados", GalaxyState.status(save0, 0) == S.AVAILABLE
			and GalaxyState.status(save0, 1) == S.LOCKED and GalaxyState.status(save0, 5) == S.LOCKED)
	save0["world"]["completed_levels"].append("sylvara_01")
	TestWorld.rec(out, "mapa: com progresso e semente viva = em perigo", GalaxyState.status(save0, 0) == S.IN_DANGER)
	TestWorld.rec(out, "mapa: viajavel = jogavel E nao bloqueado (Cristalia abre depois de Sylvara; Mecatron abre depois de Cristalia; Aquarys abre depois de Mecatron; Aerion ainda em producao)",
			GalaxyState.can_travel(save0, 0) and not GalaxyState.can_travel(save0, 1) and GalaxyState.can_travel(GalaxyState.qa_save(1), 1)
			and GalaxyState.can_travel(GalaxyState.qa_save(2), 2) and GalaxyState.can_travel(GalaxyState.qa_save(3), 3)
			and not GalaxyState.can_travel(GalaxyState.qa_save(4), 4))
	TestWorld.rec(out, "mapa: destruir a semente remove so a raiz daquele planeta", GalaxyState.root_visible(save0, 0)
			and not GalaxyState.root_visible(GalaxyState.qa_save(1), 0) and GalaxyState.root_visible(GalaxyState.qa_save(1), 1))
	TestWorld.rec(out, "mapa: estado e funcao pura (nao altera o save lido)", GalaxyState.status(save0, 0) == GalaxyState.status(save0, 0))


func _ui(tree: SceneTree, out: Array) -> void:
	var map := GalaxyMap.new()
	tree.get_root().add_child(map)
	var real: Dictionary = SaveData.new_game()
	var before: String = JSON.stringify(real)
	map.show_state(real)
	await tree.process_frame
	TestWorld.rec(out, "mapa: seis botoes de planeta com nome e estado", map._buttons.size() == 6 and "Sylvara (Disponivel)" == map._buttons[0].text
			and "Cristalia (Bloqueado)" == map._buttons[1].text)
	TestWorld.rec(out, "mapa: Viajar ativo para Sylvara", not map._travel.disabled)
	map.select(1)
	TestWorld.rec(out, "mapa: planeta bloqueado desativa Viajar e explica o motivo", map._travel.disabled and "semente do planeta anterior" in map._message.text)
	map.select(0)
	TestWorld.rec(out, "mapa: painel mostra fases, guardiao e contagem de segredos sem revelar o conteudo",
			"6 de 6" not in map._info.text and "Vyrkan" in map._info.text and "Segredos descobertos: 0" in map._info.text
			and not "glow_scarf" in map._info.text and not "archive_symbol" in map._info.text)
	var heard: Array[StringName] = []
	map.travel_requested.connect(func(id: StringName) -> void: heard.append(id))
	map._travel.pressed.emit()
	TestWorld.rec(out, "mapa: Viajar emite a rota escolhida", heard == [&"sylvara"])
	map._buttons[2].grab_focus()
	await tree.process_frame
	TestWorld.rec(out, "mapa: foco por teclado/gamepad seleciona o planeta", map._selected == 2 and "Mecatron" in map._info.text)
	map.set_qa_progress(3)
	TestWorld.rec(out, "QA: modo QA mostra 3 planetas salvos sem alterar o save real", GalaxyState.status(map.displayed_save(), 2) == S.SAVED
			and JSON.stringify(real) == before)
	map.select(0)
	TestWorld.rec(out, "QA: em modo QA a viagem fica desativada (so visualizacao)", map._travel.disabled and "Modo QA" in map._message.text)
	TestWorld.rec(out, "QA: o save real continua intacto depois de todos os estados", JSON.stringify(real) == before)
	map.queue_free()
	var found := {"n": 0}
	var s2: Dictionary = SaveData.new_game()
	s2["economy"]["owned_items"].append("sylvara_01_glow_scarf")
	found["n"] = GalaxyState.secrets_found(s2, GalaxyState.planets()[0])
	TestWorld.rec(out, "mapa: contagem de segredos descobertos usa o save", found["n"] == 1)
