class_name UpdateChecker
extends Node
## Verifica, ao abrir o jogo, se existe uma versao mais nova publicada (GitHub Releases do projeto). E o UNICO uso de rede do jogo:
## uma consulta GET sem dados do jogador, que pode ser desligada em Configuracoes. Nao baixa nem executa nada: so avisa e abre a
## pagina da versao no navegador (se o jogador pedir). Qualquer falha (sem internet, sem release, resposta estranha) e silenciosa.

signal update_available(version: String, url: String)

const API_URL: String = "https://api.github.com/repos/MayconMeneses/Nebulance/releases/latest"
const TRUSTED_PREFIX: String = "https://github.com/MayconMeneses/Nebulance/"
const TIMEOUT_SECONDS: float = 6.0

var _request: HTTPRequest


func check() -> void:
	_request = HTTPRequest.new()
	_request.timeout = TIMEOUT_SECONDS
	add_child(_request)
	_request.request_completed.connect(_on_completed)
	var headers: PackedStringArray = ["Accept: application/vnd.github+json", "User-Agent: NEBULANCE/" + GameVersion.CURRENT]
	if _request.request(API_URL, headers) != OK:
		_request.queue_free()


func _on_completed(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		return
	var info: Dictionary = parse_release(JSON.parse_string(body.get_string_from_utf8()))
	if not info.is_empty() and is_newer(info["version"], GameVersion.CURRENT):
		update_available.emit(info["version"], info["url"])


## Extrai {version, url} da resposta da API; vazio se a resposta nao for confiavel (so aceita links do proprio projeto).
static func parse_release(data: Variant) -> Dictionary:
	if not data is Dictionary:
		return {}
	var tag: Variant = data.get("tag_name")
	var url: Variant = data.get("html_url")
	if typeof(tag) != TYPE_STRING or typeof(url) != TYPE_STRING:
		return {}
	var version: String = String(tag).trim_prefix("v")
	if _parts(version).is_empty() or not String(url).begins_with(TRUSTED_PREFIX) or data.get("draft") == true or data.get("prerelease") == true:
		return {}
	return {"version": version, "url": url}


## Comparacao numerica de "a.b.c" (0.10.0 > 0.9.0). Versao invalida nunca e "mais nova".
static func is_newer(remote: String, local: String) -> bool:
	var r: Array = _parts(remote)
	var l: Array = _parts(local)
	if r.is_empty() or l.is_empty():
		return false
	for i in maxi(r.size(), l.size()):
		var a: int = r[i] if i < r.size() else 0
		var b: int = l[i] if i < l.size() else 0
		if a != b:
			return a > b
	return false


static func _parts(version: String) -> Array:
	var out: Array = []
	for piece in version.split("."):
		if not piece.is_valid_int():
			return []
		out.append(int(piece))
	return out
