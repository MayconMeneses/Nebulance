class_name UmbraxisLevelS06
extends LevelScene
## S06 — Camara da Primeira Expedicao (Umbraxis, fase secreta; entrada pelo portal da fase 33). Visual PROVISORIO. Arquivo antigo com
## ilusoes LEVES (um unico conjunto de pedras-eco, distinguivel pelo piscar) que estabiliza a travessia, e o puzzle final da expedicao:
## tocar os cristais na ordem da fechadura (a dica pisca em sequencia) para liberar o bau. Recompensa: traje exclusivo, moedas e uma
## revelacao adicional (arquivo final da expedicao) que NAO substitui o final principal.

const DEFINITION: String = "res://game/levels/umbraxis/umbraxis_s06_definition.tres"

var stones: Array[EchoStone] = []
var platforms: Array[RupturePlatform] = []
var lock: SequenceLock
var chest: Chest


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var stone := Color("3A2F55")
	b.solid(Vector3(8.0, -0.5, 0.0), Vector3(24.0, 1.0, 4.0), stone)
	for i in 3:
		var s := EchoStone.new()
		s.is_real = i == 0
		s.cue = EchoStone.Cue.BLINK
		s.link_id = &"s06_echo"
		s.position = Vector3(8.0 + 3.5 * i, 0.9, 0.0)
		add_child(s)
		stones.append(s)
	for i in 2:
		var p := RupturePlatform.new()
		p.position = Vector3(23.5 + 4.5 * i, -0.2, 0.0)
		p.phase_offset = 0.0 if i % 2 == 0 else 2.1
		p.link_id = &"s06_echo"
		p.solid_time = 3.0
		p.gone_time = 1.2
		add_child(p)
		platforms.append(p)
	b.solid(Vector3(48.0, -0.5, 0.0), Vector3(36.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.ABYSS, "rift_s06", Vector3(25.0, -6.0, 0.0), Vector3(14.0, 3.0, 4.0), Color(0.5, 0.0, 0.3, 0.2))
	lock = SequenceLock.new()
	add_child(lock)
	for i in 4:
		var c := SequenceCrystal.new()
		c.index = i
		c.lock = lock
		c.position = Vector3(36.0 + 6.0 * i, 1.0, 0.0)
		add_child(c)
		lock.crystals.append(c)
	chest = b.chest("umbraxis_s06_chest", Vector3(62.0, 0.6, 0.0))
	chest.locked = true
	lock.chest = chest
	b.pickup("umbraxis_s06_expedition_suit", Pickup.Kind.ITEM, Vector3(64.4, 1.0, 0.0))
	b.pickup("memory_first_expedition_final_s06", Pickup.Kind.MEMORY, Vector3(65.4, 1.0, 0.0))
	# Arquivo antigo: estantes e projecoes leves ao fundo.
	for x in range(-2, 68, 7):
		b.decor(Vector3(float(x), 2.0, -4.0), Vector3(1.6, 4.0, 0.8), Color("6B4A8F"), true)
	for x in range(10, 66, 14):
		b.decor(Vector3(float(x), 2.4, -2.6), Vector3(0.6, 2.2, 0.3), Color(0.6, 0.9, 1.0, 0.6), true)
	var coins: Array[Vector3] = [Vector3(4, 1, 0), Vector3(12, 1, 0), Vector3(23.5, 1, 0), Vector3(28, 1, 0), Vector3(33, 1, 0),
			Vector3(39, 1, 0), Vector3(45, 1, 0), Vector3(51, 1, 0), Vector3(58, 1, 0)]
	for i in coins.size():
		b.pickup("umbraxis_s06_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	for s in stones:
		s.vitals = rig.vitals
