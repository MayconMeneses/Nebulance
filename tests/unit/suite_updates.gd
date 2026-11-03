extends RefCounted
## Aviso de atualizacao: comparacao de versoes, resposta da API, faixa no menu, opcao desligavel e nenhuma rede nos testes.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_versions(out)
	_parse(out)
	_network_inventory(out)
	await _menu_and_flow(tree, out)
	return out


func _versions(out: Array) -> void:
	TestWorld.rec(out, "atualizacao: versao maior e mais nova (0.10.0 > 0.9.0, comparacao numerica e nao de texto)",
			UpdateChecker.is_newer("0.10.0", "0.9.0") and UpdateChecker.is_newer("1.0.0", "0.99.9") and UpdateChecker.is_newer("0.4.1", "0.4.0"))
	TestWorld.rec(out, "atualizacao: igual, menor ou invalida NAO e mais nova",
			not UpdateChecker.is_newer("0.4.0", "0.4.0") and not UpdateChecker.is_newer("0.3.9", "0.4.0") and not UpdateChecker.is_newer("lixo", "0.4.0")
			and not UpdateChecker.is_newer("0.5.0", "x") and not UpdateChecker.is_newer("", "0.4.0"))
	TestWorld.rec(out, "atualizacao: 0.5 e 0.5.0 sao equivalentes", not UpdateChecker.is_newer("0.5", "0.5.0") and not UpdateChecker.is_newer("0.5.0", "0.5"))
	var iss: String = FileAccess.get_file_as_string("res://installer/nebulance.iss")
	TestWorld.rec(out, "atualizacao: a versao do jogo coincide com a do instalador (installer/nebulance.iss)",
			iss.contains('#define AppVersion "%s"' % GameVersion.CURRENT))


func _parse(out: Array) -> void:
	var good: Dictionary = UpdateChecker.parse_release({"tag_name": "v0.5.0", "html_url": "https://github.com/MayconMeneses/Nebulance/releases/tag/v0.5.0"})
	TestWorld.rec(out, "atualizacao: resposta valida vira versao + link", good.get("version") == "0.5.0" and good.get("url", "").begins_with(UpdateChecker.TRUSTED_PREFIX))
	TestWorld.rec(out, "atualizacao: link de outro site e recusado (nunca abrimos o que a rede mandar)",
			UpdateChecker.parse_release({"tag_name": "v9.0.0", "html_url": "https://exemplo.com/baixe-aqui"}).is_empty())
	TestWorld.rec(out, "atualizacao: rascunho, pre-lancamento, tag invalida e corpo nao-dicionario sao ignorados",
			UpdateChecker.parse_release({"tag_name": "v1.0.0", "html_url": UpdateChecker.TRUSTED_PREFIX + "x", "draft": true}).is_empty()
			and UpdateChecker.parse_release({"tag_name": "v1.0.0", "html_url": UpdateChecker.TRUSTED_PREFIX + "x", "prerelease": true}).is_empty()
			and UpdateChecker.parse_release({"tag_name": "nova", "html_url": UpdateChecker.TRUSTED_PREFIX + "x"}).is_empty()
			and UpdateChecker.parse_release("texto").is_empty() and UpdateChecker.parse_release(null).is_empty())
	TestWorld.rec(out, "atualizacao: so a opcao check_updates=true (padrao) liga a verificacao", SettingsStore.defaults()["check_updates"] == true)


func _menu_and_flow(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("upd")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	TestWorld.rec(out, "atualizacao: por padrao o GameFlow NAO usa a rede (testes e benchmark ficam offline)", not flow.check_updates and flow.get_children().filter(
			func(n: Node) -> bool: return n is UpdateChecker).is_empty())
	flow._on_update_available("9.9.9", UpdateChecker.TRUSTED_PREFIX + "releases/tag/v9.9.9")
	await tree.process_frame
	var banner: Array = flow.menu.find_children("*", "Label", true, false).filter(func(l: Node) -> bool: return (l as Label).text.contains("9.9.9"))
	TestWorld.rec(out, "atualizacao: nova versao disponivel mostra a faixa no menu com a versao nova e a atual", banner.size() == 1
			and (banner[0] as Label).text.contains(GameVersion.CURRENT))
	flow.menu.show_update("8.8.8", "https://exemplo.com/mal")
	await tree.process_frame
	TestWorld.rec(out, "atualizacao: link fora do projeto nao mostra faixa nenhuma", flow.menu.find_children("*", "Label", true, false).filter(
			func(l: Node) -> bool: return (l as Label).text.contains("8.8.8")).is_empty())
	flow.show_settings()
	await tree.process_frame
	flow.settings_menu._updates.button_pressed = false
	flow.settings_menu.back_pressed.emit()
	await tree.process_frame
	await tree.process_frame
	TestWorld.rec(out, "atualizacao: a faixa volta ao reabrir o menu e a opcao desligada fica salva",
			flow.menu.find_children("*", "Label", true, false).any(func(l: Node) -> bool: return (l as Label).text.contains("9.9.9"))
			and SettingsStore.new(dir + "/settings.json").load_settings() and not _saved(dir)["check_updates"])
	tree.paused = false
	flow.queue_free()
	await tree.process_frame
	TmpDir.remove(TmpDir.ROOT)


func _saved(dir: String) -> Dictionary:
	var s := SettingsStore.new(dir + "/settings.json")
	s.load_settings()
	return s.data


## Decisao do dono: a rede so pode ser usada pela consulta de atualizacao. Qualquer outro uso de rede no codigo do jogo quebra este teste.
func _network_inventory(out: Array) -> void:
	var needles: Array[String] = ["HTTPRequest", "HTTPClient", "WebSocketPeer", "StreamPeerTCP", "TCPServer", "PacketPeerUDP", "ENetMultiplayerPeer", "ENetConnection", "UDPServer", "WebRTC"]
	var offenders: PackedStringArray = []
	var stack: Array[String] = ["res://game"]
	while not stack.is_empty():
		var dir: String = stack.pop_back()
		for sub in DirAccess.get_directories_at(dir):
			stack.append(dir + "/" + sub)
		for f in DirAccess.get_files_at(dir):
			if f.ends_with(".gd") and not (dir.ends_with("/core") and f == "update_checker.gd"):
				var text: String = FileAccess.get_file_as_string(dir + "/" + f)
				for n in needles:
					if text.contains(n):
						offenders.append("%s/%s (%s)" % [dir, f, n])
	TestWorld.rec(out, "rede: so a consulta de atualizacao usa rede (nenhum outro HTTP/socket/multiplayer no codigo do jogo)", offenders.is_empty(), "(%s)" % ", ".join(offenders))
	TestWorld.rec(out, "rede: a consulta usa so o endereco do projeto no GitHub e HTTPS", UpdateChecker.API_URL.begins_with("https://api.github.com/repos/MayconMeneses/Nebulance/"))
