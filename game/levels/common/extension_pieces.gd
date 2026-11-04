class_name ExtensionPieces
extends RefCounted
## Pecas de desafio do trecho extra (LevelExtension). Cada peca monta a geometria a partir do ExtCursor e registra a ROTA que a resolve.
## Folgas escolhidas para QUALQUER heroi saltar (Rocco, o mais fraco: 5,5 m/s e salto de 8,5 => ~3,9 m); so climb, glide e barrier exigem um heroi.
## Os numeros (gaps, alturas) sao conferidos pelo bot de teste, que atravessa cada fase so com intents.

const HERO_ROCCO: int = 0
const HERO_ZURI: int = 1
const HERO_PIPA: int = 2
const HOP_STEPS: Array[float] = [0.0, 0.6, -0.5, 0.8, -0.8, 0.0, 0.5, -0.6]


## Plataformas separadas por abismo; `gap` em metros (ate 3.2), degraus pequenos para cima/baixo.
static func hops(c: ExtCursor, count: int, gap: float, width: float = 3.2) -> void:
	c.step(&"hero", {"index": HERO_ZURI})
	for i in count:
		var takeoff: float = c.x - 0.4
		c.gap(gap)
		c.rise(HOP_STEPS[(i + c.number) % HOP_STEPS.size()])
		c.step(&"hop", {"x": takeoff, "land": c.x + width * 0.5})
		c.slab(width, c.accent)


## Piso longo com criaturas contaminadas, uma a cada 12 m (a fora de alcance da anterior), atravessadas saltando na hora certa.
static func patrol(c: ExtCursor, count: int) -> void:
	c.step(&"hero", {"index": HERO_ZURI})
	var x0: float = c.x
	c.slab(12.0 * float(count) + 4.0)
	for i in count:
		var lo: float = x0 + 4.0 + 12.0 * float(i)
		var enemy: PatrolEnemy = c.b.enemy(Vector3(lo, c.y + 0.45, 0.0), lo, lo + 6.0)
		c.step(&"cross", {"x": lo + 8.0, "enemy": enemy})


## Barreira marcada no piso: so a investida de Rocco abre passagem.
static func barrier(c: ExtCursor) -> void:
	c.step(&"hero", {"index": HERO_ROCCO})
	var x0: float = c.x
	c.slab(14.0)
	var wall: ImpactBarrier = c.b.barrier(Vector3(x0 + 7.0, c.y + 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	c.step(&"special", {"x": x0 + 3.8, "barrier": wall})


## Muro alto (3 m): so o salto duplo de Zuri chega ao topo; depois desce para o piso de antes (com 4 m de piso para pousar sem passar direto).
static func climb(c: ExtCursor) -> void:
	c.step(&"hero", {"index": HERO_ZURI})
	c.slab(7.0)
	c.step(&"dbl", {"x": c.x - 5.0, "top": c.y + 3.0})
	c.rise(3.0)
	c.slab(7.0, c.accent)
	c.rise(-3.0)
	c.slab(4.0)


## Vao largo (6,8 m, alem do salto de qualquer heroi sem habilidade): o planeio de Pipa atravessa (dura 1,5 s a 6 m/s).
static func glide(c: ExtCursor) -> void:
	c.step(&"hero", {"index": HERO_PIPA})
	c.slab(4.0)
	var jump_x: float = c.x - 0.5
	c.gap(6.8)
	c.rise(-0.3)
	c.step(&"glide", {"x": jump_x, "to": c.x + 0.5})
	c.slab(6.0, c.accent)


## Ponte de plataformas de ruptura (somem e voltam): cada uma abre depois da anterior, o jogador espera a luz verde.
static func rupture(c: ExtCursor, count: int) -> void:
	c.step(&"hero", {"index": HERO_ZURI})
	c.slab(4.0)
	for i in count:
		var p := RupturePlatform.new()
		p.position = Vector3(c.x + 3.0 + 4.5 * float(i), c.y - 0.2, 0.0)
		p.phase_offset = -1.6 * float(i)
		p.solid_time = 3.4
		p.gone_time = 1.0
		c.b.parent.add_child(p)
		c.step(&"rupt", {"x": p.position.x - 3.4, "plat": p})
	c.step(&"tap", {"x": c.x + 3.0 + 4.5 * float(count - 1) + 1.1})
	c.gap(4.5 * float(count) + 1.5)
	c.slab(5.0, c.accent)


## Respiro com checkpoint.
static func rest(c: ExtCursor) -> void:
	c.slab(7.0)
	c.checkpoint()
