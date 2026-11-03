extends RefCounted
## GravityFrame: sinal do referencial de gravidade e passo vertical (normal, invertido e no piso), sem cena.

const G: float = 30.0
const MAX_FALL: float = 20.0
const DT: float = 1.0 / 60.0


func run(_tree: SceneTree) -> Array:
	var out: Array = []
	TestWorld.rec(out, "gravidade: escala negativa inverte o referencial; zero, normal e baixa (0,4) nao",
			GravityFrame.dir_of(-0.7) == -1.0 and GravityFrame.dir_of(1.0) == 1.0 and GravityFrame.dir_of(0.4) == 1.0 and GravityFrame.dir_of(0.0) == 1.0)
	var down: float = GravityFrame.step(0.0, 1.0, 1.0, false, G, MAX_FALL, DT)
	TestWorld.rec(out, "gravidade: normal, no ar acelera para baixo (vy negativo)", is_equal_approx(down, -G * DT))
	var up: float = GravityFrame.step(0.0, -1.0, -0.7, false, G, MAX_FALL, DT)
	TestWorld.rec(out, "gravidade: invertida, no ar acelera para cima com 0,7 da gravidade (vy positivo)", is_equal_approx(up, G * 0.7 * DT))
	TestWorld.rec(out, "gravidade: velocidade de queda limitada (normal = maxima; invertida = metade da maxima)",
			is_equal_approx(GravityFrame.step(-MAX_FALL, 1.0, 1.0, false, G, MAX_FALL, DT), -MAX_FALL)
			and is_equal_approx(GravityFrame.step(MAX_FALL * 0.5, -1.0, -0.7, false, G, MAX_FALL, DT), MAX_FALL * 0.5))
	TestWorld.rec(out, "gravidade: no piso nao ha velocidade para dentro dele (normal: sem vy negativo; teto-piso: sem vy positivo), mas o pulo sai",
			GravityFrame.step(-5.0, 1.0, 1.0, true, G, MAX_FALL, DT) == 0.0 and GravityFrame.step(5.0, -1.0, -0.7, true, G, MAX_FALL, DT) == 0.0
			and GravityFrame.step(8.0, 1.0, 1.0, true, G, MAX_FALL, DT) == 8.0 and GravityFrame.step(-8.0, -1.0, -0.7, true, G, MAX_FALL, DT) == -8.0)
	return out
