extends RefCounted
## Compartimento selado da Astralis (TC-064): seis simbolos que acendem com as sementes destruidas; a mensagem final so abre com as seis;
## estado derivado do save (nada alterado) e visivel no Mapa Galactico.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_state(out)
	await _ui(tree, out)
	return out


func _state(out: Array) -> void:
	var counts: Array[int] = []
	for seeds in 7:
		counts.append(AstralisVault.lit_count(GalaxyState.qa_save(seeds)))
	TestWorld.rec(out, "TC-064 compartimento: 0 a 6 sementes acendem 0 a 6 simbolos", counts == [0, 1, 2, 3, 4, 5, 6])
	var three: Dictionary = GalaxyState.qa_save(3)
	var lit: Array[bool] = []
	for i in 6:
		lit.append(AstralisVault.symbol_lit(three, i))
	TestWorld.rec(out, "TC-064 compartimento: com 3 sementes acendem so os 3 primeiros simbolos (ordem dos planetas)",
			lit == [true, true, true, false, false, false] and AstralisVault.symbols_text(three) == "[*] [*] [*] [ ] [ ] [ ]")
	var open_flags: Array[bool] = []
	for seeds in 7:
		open_flags.append(AstralisVault.is_open(GalaxyState.qa_save(seeds)))
	TestWorld.rec(out, "TC-064 compartimento: a mensagem final so abre com as seis sementes (campanha concluida)",
			open_flags == [false, false, false, false, false, false, true])
	var sealed_text: String = AstralisVault.panel_text(GalaxyState.qa_save(5))
	TestWorld.rec(out, "TC-064 compartimento: selado, o painel nao revela o texto da mensagem; aberto, o painel mostra a mensagem",
			not AstralisVault.FINAL_MESSAGE in sealed_text and "selada" in sealed_text
			and AstralisVault.FINAL_MESSAGE in AstralisVault.panel_text(GalaxyState.qa_save(6)))
	var real: Dictionary = GalaxyState.qa_save(2)
	var before: String = JSON.stringify(real)
	AstralisVault.panel_text(real)
	AstralisVault.lit_count(real)
	TestWorld.rec(out, "TC-064 compartimento: ler o compartimento nao altera o save", JSON.stringify(real) == before)


func _ui(tree: SceneTree, out: Array) -> void:
	var map := GalaxyMap.new()
	tree.get_root().add_child(map)
	var save: Dictionary = SaveData.new_game()
	map.show_state(save)
	await tree.process_frame
	TestWorld.rec(out, "TC-064 compartimento: o mapa de um save novo mostra 0 de 6 simbolos e a mensagem selada",
			"0 de 6" in map._vault.text and "[ ] [ ] [ ] [ ] [ ] [ ]" in map._vault.text and "selada" in map._vault.text)
	map.set_qa_progress(4)
	TestWorld.rec(out, "TC-064 compartimento: o modo QA com 4 sementes acende 4 simbolos no mapa sem tocar o save real",
			"4 de 6" in map._vault.text and "[*] [*] [*] [*] [ ] [ ]" in map._vault.text and JSON.stringify(save) == JSON.stringify(SaveData.new_game()))
	map.set_qa_progress(6)
	TestWorld.rec(out, "TC-064 compartimento: com as seis sementes o mapa mostra a mensagem final aberta",
			"6 de 6" in map._vault.text and AstralisVault.FINAL_MESSAGE in map._vault.text)
	map.queue_free()
	await tree.process_frame
