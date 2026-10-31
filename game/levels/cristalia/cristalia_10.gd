class_name CristaliaLevel10
extends LevelScene
## FASE 10 — O Trem de Luz (Cristalia). Visual PROVISORIO. Carrinhos de cristal em movimento sobre os tuneis, resgate de uma criatura
## de cristais e uma tempestade de fragmentos (perseguicao) depois do checkpoint, com um buraco para pular. Queda = 1 vida.

const DEFINITION: String = "res://game/levels/cristalia/cristalia_10_definition.tres"

var _wave: ChaseWave


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var ground := Color("4A3F73")
	b.solid(Vector3(4.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), ground)
	b.zone(PhysicsLayers.ABYSS, "tunnel", Vector3(31.0, -6.0, 0.0), Vector3(36.0, 3.0, 4.0), Color(0.3, 0.0, 0.4, 0.3))
	_moving(19.0, 6.0, 0.0)
	b.solid(Vector3(28.0, -0.5, 0.0), Vector3(8.0, 1.0, 4.0), ground)
	var creature := Rescue.new()
	creature.rescue_id = &"cristalia_10_creature"
	creature.position = Vector3(28.0, 0.8, 0.0)
	add_child(creature)
	_moving(37.0, 6.0, 0.0)
	# Resto da fase: chao com um buraco (as raizes derrubaram a ponte) e o checkpoint antes da perseguicao.
	b.solid(Vector3(61.0, -0.5, 0.0), Vector3(38.0, 1.0, 4.0), ground)
	b.solid(Vector3(101.25, -0.5, 0.0), Vector3(37.5, 1.0, 4.0), ground)
	b.zone(PhysicsLayers.ABYSS, "pit", Vector3(81.25, -6.0, 0.0), Vector3(2.5, 3.0, 4.0), Color(0.5, 0.0, 0.1, 0.25))
	b.zone(PhysicsLayers.CHECKPOINT, "cristalia_10_cp1", Vector3(60.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.25))
	b.chest("cristalia_10_chest", Vector3(116.0, 0.6, 0.0))
	# A onda nasce com a geometria (antes do setup do controller) para entrar no snapshot do checkpoint.
	_wave = ChaseWave.new()
	_wave.position = Vector3(54.0, 3.0, 0.0)
	_wave.speed = 3.3
	add_child(_wave)
	for x in range(-6, 120, 7):
		b.decor(Vector3(float(x), 2.0, -4.0), Vector3(1.4, 4.0 + float(x % 3), 1.4), Color("7C6BC4"), true)
	# Colecionavel em trilho lateral: item no trilho (decoracao ao fundo) da ilha do resgate.
	b.decor(Vector3(30.0, 0.4, -3.0), Vector3(8.0, 0.2, 0.4), Color("A78BFA"), true)
	b.pickup("cristalia_10_rail_collectible", Pickup.Kind.ITEM, Vector3(30.5, 1.0, 0.0))
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(26, 1, 0), Vector3(46, 1, 0), Vector3(52, 1, 0),
			Vector3(62, 1, 0), Vector3(72, 1, 0), Vector3(88, 1, 0), Vector3(100, 1, 0)]
	for i in coins.size():
		b.pickup("cristalia_10_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	_wave.target = rig.body


func _moving(x: float, period: float, phase: float) -> void:
	var p := MovingPlatform.new()
	p.position = Vector3(x, -0.2, 0.0)
	p.period = period
	p.phase = phase
	add_child(p)
