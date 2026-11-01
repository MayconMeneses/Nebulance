class_name TouchLayout
extends RefCounted
## Disposicao pura dos controles de toque (sem nos): cada botao dispara UMA acao do InputMap. Coordenadas no viewport 1280x720.
## Lado: "L"/"R" = borda de ancoragem; `edge` e a distancia da borda lateral; `y` e a distancia da borda de baixo ("B") ou de cima ("T").

const VIEW: Vector2 = Vector2(1280.0, 720.0)
const SIZE_SCALES: Array[float] = [0.8, 1.0, 1.3]
const OPACITIES: Array[float] = [0.25, 0.4, 0.65]
const MODES: Array[String] = ["auto", "on", "off"]

## action, rotulo, lado, borda, y, referencia vertical, largura, altura
const ENTRIES: Array = [
	[&"move_left", "<", "L", 30.0, 40.0, "B", 140.0, 140.0],
	[&"move_right", ">", "L", 190.0, 40.0, "B", 140.0, 140.0],
	[&"jump", "PULAR", "R", 30.0, 40.0, "B", 170.0, 170.0],
	[&"special", "HAB.", "R", 230.0, 40.0, "B", 120.0, 120.0],
	[&"interact", "INTERAGIR", "R", 60.0, 230.0, "B", 130.0, 100.0],
	[&"swap_prev", "HEROI -", "L", 30.0, 20.0, "T", 120.0, 70.0],
	[&"swap_next", "HEROI +", "L", 170.0, 20.0, "T", 120.0, 70.0],
	[&"pause", "II", "R", 30.0, 20.0, "T", 80.0, 70.0],
]


## Retângulo (em coordenadas do viewport) de cada acao para um tamanho e lado (espelhado = canhoto).
static func rects(scale: float, mirror: bool) -> Dictionary:
	var out: Dictionary = {}
	for e in ENTRIES:
		var w: float = e[6] * scale
		var h: float = e[7] * scale
		var edge: float = e[3] * scale
		var gap: float = e[4] * scale
		var side: String = e[2]
		if mirror:
			side = "R" if side == "L" else "L"
		var x: float = edge if side == "L" else VIEW.x - edge - w
		var y: float = VIEW.y - gap - h if e[5] == "B" else gap
		out[e[0]] = Rect2(x, y, w, h)
	return out


## Verdadeiro se os controles devem aparecer: "on" sempre, "off" nunca, "auto" so em aparelho com tela de toque.
static func should_show(mode: String, touchscreen_available: bool) -> bool:
	return mode == "on" or (mode == "auto" and touchscreen_available)
