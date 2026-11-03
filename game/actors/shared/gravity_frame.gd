class_name GravityFrame
extends RefCounted
## Referencial de gravidade do heroi: +1 = normal (cai para -Y), -1 = zona de gravidade invertida (o teto vira o piso). Tudo que depende de
## "para cima/para baixo" no controller usa este sinal, entao `is_on_floor()`, pulo e queda funcionam igual no teto (up_direction acompanha).


static func dir_of(scale: float) -> float:
	return -1.0 if scale < 0.0 else 1.0


## Nova velocidade vertical de um quadro: sem velocidade para dentro do piso (o do referencial atual); no ar, acelera em direcao a gravidade
## (`g` = sinal, `scale` = multiplicador da zona). Na zona invertida a "queda" para o teto e limitada a metade da velocidade maxima.
static func step(velocity_y: float, g: float, scale: float, on_floor: bool, gravity: float, max_fall: float, delta: float) -> float:
	if on_floor:
		return maxf(velocity_y * g, 0.0) * g
	var limit: float = max_fall * (0.5 if g < 0.0 else 1.0)
	return maxf(velocity_y * g - gravity * absf(scale) * delta, -limit) * g
