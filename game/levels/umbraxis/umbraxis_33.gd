class_name UmbraxisLevel33
extends LevelScene
## FASE 33 — O Jardim dos Ecos (Umbraxis). Visual PROVISORIO. Dois conjuntos de pedras-eco: so UMA de cada conjunto e verdadeira e a
## diferenca e sempre uma EVIDENCIA observavel (as ilusoes piscam no primeiro; no segundo sao colunas finas e ocas). Tocar a verdadeira
## estabiliza a travessia de plataformas de ruptura; tocar uma ilusao tira um coracao. Projecoes da antiga tripulacao ao fundo, o traje da
## tripulacao e o arquivo do ultimo registro. A inscricao no alto (Zuri escala) abre o portal para a Camara da Primeira Expedicao (S06).
## Checkpoints: antes das ilusoes e perto do portal (ponto de retorno ao sair da S06).

const DEFINITION: String = "res://game/levels/umbraxis/umbraxis_33_definition.tres"
const STONES_A_X: Array[float] = [22.0, 25.5, 29.0]
const STONES_B_X: Array[float] = [52.0, 55.5, 59.0]
const REAL_A: int = 1
const REAL_B: int = 2

var stones_a: Array[EchoStone] = []
var stones_b: Array[EchoStone] = []
var platforms_a: Array[RupturePlatform] = []
var platforms_b: Array[RupturePlatform] = []
var inscription: Mechanism
var portal: Portal


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var moss := Color("3A2F55")
	b.solid(Vector3(14.0, -0.5, 0.0), Vector3(36.0, 1.0, 4.0), moss)
	b.zone(PhysicsLayers.CHECKPOINT, "umbraxis_33_cp1", Vector3(14.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.75, 0.24, 0.66, 0.25))
	for i in STONES_A_X.size():
		stones_a.append(_stone(STONES_A_X[i], i == REAL_A, EchoStone.Cue.BLINK, &"echo_a"))
	for i in 3:
		platforms_a.append(_platform(35.5 + 4.5 * i, i, &"echo_a"))
	b.solid(Vector3(56.25, -0.5, 0.0), Vector3(19.5, 1.0, 4.0), moss)
	for i in STONES_B_X.size():
		stones_b.append(_stone(STONES_B_X[i], i == REAL_B, EchoStone.Cue.SHAPE, &"echo_b"))
	for i in 2:
		platforms_b.append(_platform(69.5 + 4.5 * i, i, &"echo_b"))
	b.solid(Vector3(94.0, -0.5, 0.0), Vector3(36.0, 1.0, 4.0), moss)
	b.zone(PhysicsLayers.CHECKPOINT, "umbraxis_33_cp2", Vector3(79.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.75, 0.24, 0.66, 0.25))
	b.zone(PhysicsLayers.ABYSS, "rift_33a", Vector3(39.5, -6.0, 0.0), Vector3(16.0, 3.0, 4.0), Color(0.5, 0.0, 0.3, 0.2))
	b.zone(PhysicsLayers.ABYSS, "rift_33b", Vector3(71.0, -6.0, 0.0), Vector3(12.0, 3.0, 4.0), Color(0.5, 0.0, 0.3, 0.2))
	# Ruinas altas: a inscricao abre o portal da S06; o traje da tripulacao fica ao lado.
	b.zone(PhysicsLayers.CLIMBABLE, "climb_33", Vector3(82.0, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(85.6, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B4A8F"))
	inscription = Mechanism.new()
	inscription.mechanism_id = &"umbraxis_33_inscription"
	inscription.prompt_text = "Pressione E para ler a inscricao das ruinas"
	inscription.position = Vector3(86.0, 5.8, 0.0)
	add_child(inscription)
	b.pickup("umbraxis_33_crew_suit", Pickup.Kind.ITEM, Vector3(88.0, 5.9, 0.0))
	b.chest("umbraxis_33_chest", Vector3(100.0, 0.6, 0.0))
	b.pickup("memory_expedition_projection_33", Pickup.Kind.MEMORY, Vector3(104.5, 1.0, 0.0))
	portal = Portal.new()
	portal.portal_id = &"umbraxis_33_portal"
	portal.destination_level_id = &"umbraxis_s06"
	portal.requires_open = true
	portal.position = Vector3(108.0, 1.2, 0.0)
	add_child(portal)
	# Projecoes da antiga tripulacao (colunas translucidas) e raizes ao fundo.
	for x in range(92, 112, 5):
		b.decor(Vector3(float(x), 1.2, -3.0), Vector3(0.6, 2.4, 0.4), Color(0.6, 0.9, 1.0, 0.6), true)
	for x in range(-2, 112, 10):
		b.decor(Vector3(float(x), 4.0, -5.5), Vector3(1.8, 8.0 + float(x % 3), 1.8), Color("5B1F4F"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(24, 1, 0), Vector3(40, 1, 0), Vector3(48, 1, 0),
			Vector3(57, 1, 0), Vector3(74, 1, 0), Vector3(85, 6.0, 0), Vector3(97, 1, 0)]
	for i in coins.size():
		b.pickup("umbraxis_33_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	inscription.activated.connect(func(_m: Mechanism) -> void: portal.open())
	for s in stones_a + stones_b:
		s.vitals = rig.vitals


func _stone(x: float, real: bool, cue: EchoStone.Cue, link: StringName) -> EchoStone:
	var s := EchoStone.new()
	s.is_real = real
	s.cue = cue
	s.link_id = link
	s.position = Vector3(x, 0.9, 0.0)
	add_child(s)
	return s


func _platform(x: float, i: int, link: StringName) -> RupturePlatform:
	var p := RupturePlatform.new()
	p.position = Vector3(x, -0.2, 0.0)
	p.phase_offset = 0.0 if i % 2 == 0 else 2.1
	p.link_id = link
	p.solid_time = 3.0
	p.gone_time = 1.2
	add_child(p)
	return p
