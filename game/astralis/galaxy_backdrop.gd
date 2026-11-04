class_name GalaxyBackdrop
extends RefCounted
## Fundo 2D do Mapa Galactico (so desenho, sem estado do jogo): degrade de espaco profundo, nebulosas, aneis de orbita e estrelas que
## cintilam e derivam devagar em duas profundidades (paralaxe). Estrelas DETERMINISTICAS. `moving = false` (reduzir movimento) congela tudo.

const SIZE: Vector2 = Vector2(1280.0, 720.0)
const STAR_COUNT: int = 170
const NEBULAE: Array = [
	[Vector2(250.0, 180.0), 260.0, Color(0.30, 0.18, 0.55)], [Vector2(980.0, 520.0), 300.0, Color(0.10, 0.30, 0.55)],
	[Vector2(640.0, 660.0), 220.0, Color(0.55, 0.15, 0.40)], [Vector2(1000.0, 90.0), 200.0, Color(0.12, 0.40, 0.45)],
]

static var _stars: Array = []


static func _ensure_stars() -> void:
	if not _stars.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260111
	for i in STAR_COUNT:
		_stars.append([Vector2(rng.randf_range(0.0, SIZE.x), rng.randf_range(0.0, SIZE.y)), rng.randf_range(0.8, 2.2), rng.randf_range(0.0, TAU), rng.randf_range(0.3, 1.0)])


## Desenha o fundo no `canvas` (Control em coordenadas do mapa 1280x720). `center`/`orbit_radius`: aneis de orbita ao redor de Umbraxis.
static func draw(canvas: Control, time: float, center: Vector2, orbit_radius: float, moving: bool) -> void:
	_ensure_stars()
	canvas.draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.016, 0.024, 0.06))
	for neb in NEBULAE:
		var col: Color = neb[2]
		for k in 7:
			canvas.draw_circle(neb[0], float(neb[1]) * (1.0 - 0.13 * float(k)), Color(col.r, col.g, col.b, 0.03))
	for ring in 3:
		canvas.draw_arc(center, orbit_radius * (0.62 + 0.38 * float(ring)), 0.0, TAU, 96, Color(0.35, 0.65, 0.95, 0.10 + 0.04 * float(ring)), 1.5)
	for star in _stars:
		var pos: Vector2 = star[0]
		var depth: float = star[3]
		var shift: float = fmod(time * 3.0 * depth, SIZE.x) if moving else 0.0
		pos.x = fposmod(pos.x - shift, SIZE.x)
		var twinkle: float = 0.65 + 0.35 * sin(time * 1.8 + float(star[2])) if moving else 0.8
		canvas.draw_circle(pos, float(star[1]) * (0.6 + 0.5 * depth), Color(0.8, 0.9, 1.0, twinkle * (0.35 + 0.65 * depth)))
