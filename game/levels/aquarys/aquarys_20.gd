class_name AquarysLevel20
extends LevelScene
## FASE 20 — Os Canais Suspensos (Aquarys). Visual PROVISORIO. A comporta ALTA ergue as plataformas ate o patamar central (checkpoint);
## ali, antes da escolha de nivel, Zuri escala ao coletavel atras da comporta e Rocco quebra a barreira marcada; a comporta BAIXA expoe a
## passarela que antes estava submersa e leva ao bau. Combinar o trio e escolher o nivel certo na hora certa.

const DEFINITION: String = "res://game/levels/aquarys/aquarys_20_definition.tres"

var water: WaterBody
var raise_control: SluiceControl
var lower_control: SluiceControl
var walkway: TideWalkway
var barrier: ImpactBarrier


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var stone := Color("5B7C99")
	b.solid(Vector3(7.0, -0.5, 0.0), Vector3(14.0, 1.0, 4.0), stone)
	water = WaterBody.new()
	water.surface_size = Vector2(56.0, 3.4)
	water.position = Vector3(36.0, 0.0, 0.0)
	add_child(water)
	for cx in [16.0, 20.0, 24.0]:
		var f := FloatingPlatform.new()
		f.water = water
		f.offset = -0.2
		f.position = Vector3(cx, 0.0, 0.0)
		add_child(f)
	b.solid(Vector3(33.0, -0.5, 0.0), Vector3(14.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.CHECKPOINT, "aquarys_20_cp1", Vector3(28.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.14, 0.81, 0.96, 0.25))
	b.zone(PhysicsLayers.CLIMBABLE, "climb_20", Vector3(33.0, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(36.6, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("7FA6C4"))
	barrier = b.barrier(Vector3(39.4, 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	raise_control = _control(12.0, 2)
	lower_control = _control(36.0, 0)
	walkway = TideWalkway.new()
	walkway.water = water
	walkway.size = Vector3(12.0, 0.4, 3.0)
	walkway.position = Vector3(46.0, -0.2, 0.0)
	add_child(walkway)
	b.solid(Vector3(61.0, -0.5, 0.0), Vector3(18.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.ABYSS, "sea_20", Vector3(36.0, -7.0, 0.0), Vector3(90.0, 3.0, 4.0), Color(0.0, 0.2, 0.4, 0.3))
	b.chest("aquarys_20_chest", Vector3(66.0, 0.6, 0.0))
	for x in range(-4, 70, 8):
		b.decor(Vector3(float(x), 2.5, -4.0), Vector3(0.6, 5.0, 0.6), Color("7FE9F5"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(10, 1, 0), Vector3(16, 1, 0), Vector3(22, 1, 0), Vector3(30, 1, 0),
			Vector3(35, 1, 0), Vector3(46, 1, 0), Vector3(56, 1, 0), Vector3(62, 1, 0)]
	for i in coins.size():
		b.pickup("aquarys_20_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("aquarys_20_gate_collectible", Pickup.Kind.ITEM, Vector3(37.0, 6.1, 0.0))


func _control(x: float, level: int) -> SluiceControl:
	var c := SluiceControl.new()
	c.water = water
	c.target_level = level
	c.prompt_text = "Pressione E para %s a mare" % ("subir" if level > 0 else "baixar")
	c.position = Vector3(x, 0.8, 0.0)
	add_child(c)
	return c
