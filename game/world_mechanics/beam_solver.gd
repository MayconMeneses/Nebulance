class_name BeamSolver
extends RefCounted
## Solver DETERMINISTICO de feixes em grade (PDF §09: prismas e feixes discretos, sem ray tracing real).
## Celulas inteiras no plano XY. Prisma '/' (orientacao 0): (dx,dy) -> (dy,dx). Prisma '\' (orientacao 1): (dx,dy) -> (-dy,-dx).
## O feixe anda uma celula por passo; para em bloqueio, alvo, fora dos limites ou no limite de passos (anti-laco).

const MAX_STEPS: int = 96


static func reflect(dir: Vector2i, orientation: int) -> Vector2i:
	return Vector2i(dir.y, dir.x) if orientation == 0 else Vector2i(-dir.y, -dir.x)


## prisms: {Vector2i: orientacao 0|1}; blockers: {Vector2i: true}; targets: {Vector2i: id}; bounds: Rect2i valido para o feixe.
## Retorna {"segments": Array de [Vector2i inicio, Vector2i fim], "hits": Array de ids de alvos atingidos}.
static func trace(origin: Vector2i, dir: Vector2i, prisms: Dictionary, blockers: Dictionary, targets: Dictionary, bounds: Rect2i) -> Dictionary:
	var segments: Array = []
	var hits: Array = []
	var pos: Vector2i = origin
	var seg_start: Vector2i = origin
	var d: Vector2i = dir
	for step in MAX_STEPS:
		var next: Vector2i = pos + d
		if not bounds.has_point(next) or blockers.has(next):
			break
		pos = next
		if targets.has(pos):
			hits.append(targets[pos])
			break
		if prisms.has(pos):
			segments.append([seg_start, pos])
			seg_start = pos
			d = reflect(d, prisms[pos])
	segments.append([seg_start, pos])
	return {"segments": segments, "hits": hits}
