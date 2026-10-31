class_name MecatronLevelS03
extends LevelScene
## S03 — Oficina Zero (Mecatron, fase secreta). Visual PROVISORIO. Maquinas de laboratorio e polaridade em espaco compacto: um elevador e um
## trilho levam a bancada do bau. Recompensa: acessorio tecnologico, moedas e o registro da manutencao da Astralis.

const DEFINITION: String = "res://game/levels/mecatron/mecatron_s03_definition.tres"

var lift: PolarityPlatform
var rail: PolarityPlatform


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var steel := Color("3F4752")
	b.solid(Vector3(7.25, -0.5, 0.0), Vector3(14.5, 1.0, 4.0), steel)
	lift = _platform(Vector3(16.0, -0.2, 0.0), Vector3(0.0, 4.0, 0.0), &"mecatron_s03_lever_lift")
	b.solid(Vector3(21.25, 3.5, 0.0), Vector3(7.5, 1.0, 4.0), steel)
	rail = _platform(Vector3(26.5, 3.8, 0.0), Vector3(6.0, 0.0, 0.0), &"mecatron_s03_lever_rail")
	b.solid(Vector3(39.0, 3.5, 0.0), Vector3(10.0, 1.0, 4.0), steel)
	b.zone(PhysicsLayers.ABYSS, "abyss_s03", Vector3(25.0, -9.0, 0.0), Vector3(70.0, 3.0, 4.0), Color(0.3, 0.0, 0.0, 0.2))
	b.chest("mecatron_s03_chest", Vector3(42.0, 4.6, 0.0))
	b.pickup("mecatron_s03_tech_accessory", Pickup.Kind.ITEM, Vector3(37.5, 5.1, 0.0))
	b.pickup("memory_astralis_maintenance_s03", Pickup.Kind.MEMORY, Vector3(39.5, 5.0, 0.0))
	for i in 6:
		var g := GearDecor.new()
		g.radius = 1.0 + float(i % 3)
		g.spin_speed = 0.6 if i % 2 == 0 else -0.6
		g.position = Vector3(float(i) * 9.0, 6.0 + float(i % 3) * 2.0, -5.0)
		add_child(g)
	var coins: Array[Vector3] = [Vector3(8, 1, 0), Vector3(20, 5.0, 0), Vector3(24, 5.0, 0), Vector3(35, 5.0, 0)]
	for i in coins.size():
		b.pickup("mecatron_s03_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


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
