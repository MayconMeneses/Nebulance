class_name AerionLevel26
extends LevelScene
## FASE 26 — Os Jardins Suspensos (Aerion). Visual PROVISORIO. Plataformas aereas, correntes de sustentacao e saltos: Pipa planeia
## o primeiro vao (corrente ascendente), Rocco rompe a barreira marcada que ancora a passagem, Zuri escala a estrutura que flutua
## sem tocar o chao e Pipa planeia o segundo vao ate a ilha do bau. Checkpoint antes das lacunas longas. Rota opcional: o item das
## nuvens fica sob a estrutura flutuante (fora do caminho principal).

const DEFINITION: String = "res://game/levels/aerion/aerion_26_definition.tres"

var lift_a: WindVent
var lift_b: WindVent
var barrier: ImpactBarrier
var chest: Chest


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var grass := Color("6FB58F")
	b.solid(Vector3(4.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), grass)
	b.zone(PhysicsLayers.CHECKPOINT, "aerion_26_cp1", Vector3(12.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.93, 0.72, 0.37, 0.25))
	# Primeira lacuna longa (9 m): so Pipa, com a corrente ascendente.
	lift_a = _lift(Vector3(18.5, 1.25, 0.0))
	b.solid(Vector3(37.5, -0.5, 0.0), Vector3(29.0, 1.0, 4.0), grass)
	barrier = b.barrier(Vector3(30.4, 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	# Estrutura que flutua sem contato com o solo: escalada de Zuri na face marcada.
	b.zone(PhysicsLayers.CLIMBABLE, "climb_26", Vector3(37.4, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(42.0, 4.75, 0.0), Vector3(8.0, 0.5, 4.0), Color("8FD3C0"))
	# Segunda lacuna longa: de novo Pipa, partindo do alto da estrutura.
	lift_b = _lift(Vector3(50.5, 6.0, 0.0))
	b.solid(Vector3(66.0, 4.5, 0.0), Vector3(22.0, 1.0, 4.0), grass)
	b.zone(PhysicsLayers.ABYSS, "sky_26", Vector3(35.0, -9.0, 0.0), Vector3(120.0, 3.0, 4.0), Color(0.1, 0.1, 0.3, 0.2))
	chest = b.chest("aerion_26_chest", Vector3(72.0, 5.6, 0.0))
	b.pickup("aerion_26_cloud_seed", Pickup.Kind.ITEM, Vector3(44.0, 1.0, 0.0))
	# Jardins decorativos suspensos (arvores de nuvem) e a estrutura flutuante ao fundo.
	b.decor(Vector3(62.0, 10.0, -4.0), Vector3(9.0, 2.0, 3.0), Color("2FA879"), true)
	b.decor(Vector3(62.0, 8.5, -4.0), Vector3(1.0, 2.0, 1.0), Color("5B3A29"))
	for x in range(0, 60, 9):
		b.decor(Vector3(float(x), -2.5, -5.0), Vector3(6.0, 1.4, 3.0), Color("E8F0FA"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(11, 1, 0), Vector3(26, 1, 0), Vector3(34, 1, 0), Vector3(40, 1, 0),
			Vector3(40, 6.2, 0), Vector3(44, 6.2, 0), Vector3(58, 6.2, 0), Vector3(63, 6.2, 0)]
	for i in coins.size():
		b.pickup("aerion_26_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _lift(pos: Vector3) -> WindVent:
	var v := WindVent.new()
	v.size = Vector3(9.0, 12.0, 3.0)
	v.wind_on = Vector3(0.0, 23.0, 0.0)
	v.position = pos
	add_child(v)
	return v
