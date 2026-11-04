class_name NecryonBoss
extends VyrkanBoss
## Necryon, a Flor-Cadaver (Umbraxis, guardiao da sexta e ultima semente): mesmas regras do contrato de boss (3 fases, avisos >= 0,6 s,
## so a faixa ativa fere, Golpe Triade), com as etapas proprias: 1 = COMBINACAO (tocar os cristais na ordem da fechadura);
## 2 = distinguir a pedra-eco REAL das ilusoes por evidencia (como a flor real de Zythra); 3 = RUPTURA (estabilizar a travessia, escalar e
## selar o nucleo no alto). Caeldron interfere na arena por fora (so mensagem/decoracao): nao ha final aqui.


func _init() -> void:
	stage_keys = {1: &"combine", 2: &"real", 3: &"core"}
	signature = &"rift"


## Pedra errada: penalidade (reinicia o ciclo de ataques da fase atual); o jogador precisa tentar de novo com mais cuidado.
func wrong_illusion() -> void:
	restart_cycle()
