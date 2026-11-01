class_name AerionLevel25
extends LevelScene
## FASE 25 — O Porto das Nuvens (Aerion). Visual PROVISORIO. Chegada ao arquipelago suspenso: introducao a vento direcional (um vao
## com vento de popa empurra quem esta no ar), plataformas suspensas em degraus e altitude ate o antigo observatorio.
## Checkpoint logo depois da primeira corrente. Item tematico: Horizonte.

const DEFINITION: String = "res://game/levels/aerion/aerion_25_definition.tres"

var tailwind: WindVent
var chest: Chest


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var cloud := Color("A9C7E8")
	b.solid(Vector3(4.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), cloud)
	# Vao de 7 m com vento de popa (sinalizado pela zona luminosa e pelas faixas no ar).
	tailwind = WindVent.new()
	tailwind.size = Vector3(7.0, 8.0, 3.0)
	tailwind.wind_on = Vector3(40.0, 0.0, 0.0)
	tailwind.position = Vector3(17.5, 2.0, 0.0)
	add_child(tailwind)
	b.solid(Vector3(32.5, -0.5, 0.0), Vector3(23.0, 1.0, 4.0), cloud)
	b.zone(PhysicsLayers.CHECKPOINT, "aerion_25_cp1", Vector3(23.5, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.93, 0.72, 0.37, 0.25))
	# Degraus suspensos ate o observatorio (altitude).
	b.solid(Vector3(32.0, 0.95, 0.0), Vector3(4.0, 0.5, 4.0), Color("7FA6C4"))
	b.solid(Vector3(37.5, 2.15, 0.0), Vector3(4.0, 0.5, 4.0), Color("7FA6C4"))
	b.solid(Vector3(51.5, 3.1, 0.0), Vector3(21.0, 1.0, 4.0), cloud)
	b.zone(PhysicsLayers.ABYSS, "sky_25", Vector3(30.0, -9.0, 0.0), Vector3(120.0, 3.0, 4.0), Color(0.1, 0.1, 0.3, 0.2))
	chest = b.chest("aerion_25_chest", Vector3(58.0, 4.2, 0.0))
	b.pickup("aerion_25_horizon_item", Pickup.Kind.ITEM, Vector3(37.5, 3.2, 0.0))
	# Observatorio nas nuvens (decoracao) e ilhas ao longe.
	b.decor(Vector3(50.0, 6.6, -3.0), Vector3(6.0, 5.0, 2.0), Color("D9E4F2"), true)
	b.decor(Vector3(50.0, 9.6, -3.0), Vector3(3.0, 1.2, 2.0), Color("EDB85E"), true)
	for x in range(-2, 60, 10):
		b.decor(Vector3(float(x), -2.5, -5.0), Vector3(6.0, 1.4, 3.0), Color("E8F0FA"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(25.5, 1, 0), Vector3(29, 1, 0), Vector3(32, 2.2, 0),
			Vector3(44, 4.6, 0), Vector3(48, 4.6, 0), Vector3(52, 4.6, 0), Vector3(55, 4.6, 0)]
	for i in coins.size():
		b.pickup("aerion_25_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
