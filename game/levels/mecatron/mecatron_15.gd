class_name MecatronLevel15
extends LevelScene
## FASE 15 — O Trem do Eclipse (Mecatron). Visual PROVISORIO. Vagoes maglev em movimento sobre os tuneis da fabrica, resgate de uma criatura
## e raizes que ameacam os trilhos (perseguicao) depois do checkpoint, com um buraco para pular. Queda = 1 vida.
## O colecionavel fica num vagao elevado antes da perseguicao (opcional: exige o salto duplo de Zuri).

const DEFINITION: String = "res://game/levels/mecatron/mecatron_15_definition.tres"

var _wave: ChaseWave


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var ground := Color("4B5563")
	b.solid(Vector3(4.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), ground)
	b.zone(PhysicsLayers.ABYSS, "tunnel", Vector3(31.0, -6.0, 0.0), Vector3(36.0, 3.0, 4.0), Color(0.3, 0.0, 0.4, 0.3))
	_moving(19.0, 6.0, 0.0)
	b.solid(Vector3(28.0, -0.5, 0.0), Vector3(8.0, 1.0, 4.0), ground)
	var creature := Rescue.new()
	creature.rescue_id = &"mecatron_15_creature"
	creature.position = Vector3(28.0, 0.8, 0.0)
	add_child(creature)
	_moving(37.0, 6.0, 0.0)
	# Resto da fase: chao com um buraco (as raizes derrubaram a ponte) e o checkpoint antes da perseguicao.
	b.solid(Vector3(61.0, -0.5, 0.0), Vector3(38.0, 1.0, 4.0), ground)
	b.solid(Vector3(101.25, -0.5, 0.0), Vector3(37.5, 1.0, 4.0), ground)
	b.zone(PhysicsLayers.ABYSS, "pit", Vector3(81.25, -6.0, 0.0), Vector3(2.5, 3.0, 4.0), Color(0.5, 0.0, 0.1, 0.25))
	b.zone(PhysicsLayers.CHECKPOINT, "mecatron_15_cp1", Vector3(60.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.25))
	b.chest("mecatron_15_chest", Vector3(116.0, 0.6, 0.0))
	# A onda nasce com a geometria (antes do setup do controller) para entrar no snapshot do checkpoint.
	_wave = ChaseWave.new()
	_wave.position = Vector3(54.0, 3.0, 0.0)
	_wave.speed = 3.3
	add_child(_wave)
	for x in range(-6, 120, 7):
		b.decor(Vector3(float(x), 2.0, -4.0), Vector3(1.4, 4.0 + float(x % 3), 1.4), Color("8A5A2B"), true)
	# Colecionavel num vagao elevado (parado, no trilho lateral) depois da segunda plataforma, antes da perseguicao: topo a 2,4 m (vao livre de 2,2 m por baixo), so o salto duplo de Zuri o alcanca.
	b.decor(Vector3(48.5, 1.1, -3.0), Vector3(8.0, 0.2, 0.4), Color("F08A3B"), true)
	b.solid(Vector3(48.5, 2.3, 0.0), Vector3(3.0, 0.2, 3.0), Color("F08A3B"))
	b.pickup("mecatron_15_rail_collectible", Pickup.Kind.ITEM, Vector3(48.5, 3.4, 0.0))
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(26, 1, 0), Vector3(46, 1, 0), Vector3(52, 1, 0),
			Vector3(62, 1, 0), Vector3(72, 1, 0), Vector3(88, 1, 0), Vector3(100, 1, 0)]
	for i in coins.size():
		b.pickup("mecatron_15_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	_wave.target = rig.body


func _moving(x: float, period: float, phase: float) -> void:
	var p := MovingPlatform.new()
	p.position = Vector3(x, -0.2, 0.0)
	p.period = period
	p.phase = phase
	add_child(p)
