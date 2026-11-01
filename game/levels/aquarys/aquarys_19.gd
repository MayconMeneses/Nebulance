class_name AquarysLevel19
extends LevelScene
## FASE 19 — A Costa das Luzes (Aquarys). Visual PROVISORIO. Introducao segura as mares: a comporta ALTA ergue as plataformas flutuantes
## ate a altura da praia; depois da primeira comporta (checkpoint) a comporta BAIXA expoe a passarela do vao seguinte. Sem fisica de fluidos:
## o nivel e discreto. Segredo: primeiro acessorio Mare Estelar.

const DEFINITION: String = "res://game/levels/aquarys/aquarys_19_definition.tres"

var water: WaterBody
var raise_control: SluiceControl
var lower_control: SluiceControl
var walkway: TideWalkway
var floaters: Array[FloatingPlatform] = []


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var sand := Color("C9B98A")
	b.solid(Vector3(8.0, -0.5, 0.0), Vector3(16.0, 1.0, 4.0), sand)
	water = WaterBody.new()
	water.surface_size = Vector2(44.0, 3.4)
	water.position = Vector3(38.0, 0.0, 0.0)
	add_child(water)
	for cx in [18.0, 22.0, 26.0]:
		var f := FloatingPlatform.new()
		f.water = water
		f.offset = -0.2
		f.position = Vector3(cx, 0.0, 0.0)
		add_child(f)
		floaters.append(f)
	b.solid(Vector3(37.0, -0.5, 0.0), Vector3(18.0, 1.0, 4.0), sand)
	b.zone(PhysicsLayers.CHECKPOINT, "aquarys_19_cp1", Vector3(30.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.14, 0.81, 0.96, 0.25))
	raise_control = _control(14.0, 2)
	lower_control = _control(35.0, 0)
	walkway = TideWalkway.new()
	walkway.water = water
	walkway.size = Vector3(14.0, 0.4, 3.0)
	walkway.position = Vector3(53.0, -0.2, 0.0)
	add_child(walkway)
	b.solid(Vector3(70.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), sand)
	b.zone(PhysicsLayers.ABYSS, "sea_19", Vector3(38.0, -7.0, 0.0), Vector3(90.0, 3.0, 4.0), Color(0.0, 0.2, 0.4, 0.3))
	b.chest("aquarys_19_chest", Vector3(76.0, 0.6, 0.0))
	for x in range(-4, 80, 8):
		b.decor(Vector3(float(x), 2.5, -4.0), Vector3(0.6, 5.0, 0.6), Color("7FE9F5"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(18, 1, 0), Vector3(24, 1, 0), Vector3(33, 1, 0),
			Vector3(40, 1, 0), Vector3(53, 1, 0), Vector3(64, 1, 0), Vector3(72, 1, 0)]
	for i in coins.size():
		b.pickup("aquarys_19_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("aquarys_19_star_tide", Pickup.Kind.ITEM, Vector3(68.0, 1.0, 0.0))


func _control(x: float, level: int) -> SluiceControl:
	var c := SluiceControl.new()
	c.water = water
	c.target_level = level
	c.prompt_text = "Pressione E para %s a mare" % ("subir" if level > 0 else "baixar")
	c.position = Vector3(x, 0.8, 0.0)
	add_child(c)
	return c
