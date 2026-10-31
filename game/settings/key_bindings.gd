class_name KeyBindings
extends RefCounted
## Remapeamento de teclado (TC-023). Guarda so a tecla fisica escolhida por acao; o gamepad nao e tocado.
## O codigo de jogo le apenas acoes do InputMap, entao basta trocar os eventos de tecla da acao.

const ACTIONS: Array[StringName] = [&"move_left", &"move_right", &"jump", &"special", &"swap_prev", &"swap_next", &"interact", &"pause"]
const LABELS: Dictionary = {
	&"move_left": "Andar para a esquerda", &"move_right": "Andar para a direita", &"jump": "Pular", &"special": "Habilidade",
	&"swap_prev": "Heroi anterior", &"swap_next": "Proximo heroi", &"interact": "Interagir", &"pause": "Pausar",
}


## Remove entradas invalidas (acao desconhecida, tipo errado, tecla inexistente) e repetidas; o que sobra e seguro de aplicar.
static func sanitize(raw: Variant) -> Dictionary:
	var out: Dictionary = {}
	if not raw is Dictionary:
		return out
	var used: Dictionary = {}
	for action in ACTIONS:
		var value: Variant = raw.get(String(action))
		if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
			continue
		var code: int = int(value)
		if not _is_key(code) or used.has(code):
			continue
		used[code] = true
		out[String(action)] = code
	return out


## Aplica as teclas escolhidas: substitui os eventos de TECLADO da acao e preserva os de gamepad.
static func apply(keys: Dictionary) -> void:
	for action in ACTIONS:
		if not keys.has(String(action)) or not InputMap.has_action(action):
			continue
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				InputMap.action_erase_event(action, event)
		var ev := InputEventKey.new()
		ev.physical_keycode = int(keys[String(action)]) as Key
		InputMap.action_add_event(action, ev)


## Acao (diferente de `action`) que ja usa essa tecla fisica, ou &"" se livre. Considera as teclas alternativas padrao (setas).
static func conflict(action: StringName, keycode: int) -> StringName:
	for other in ACTIONS:
		if other == action:
			continue
		for event in InputMap.action_get_events(other):
			if event is InputEventKey and (event as InputEventKey).physical_keycode == keycode:
				return other
	return &""


## Tecla principal exibida para a acao.
static func key_name(action: StringName) -> String:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return OS.get_keycode_string((event as InputEventKey).physical_keycode)
	return "-"


## Tenta trocar a tecla de uma acao. Retorna "" se aplicou, ou o texto do motivo da recusa. Altera `keys` so em caso de sucesso.
static func rebind(keys: Dictionary, action: StringName, keycode: int) -> String:
	if not _is_key(keycode):
		return "Tecla invalida."
	var other: StringName = conflict(action, keycode)
	if other != &"":
		return "%s ja usa %s." % [LABELS[other], OS.get_keycode_string(keycode as Key)]
	keys[String(action)] = keycode
	apply(keys)
	return ""


## Tecla fisica real: sem bits de modificador e que o motor reconhece pelo proprio nome (ida e volta).
static func _is_key(code: int) -> bool:
	return code > 0 and code == (code & KEY_CODE_MASK) and OS.find_keycode_from_string(OS.get_keycode_string(code as Key)) == code
