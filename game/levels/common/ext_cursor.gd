class_name ExtCursor
extends RefCounted
## Cursor de montagem do TRECHO EXTRA de uma fase (a fase dobra de tamanho, ver LevelExtension): guarda a borda direita (`x`) e a altura do piso (`y`)
## onde a proxima peca encaixa, e acumula a ROTA: a lista de passos que um jogador (ou o bot de teste) cumpre para atravessar o trecho.
## Passos (Dictionary com "op"): hero, hop, cross, special, dbl, glide, rupt. Quem executa a rota: tests/support/extension_runner.gd.

var b: SegmentBuilder
var x: float = 0.0
var y: float = 0.0
var start_x: float = 0.0
var start_y: float = 0.0
var low_y: float = 0.0
var number: int = 1
var ground: Color = Color("2F5D4A")
var accent: Color = Color("3E7A63")
var route: Array = []
var checkpoint_prefix: String = ""
var checkpoints: int = 0


func _init(builder: SegmentBuilder, x0: float, y0: float, level_number: int, color: Color) -> void:
	b = builder
	x = x0
	y = y0
	start_x = x0
	start_y = y0
	low_y = y0
	number = level_number
	ground = color
	accent = color.lightened(0.18)


## Laje de piso: do cursor ate `x + width`, topo em `y`, espessura 1.
func slab(width: float, color: Color = Color(0, 0, 0, 0)) -> StaticBody3D:
	var body: StaticBody3D = b.solid(Vector3(x + width * 0.5, y - 0.5, 0.0), Vector3(width, 1.0, 4.0), ground if color.a == 0.0 else color)
	x += width
	return body


func gap(width: float) -> void:
	x += width


func rise(dy: float) -> void:
	y += dy
	low_y = minf(low_y, y)


func step(op: StringName, data: Dictionary = {}) -> void:
	var s: Dictionary = data.duplicate()
	s["op"] = op
	route.append(s)


## Checkpoint no piso, a `back` metros atras do cursor.
func checkpoint(back: float = 3.0) -> void:
	checkpoints += 1
	b.zone(PhysicsLayers.CHECKPOINT, "%s_xcp%d" % [checkpoint_prefix, checkpoints], Vector3(x - back, y + 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.25))
