class_name ZythraBoss
extends VyrkanBoss
## Zythra, a Orquidea de Cristal (Cristalia): mesmas regras do contrato de boss (3 fases, avisos >= 0,6 s, so a faixa ativa fere,
## Golpe Triade), com as etapas proprias: 1 = reposicionar o prisma ate o nucleo; 2 = distinguir a flor REAL das ilusoes; 3 = planeio de Pipa.


func _init() -> void:
	stage_keys = {1: &"prism", 2: &"real", 3: &"pipa"}
	signature = &"petal"


## Flor errada: penalidade (reinicia o ciclo de ataques da fase atual); o jogador precisa tentar de novo com mais cuidado.
func wrong_flower() -> void:
	restart_cycle()
