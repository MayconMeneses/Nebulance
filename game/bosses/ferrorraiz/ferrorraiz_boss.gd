class_name FerrorraizBoss
extends VyrkanBoss
## Ferrorraiz, o Cacto Mecanico (Mecatron): mesmas regras do contrato de boss (3 fases, avisos >= 0,6 s, so a faixa ativa fere,
## Golpe Triade), com as etapas proprias: 1 = desligar os sistemas de energia (dois interruptores sincronizados);
## 2 = mover a ancora magnetica (plataforma de polaridade); 3 = abrir a protecao (mecanismo no alto).


func _init() -> void:
	stage_keys = {1: &"power", 2: &"anchors", 3: &"shield"}
	signature = &"spike"
