class_name CristaliaLevel07
extends LevelScene
## FASE 07 — O Despertar dos Cristais (Cristalia). Visual PROVISORIO. Introduz prismas girateis: girar o prisma (E) desvia o feixe
## para um cristal; o cristal aceso forma uma ponte de luz. Checkpoint depois do primeiro ativador. Segredo: primeiro simbolo Prisma Cosmico.

const DEFINITION: String = "res://game/levels/cristalia/cristalia_07_definition.tres"

var field: BeamField
var prism_a: BeamPrism
var prism_b: BeamPrism


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var rock := Color("4A3F73")
	b.solid(Vector3(7.0, -0.5, 0.0), Vector3(26.0, 1.0, 4.0), rock)
	b.zone(PhysicsLayers.ABYSS, "chasm", Vector3(35.0, -6.0, 0.0), Vector3(40.0, 3.0, 4.0), Color(0.3, 0.0, 0.4, 0.25))
	b.solid(Vector3(35.5, -0.5, 0.0), Vector3(9.0, 1.0, 4.0), rock)
	b.solid(Vector3(65.0, -0.5, 0.0), Vector3(30.0, 1.0, 4.0), rock)
	b.zone(PhysicsLayers.CHECKPOINT, "cristalia_07_cp1", Vector3(33.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.25))
	field = BeamField.new()
	add_child(field)
	field.add_emitter(Vector2i(4, 1), Vector2i(1, 0))
	prism_a = field.add_prism(Vector2i(12, 1), 1)
	field.add_target(Vector2i(12, 6), &"b1")
	field.add_emitter(Vector2i(33, 1), Vector2i(1, 0))
	prism_b = field.add_prism(Vector2i(37, 1), 1)
	field.add_target(Vector2i(37, 6), &"b2")
	_bridge(&"b1", Vector3(26.0, -0.2, 0.0))
	_bridge(&"b2", Vector3(45.0, -0.2, 0.0))
	b.solid(Vector3(39.0, 2.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B5CA5"))
	b.chest("cristalia_07_chest", Vector3(76.0, 0.6, 0.0))
	b.decor(Vector3(45.0, 9.0, -4.0), Vector3(3.0, 18.0, 2.0), Color("A78BFA"), true)
	for x in range(-6, 80, 7):
		b.decor(Vector3(float(x), 2.0, -4.0), Vector3(1.4, 4.0 + float(x % 3), 1.4), Color("7C6BC4"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(14, 1, 0), Vector3(25.5, 1, 0), Vector3(34, 1, 0), Vector3(39, 4.0, 0),
			Vector3(46, 1, 0), Vector3(55, 1, 0), Vector3(62, 1, 0), Vector3(70, 1, 0)]
	for i in coins.size():
		b.pickup("cristalia_07_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("cristalia_07_prism_symbol", Pickup.Kind.ITEM, Vector3(40.0, 4.1, 0.0))


func _bridge(link: StringName, pos: Vector3) -> void:
	var br := LightBridge.new()
	br.link_id = link
	br.size = Vector3(10.0, 0.4, 3.0)
	br.field = field
	br.position = pos
	add_child(br)
