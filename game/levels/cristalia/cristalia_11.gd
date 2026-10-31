class_name CristaliaLevel11
extends LevelScene
## FASE 11 — A Catedral Prismatica (Cristalia). Visual PROVISORIO. Puzzle composto: a luz abre a parede do corredor (prisma), uma torre
## vertical exige a escalada de Zuri e, no alto, dois mecanismos SINCRONIZADOS (ativos ao mesmo tempo, 6 s cada) abrem o salao do arquivo
## da expedicao (a memoria confirma a participacao da Astralis). Checkpoint antes da sequencia final.

const DEFINITION: String = "res://game/levels/cristalia/cristalia_11_definition.tres"

var field: BeamField
var prism: BeamPrism
var wall: LightBridge
var mech_a: Mechanism
var mech_b: Mechanism
var sync_gate: MechanismGate


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var rock := Color("4A3F73")
	b.solid(Vector3(42.0, -0.5, 0.0), Vector3(96.0, 1.0, 4.0), rock)
	# Parte 1: a luz abre a parede.
	field = BeamField.new()
	add_child(field)
	field.add_emitter(Vector2i(3, 1), Vector2i(1, 0))
	prism = field.add_prism(Vector2i(10, 1), 1)
	field.add_target(Vector2i(10, 5), &"hall")
	wall = LightBridge.new()
	wall.link_id = &"hall"
	wall.opens_when_lit = true
	wall.size = Vector3(1.5, 6.0, 3.0)
	wall.field = field
	wall.position = Vector3(22.0, 3.0, 0.0)
	add_child(wall)
	# Parte 2: torre vertical (so se passa por cima, escalando).
	b.zone(PhysicsLayers.CHECKPOINT, "cristalia_11_cp1", Vector3(36.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.25))
	b.solid(Vector3(51.0, 2.5, 0.0), Vector3(22.0, 5.0, 4.0), Color("6B5CA5"))
	b.zone(PhysicsLayers.CLIMBABLE, "climb_11", Vector3(39.4, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	# Parte 3: mecanismos sincronizados e salao do arquivo.
	mech_a = _sync(&"cristalia_11_sync_a", Vector3(43.0, 5.8, 0.0))
	mech_b = _sync(&"cristalia_11_sync_b", Vector3(51.0, 5.8, 0.0))
	sync_gate = MechanismGate.new()
	sync_gate.link_id = &"sync"
	sync_gate.size = Vector3(0.8, 3.0, 3.0)
	sync_gate.position = Vector3(55.0, 6.5, 0.0)
	add_child(sync_gate)
	b.pickup("memory_astralis_expedition_11", Pickup.Kind.MEMORY, Vector3(58.0, 6.0, 0.0))
	b.chest("cristalia_11_chest", Vector3(60.5, 5.6, 0.0))
	b.decor(Vector3(50.0, 12.0, -4.0), Vector3(4.0, 24.0, 2.0), Color("A78BFA"), true)
	for x in range(-6, 90, 7):
		b.decor(Vector3(float(x), 2.0, -4.0), Vector3(1.4, 4.0 + float(x % 3), 1.4), Color("7C6BC4"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(14, 1, 0), Vector3(28, 1, 0), Vector3(34, 1, 0), Vector3(45, 6.2, 0),
			Vector3(47, 6.2, 0), Vector3(49, 6.2, 0), Vector3(53, 6.2, 0), Vector3(57, 6.2, 0)]
	for i in coins.size():
		b.pickup("cristalia_11_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _sync(id: StringName, pos: Vector3) -> Mechanism:
	var m := Mechanism.new()
	m.mechanism_id = id
	m.link_id = &"sync"
	m.hold_time = 6.0
	m.prompt_text = "Pressione E (ative os dois ao mesmo tempo)"
	m.position = pos
	add_child(m)
	return m
