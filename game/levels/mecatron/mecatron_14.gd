class_name MecatronLevel14
extends LevelScene
## FASE 14 — As Esteiras de Titanio (Mecatron). Visual PROVISORIO. Uma barreira marcada (Rocco) abre a rota; esteiras transportam o
## trio ate a sala de sincronizacao, onde tres prensas em ciclo fixo (aviso amarelo antes de descer) exigem tempo. Rota alternativa
## de Zuri (escalada) leva ao item de decoracao industrial. Checkpoint antes da sala de sincronizacao.

const DEFINITION: String = "res://game/levels/mecatron/mecatron_14_definition.tres"

var barrier: ImpactBarrier
var presses: Array[HydraulicPress] = []


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var steel := Color("4B5563")
	b.solid(Vector3(35.0, -0.5, 0.0), Vector3(76.0, 1.0, 4.0), steel)
	barrier = b.barrier(Vector3(13.0, 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	_belt(Vector3(22.0, -0.2, 0.0), 8.0, 1.0)
	b.zone(PhysicsLayers.CHECKPOINT, "mecatron_14_cp1", Vector3(32.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.95, 0.55, 0.2, 0.25))
	b.zone(PhysicsLayers.CLIMBABLE, "climb_14", Vector3(34.4, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(38.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B7280"))
	_belt(Vector3(62.0, -0.2, 0.0), 5.0, 1.0)
	for i in 3:
		var press := HydraulicPress.new()
		press.position = Vector3(40.0 + 8.0 * i, 0.0, 0.0)
		press.phase = 1.3 * i
		add_child(press)
		presses.append(press)
		b.decor(Vector3(40.0 + 8.0 * i, 6.0, -1.8), Vector3(4.0, 0.6, 0.6), Color("6B7280"))
	b.chest("mecatron_14_chest", Vector3(66.0, 0.6, 0.0))
	b.zone(PhysicsLayers.ABYSS, "abyss_14", Vector3(35.0, -9.0, 0.0), Vector3(120.0, 3.0, 4.0), Color(0.3, 0.0, 0.0, 0.2))
	for i in 9:
		var g := GearDecor.new()
		g.radius = 1.0 + float(i % 3)
		g.spin_speed = 0.6 if i % 2 == 0 else -0.6
		g.position = Vector3(float(i) * 9.0, 6.0 + float(i % 3) * 2.0, -5.0)
		add_child(g)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(10, 1, 0), Vector3(20, 1, 0), Vector3(25, 1, 0), Vector3(30, 1, 0),
			Vector3(44, 1, 0), Vector3(52, 1, 0), Vector3(60, 1, 0), Vector3(63, 1, 0)]
	for i in coins.size():
		b.pickup("mecatron_14_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("mecatron_14_industrial_decor", Pickup.Kind.ITEM, Vector3(38.0, 6.1, 0.0))


func _belt(pos: Vector3, length: float, dir: float) -> ConveyorBelt:
	var belt := ConveyorBelt.new()
	belt.size = Vector3(length, 0.4, 4.0)
	belt.direction = dir
	belt.position = pos
	add_child(belt)
	return belt
