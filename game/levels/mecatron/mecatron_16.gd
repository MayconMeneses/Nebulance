class_name MecatronLevel16
extends LevelScene
## FASE 16 — O Labirinto Magnetico (Mecatron). Visual PROVISORIO. Alavancas de polaridade (E, alternam) sobre as plataformas: um elevador
## que sobe, um trilho horizontal que atravessa um vao e um elevador que desce. No fim, uma esteira rapida contraria so cede quando a
## alavanca do chao inverte o sentido. Checkpoint antes do puzzle composto. O trilho antigo termina num beco com a pista da Oficina Zero.

const DEFINITION: String = "res://game/levels/mecatron/mecatron_16_definition.tres"

var lift_up: PolarityPlatform
var rail: PolarityPlatform
var lift_down: PolarityPlatform
var belt: ConveyorBelt
var lever_belt: Mechanism


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var steel := Color("4B5563")
	b.solid(Vector3(8.25, -0.5, 0.0), Vector3(16.5, 1.0, 4.0), steel)
	lift_up = _platform(Vector3(18.0, -0.2, 0.0), Vector3(0.0, 5.0, 0.0), &"mecatron_16_lever_up")
	b.solid(Vector3(24.25, 4.5, 0.0), Vector3(9.5, 1.0, 4.0), steel)
	rail = _platform(Vector3(30.5, 4.8, 0.0), Vector3(7.0, 0.0, 0.0), &"mecatron_16_lever_rail")
	b.solid(Vector3(45.0, 4.5, 0.0), Vector3(12.0, 1.0, 4.0), steel)
	b.zone(PhysicsLayers.CHECKPOINT, "mecatron_16_cp1", Vector3(41.0, 7.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.95, 0.55, 0.2, 0.25))
	lift_down = _platform(Vector3(52.5, 4.8, 0.0), Vector3(0.0, -5.0, 0.0), &"mecatron_16_lever_down")
	b.solid(Vector3(72.0, -0.5, 0.0), Vector3(36.0, 1.0, 4.0), steel)
	lever_belt = Mechanism.new()
	lever_belt.mechanism_id = &"mecatron_16_lever_belt"
	lever_belt.toggle = true
	lever_belt.prompt_text = "Pressione E para inverter a esteira"
	lever_belt.position = Vector3(56.0, 0.8, 0.0)
	add_child(lever_belt)
	belt = ConveyorBelt.new()
	belt.size = Vector3(14.0, 0.4, 4.0)
	belt.speed = 6.0
	belt.direction = -1.0
	belt.position = Vector3(65.0, -0.2, 0.0)
	belt.control = lever_belt
	add_child(belt)
	b.zone(PhysicsLayers.ABYSS, "abyss_16", Vector3(40.0, -9.0, 0.0), Vector3(120.0, 3.0, 4.0), Color(0.3, 0.0, 0.0, 0.2))
	b.chest("mecatron_16_chest", Vector3(76.0, 0.6, 0.0))
	b.decor(Vector3(90.5, 3.0, 0.0), Vector3(1.0, 6.0, 4.0), Color("2A2F3A"))
	b.decor(Vector3(84.0, 0.1, -1.5), Vector3(12.0, 0.2, 0.4), Color("F08A3B"), true)
	b.pickup("memory_workshop_clue_16", Pickup.Kind.MEMORY, Vector3(88.0, 1.0, 0.0))
	for i in 9:
		var g := GearDecor.new()
		g.radius = 1.2 + float(i % 3)
		g.spin_speed = 0.5 if i % 2 == 0 else -0.5
		g.position = Vector3(float(i) * 10.0, 8.0 + float(i % 3) * 2.0, -5.0)
		add_child(g)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(23, 6, 0), Vector3(43, 6, 0), Vector3(47, 6, 0),
			Vector3(62, 1, 0), Vector3(70, 1, 0), Vector3(74, 1, 0), Vector3(80, 1, 0)]
	for i in coins.size():
		b.pickup("mecatron_16_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("mecatron_16_magnet_charm", Pickup.Kind.ITEM, Vector3(21.5, 6.1, 0.0))


func _platform(pos: Vector3, axis: Vector3, lever_id: StringName) -> PolarityPlatform:
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
