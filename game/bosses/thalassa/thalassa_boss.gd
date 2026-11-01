class_name ThalassaBoss
extends VyrkanBoss
## Thalassa, a Vitoria-Regia (Aquarys): mesmas regras do contrato de boss (3 fases, avisos >= 0,6 s, so a faixa ativa fere,
## Golpe Triade), com as etapas proprias: 1 = estabilizar o fluxo (comportas nos niveis certos); 2 = as folhas flutuantes
## (a onda ergue a folha com o heroi); 3 = desativar a protecao da semente no alto.


func _init() -> void:
	stage_keys = {1: &"flux", 2: &"leaves", 3: &"shield"}
