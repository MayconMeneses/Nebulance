class_name ZefrionBoss
extends VyrkanBoss
## Zefrion, o Dente-de-Leao (Aerion): mesmas regras do contrato de boss (3 fases, avisos >= 0,6 s, so a faixa ativa fere,
## Golpe Triade), com as etapas proprias de vento e gravidade localizada: 1 = ancorar os controles de vento (dois mecanismos
## sincronizados); 2 = escalar ate o farol; 3 = planear na corrente ate o nucleo e desativar a protecao da semente.


func _init() -> void:
	stage_keys = {1: &"anchors", 2: &"climb", 3: &"glide"}
