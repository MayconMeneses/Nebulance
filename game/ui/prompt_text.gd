class_name PromptText
extends RefCounted
## Dica de interacao do HUD segundo o aparelho: os textos das fases dizem "Pressione E ...", mas a tecla pode estar remapeada e, com os
## controles de toque, nao existe tecla. A troca acontece so na hora de exibir; os textos das fases e o jogo nao mudam.

const LEGACY_PREFIX: String = "Pressione E"
const TOUCH_BUTTON: String = "INTERAGIR"


## `key` e o nome da tecla atual de "interagir"; `touch` diz se os controles de toque estao na tela.
static func localize(text: String, key: String, touch: bool) -> String:
	if not text.begins_with(LEGACY_PREFIX):
		return text
	var rest: String = text.substr(LEGACY_PREFIX.length())
	if rest != "" and rest[0] != " " and rest[0] != ":":
		return text
	return ("Toque em " + TOUCH_BUTTON if touch else "Pressione " + key) + rest


## Dica de troca de heroi exibida no HUD.
static func swap_hint(prev_key: String, next_key: String, touch: bool) -> String:
	return "botoes HEROI -/+" if touch else "%s/%s troca" % [prev_key, next_key]
