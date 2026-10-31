class_name MecatronLevel17
extends LevelScene
## FASE 17 — A Forja Autonoma (Mecatron). Visual PROVISORIO. Combina esteira, prensas, elevadores de polaridade e esteira contraria rapida.
## Alavanca escondida no alto (Zuri escala) abre o portal para a S03 (Oficina Zero). Checkpoint antes da central de energia.
## Descoberta: o arquivo parcial da expedicao anterior, no fim.

const DEFINITION: String = "res://game/levels/mecatron/mecatron_17_definition.tres"

var presses: Array[HydraulicPress] = []
var lift_up: PolarityPlatform
var lift_down: PolarityPlatform
var belt: ConveyorBelt
var lever_belt: Mechanism
var secret_lever: Mechanism
var portal: Portal


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var steel := Color("4B5563")
	b.solid(Vector3(15.0, -0.5, 0.0), Vector3(30.0, 1.0, 4.0), steel)
	b.zone(PhysicsLayers.CLIMBABLE, "climb_17", Vector3(11.0, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(14.6, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B7280"))
	secret_lever = Mechanism.new()
	secret_lever.mechanism_id = &"mecatron_17_secret_lever"
	secret_lever.prompt_text = "Pressione E para ligar o painel escondido"
	secret_lever.position = Vector3(15.0, 5.8, 0.0)
	add_child(secret_lever)
	_belt(Vector3(34.0, -0.2, 0.0), 8.0, 1.0)
	b.solid(Vector3(45.0, -0.5, 0.0), Vector3(14.0, 1.0, 4.0), steel)
	_press(44.0, 0.0, b)
	b.zone(PhysicsLayers.CHECKPOINT, "mecatron_17_cp1", Vector3(50.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.95, 0.55, 0.2, 0.25))
	lift_up = _lift(Vector3(53.5, -0.2, 0.0), Vector3(0.0, 4.0, 0.0), &"mecatron_17_lever_up")
	b.solid(Vector3(62.5, 3.5, 0.0), Vector3(15.0, 1.0, 4.0), steel)
	_press(62.0, 1.3, b, 4.0)
	lift_down = _lift(Vector3(71.5, 3.8, 0.0), Vector3(0.0, -4.0, 0.0), &"mecatron_17_lever_down")
	b.solid(Vector3(91.5, -0.5, 0.0), Vector3(37.0, 1.0, 4.0), steel)
	lever_belt = Mechanism.new()
	lever_belt.mechanism_id = &"mecatron_17_lever_belt"
	lever_belt.toggle = true
	lever_belt.prompt_text = "Pressione E para inverter a esteira"
	lever_belt.position = Vector3(74.5, 0.8, 0.0)
	add_child(lever_belt)
	belt = _belt(Vector3(82.0, -0.2, 0.0), 12.0, -1.0)
	belt.speed = 6.0
	belt.control = lever_belt
	b.zone(PhysicsLayers.ABYSS, "abyss_17", Vector3(55.0, -9.0, 0.0), Vector3(140.0, 3.0, 4.0), Color(0.3, 0.0, 0.0, 0.2))
	b.chest("mecatron_17_chest", Vector3(96.0, 0.6, 0.0))
	b.pickup("memory_failed_expedition_17", Pickup.Kind.MEMORY, Vector3(100.5, 1.0, 0.0))
	portal = Portal.new()
	portal.portal_id = &"mecatron_17_portal"
	portal.destination_level_id = &"mecatron_s03"
	portal.requires_open = true
	portal.position = Vector3(104.0, 1.2, 0.0)
	add_child(portal)
	for i in 11:
		var g := GearDecor.new()
		g.radius = 1.2 + float(i % 3)
		g.spin_speed = 0.5 if i % 2 == 0 else -0.5
		g.position = Vector3(float(i) * 10.0, 8.0 + float(i % 3) * 2.0, -5.0)
		add_child(g)
	var coins: Array[Vector3] = [Vector3(8, 1, 0), Vector3(24, 1, 0), Vector3(34, 1, 0), Vector3(41, 1, 0), Vector3(50, 1, 0),
			Vector3(59, 4.9, 0), Vector3(66, 4.9, 0), Vector3(80, 1, 0), Vector3(92, 1, 0)]
	for i in coins.size():
		b.pickup("mecatron_17_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("mecatron_17_forge_core", Pickup.Kind.ITEM, Vector3(56.5, 5.1, 0.0))


func _after_setup() -> void:
	secret_lever.activated.connect(func(_m: Mechanism) -> void: portal.open())


func _belt(pos: Vector3, length: float, dir: float) -> ConveyorBelt:
	var belt_node := ConveyorBelt.new()
	belt_node.size = Vector3(length, 0.4, 4.0)
	belt_node.direction = dir
	belt_node.position = pos
	add_child(belt_node)
	return belt_node


func _press(x: float, phase: float, b: SegmentBuilder, base_y: float = 0.0) -> void:
	var press := HydraulicPress.new()
	press.position = Vector3(x, base_y, 0.0)
	press.phase = phase
	add_child(press)
	presses.append(press)
	b.decor(Vector3(x, base_y + 6.0, -1.8), Vector3(4.0, 0.6, 0.6), Color("6B7280"))


func _lift(pos: Vector3, axis: Vector3, lever_id: StringName) -> PolarityPlatform:
	var p := PolarityPlatform.new()
	p.position = pos
	p.axis = axis
	add_child(p)
	var lever := Mechanism.new()
	lever.mechanism_id = lever_id
	lever.toggle = true
	lever.prompt_text = "Pressione E para inverter a polaridade"
	lever.position = Vector3(0.0, 0.8, 0.0)
	p.add_child(lever)
	p.control = lever
	return p
