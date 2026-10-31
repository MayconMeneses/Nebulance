class_name CristaliaLevelS02
extends LevelScene
## S02 — Camara das Frequencias Perdidas (Cristalia, fase secreta). Visual PROVISORIO. Sincronizar cristais musicais na ordem certa
## (roteiro deterministico, com dica que pisca em sequencia). Recompensa: Lente do Primeiro Explorador, item Prisma Cosmico e moedas.

const DEFINITION: String = "res://game/levels/cristalia/cristalia_s02_definition.tres"

var lock: SequenceLock
var chest: Chest


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	b.solid(Vector3(21.0, -0.5, 0.0), Vector3(50.0, 1.0, 4.0), Color("4A3F73"))
	lock = SequenceLock.new()
	add_child(lock)
	for i in 4:
		var c := SequenceCrystal.new()
		c.index = i
		c.lock = lock
		c.position = Vector3(8.0 + 8.0 * i, 1.0, 0.0)
		add_child(c)
		lock.crystals.append(c)
	chest = b.chest("cristalia_s02_chest", Vector3(42.0, 0.6, 0.0))
	chest.locked = true
	lock.chest = chest
	for x in range(-2, 46, 7):
		b.decor(Vector3(float(x), 2.0, -4.0), Vector3(1.4, 4.0, 1.4), Color("7C6BC4"), true)
	var coins: Array[Vector3] = [Vector3(12, 1, 0), Vector3(20, 1, 0), Vector3(28, 1, 0), Vector3(36, 1, 0)]
	for i in coins.size():
		b.pickup("cristalia_s02_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("cristalia_s02_explorer_lens", Pickup.Kind.ITEM, Vector3(39.0, 1.0, 0.0))
	b.pickup("cristalia_s02_prism_item", Pickup.Kind.ITEM, Vector3(40.0, 1.0, 0.0))
