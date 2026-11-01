class_name AerionLevelS05
extends LevelScene
## S05 — Jardim Sem Gravidade (Aerion, fase secreta). Visual PROVISORIO. Plataformas em baixa gravidade (escala 0,4 em toda a area):
## tres saltos longos de Rocco levam ao alto, Pipa planeia com precisao ate a ilha seguinte e salta ate a ilha do bau.
## Recompensa: cosmetico lendario, moedas e o registro estelar.

const DEFINITION: String = "res://game/levels/aerion/aerion_s05_definition.tres"
const LOW_GRAVITY: float = 0.4

var low_gravity: LevelZone
var chest: Chest


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var moss := Color("5FAF8A")
	low_gravity = b.zone(PhysicsLayers.WIND, "low_gravity_s05", Vector3(20.0, 10.0, 0.0), Vector3(60.0, 28.0, 4.0), Color(0.6, 0.4, 1.0, 0.06), Vector3.ZERO, LOW_GRAVITY)
	b.zone(PhysicsLayers.ABYSS, "abyss_s05", Vector3(20.0, -9.0, 0.0), Vector3(80.0, 3.0, 4.0), Color(0.5, 0.0, 0.1, 0.2))
	b.zone(PhysicsLayers.CHECKPOINT, "aerion_s05_cp1", Vector3(0.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.93, 0.72, 0.37, 0.2))
	b.solid(Vector3(0.0, -0.25, 0.0), Vector3(6.0, 0.5, 4.0), moss)
	b.solid(Vector3(5.0, 1.5, 0.0), Vector3(3.0, 0.5, 4.0), moss)
	b.solid(Vector3(10.0, 3.5, 0.0), Vector3(3.0, 0.5, 4.0), moss)
	b.solid(Vector3(15.0, 5.5, 0.0), Vector3(4.0, 0.5, 4.0), moss)
	# Planeio de precisao: ilha pequena (4 m) bem abaixo e longe.
	b.solid(Vector3(30.0, 3.75, 0.0), Vector3(4.0, 0.5, 4.0), Color("8FD3C0"))
	b.solid(Vector3(39.0, 5.75, 0.0), Vector3(8.0, 0.5, 4.0), moss)
	chest = b.chest("aerion_s05_chest", Vector3(41.0, 6.6, 0.0))
	b.pickup("aerion_s05_legendary_cosmetic", Pickup.Kind.ITEM, Vector3(37.0, 7.0, 0.0))
	b.pickup("memory_stellar_record_s05", Pickup.Kind.MEMORY, Vector3(39.0, 7.0, 0.0))
	for x in range(-4, 46, 10):
		b.decor(Vector3(float(x), 8.0, -4.0), Vector3(0.7, 16.0, 0.7), Color("5B3A29"))
		b.decor(Vector3(float(x), 17.0, -4.0), Vector3(4.0, 2.5, 4.0), Color("2FA879"), true)
	var coins: Array[Vector3] = [Vector3(5, 2.9, 0), Vector3(10, 4.9, 0), Vector3(15, 6.9, 0), Vector3(30, 5.15, 0), Vector3(36, 7.15, 0)]
	for i in coins.size():
		b.pickup("aerion_s05_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
