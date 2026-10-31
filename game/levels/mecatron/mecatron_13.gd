class_name MecatronLevel13
extends LevelScene
## FASE 13 — O Porto das Engrenagens (Mecatron). Visual PROVISORIO. Introduz a esteira simples (a favor), a esteira contraria
## (correr contra) e o elevador (alavanca de polaridade sobre a plataforma). Checkpoint depois da esteira simples.
## Segredo: primeiro componente visual TecnoGear.

const DEFINITION: String = "res://game/levels/mecatron/mecatron_13_definition.tres"

var conveyor_with: ConveyorBelt
var conveyor_against: ConveyorBelt
var elevator: PolarityPlatform
var lever: Mechanism


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var steel := Color("4B5563")
	b.solid(Vector3(7.0, -0.5, 0.0), Vector3(14.0, 1.0, 4.0), steel)
	conveyor_with = _belt(Vector3(19.0, -0.2, 0.0), 10.0, 1.0)
	b.solid(Vector3(29.0, -0.5, 0.0), Vector3(10.0, 1.0, 4.0), steel)
	b.zone(PhysicsLayers.CHECKPOINT, "mecatron_13_cp1", Vector3(30.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.95, 0.55, 0.2, 0.25))
	conveyor_against = _belt(Vector3(40.0, -0.2, 0.0), 12.0, -1.0)
	b.solid(Vector3(49.75, -0.5, 0.0), Vector3(7.5, 1.0, 4.0), steel)
	elevator = PolarityPlatform.new()
	elevator.position = Vector3(55.0, -0.2, 0.0)
	elevator.axis = Vector3(0.0, 6.0, 0.0)
	add_child(elevator)
	lever = Mechanism.new()
	lever.mechanism_id = &"mecatron_13_lever"
	lever.toggle = true
	lever.prompt_text = "Pressione E para subir ou descer o elevador"
	lever.position = Vector3(0.0, 0.8, 0.0)
	elevator.add_child(lever)
	elevator.control = lever
	b.solid(Vector3(67.0, 5.5, 0.0), Vector3(20.0, 1.0, 4.0), steel)
	b.zone(PhysicsLayers.ABYSS, "abyss_13", Vector3(40.0, -9.0, 0.0), Vector3(120.0, 3.0, 4.0), Color(0.3, 0.0, 0.0, 0.2))
	b.chest("mecatron_13_chest", Vector3(72.0, 6.1, 0.0))
	for i in 8:
		var g := GearDecor.new()
		g.radius = 1.2 + float(i % 3)
		g.spin_speed = (0.7 if i % 2 == 0 else -0.7)
		g.position = Vector3(float(i) * 10.0, 5.0 + float(i % 4) * 2.0, -5.0)
		add_child(g)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(19, 1, 0), Vector3(27, 1, 0), Vector3(32, 1, 0),
			Vector3(38, 1, 0), Vector3(44, 1, 0), Vector3(49, 1, 0), Vector3(62, 6.9, 0)]
	for i in coins.size():
		b.pickup("mecatron_13_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("mecatron_13_techgear_part", Pickup.Kind.ITEM, Vector3(75.0, 7.0, 0.0))


func _belt(pos: Vector3, length: float, dir: float) -> ConveyorBelt:
	var belt := ConveyorBelt.new()
	belt.size = Vector3(length, 0.4, 4.0)
	belt.direction = dir
	belt.position = pos
	add_child(belt)
	return belt
