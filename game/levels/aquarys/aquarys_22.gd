class_name AquarysLevel22
extends LevelScene
## FASE 22 — A Onda Colossal (Aquarys). Visual PROVISORIO. Fuga de uma onda que invade o trecho depois do checkpoint: Rocco abre a via na barreira
## marcada, Zuri sobe o muro das passarelas, Pipa planeia com a corrente de ar ate a passarela alta (onde espera um sobrevivente, resgate
## opcional) e a rota segue por uma laje elevada com moedas. A onda comeca atras do ponto de partida e so avanca depois do gatilho.

const DEFINITION: String = "res://game/levels/aquarys/aquarys_22_definition.tres"

var wave: ChaseWave
var barrier: ImpactBarrier
var survivor: Rescue


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var stone := Color("486E86")
	b.solid(Vector3(60.0, -0.5, 0.0), Vector3(128.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.CHECKPOINT, "aquarys_22_cp1", Vector3(34.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.14, 0.81, 0.96, 0.25))
	barrier = b.barrier(Vector3(46.0, 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	# Passarelas altas: muro (Zuri), corrente de ar (Pipa) e a passarela do sobrevivente.
	b.solid(Vector3(60.0, 1.5, 0.0), Vector3(4.0, 3.0, 4.0), Color("5E8FA8"))
	b.solid(Vector3(74.0, 2.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("7FA6C4"))
	b.zone(PhysicsLayers.WIND, "wind_22", Vector3(66.5, 6.0, 0.0), Vector3(9.0, 12.0, 3.0), Color(0.7, 0.9, 1.0, 0.15), Vector3(0.0, 23.0, 0.0))
	survivor = Rescue.new()
	survivor.rescue_id = &"aquarys_22_survivor"
	survivor.position = Vector3(75.5, 3.8, 0.0)
	add_child(survivor)
	# Laje elevada com moedas (rota um pouco mais arriscada, sem parar).
	b.solid(Vector3(91.0, 0.5, 0.0), Vector3(14.0, 1.0, 4.0), Color("5E8FA8"))
	b.chest("aquarys_22_chest", Vector3(116.0, 0.6, 0.0))
	# A onda nasce com a geometria (antes do setup do controller) para entrar no snapshot do checkpoint.
	wave = ChaseWave.new()
	wave.start_x = -8.0
	wave.trigger_x = 44.0
	wave.stop_x = 108.0
	wave.speed = 7.0
	wave.position = Vector3(-8.0, 3.0, 0.0)
	add_child(wave)
	for x in range(-4, 124, 8):
		b.decor(Vector3(float(x), 2.5, -4.0), Vector3(0.7, 5.0 + float(x % 3), 0.7), Color("7FE9F5"), true)
	b.decor(Vector3(30.0, 6.0, -5.0), Vector3(12.0, 0.5, 0.5), Color("3C6E8F"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(14, 1, 0), Vector3(24, 1, 0), Vector3(52, 1, 0), Vector3(60, 4.0, 0),
			Vector3(73, 4.0, 0), Vector3(88, 2.0, 0), Vector3(94, 2.0, 0), Vector3(104, 1, 0)]
	for i in coins.size():
		b.pickup("aquarys_22_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	wave.target = rig.body
