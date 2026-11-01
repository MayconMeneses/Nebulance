class_name AquarysLevelS04
extends LevelScene
## S04 — Oceano Esquecido (Aquarys, fase secreta). Visual PROVISORIO. Instalacao subaquatica compacta da antiga expedicao: uma comporta ergue a
## mare para as plataformas flutuantes alcancarem o outro lado, e degraus de metal levam a sala do bau. Recompensa: moedas, o acessorio
## da expedicao e a gravacao da antiga expedicao.

const DEFINITION: String = "res://game/levels/aquarys/aquarys_s04_definition.tres"

var water: WaterBody
var raise_control: SluiceControl
var floaters: Array[FloatingPlatform] = []


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var hull := Color("33556B")
	b.solid(Vector3(8.0, -0.5, 0.0), Vector3(16.0, 1.0, 4.0), hull)
	water = WaterBody.new()
	water.surface_size = Vector2(40.0, 3.4)
	water.position = Vector3(26.0, 0.0, 0.0)
	add_child(water)
	for cx in [18.0, 22.0, 26.0]:
		var f := FloatingPlatform.new()
		f.water = water
		f.offset = -0.2
		f.position = Vector3(cx, 0.0, 0.0)
		add_child(f)
		floaters.append(f)
	raise_control = SluiceControl.new()
	raise_control.water = water
	raise_control.target_level = 2
	raise_control.prompt_text = "Pressione E para subir a mare"
	raise_control.position = Vector3(10.0, 0.8, 0.0)
	add_child(raise_control)
	b.solid(Vector3(44.0, -0.5, 0.0), Vector3(32.0, 1.0, 4.0), hull)
	b.zone(PhysicsLayers.ABYSS, "sea_s04", Vector3(22.0, -7.0, 0.0), Vector3(14.0, 3.0, 4.0), Color(0.0, 0.2, 0.4, 0.3))
	b.solid(Vector3(49.0, 0.75, 0.0), Vector3(4.0, 0.5, 4.0), Color("5E8FA8"))
	b.solid(Vector3(55.0, 1.75, 0.0), Vector3(4.0, 0.5, 4.0), Color("5E8FA8"))
	b.solid(Vector3(63.0, 1.75, 0.0), Vector3(8.0, 0.5, 4.0), Color("5E8FA8"))
	b.chest("aquarys_s04_chest", Vector3(62.0, 2.6, 0.0))
	b.pickup("aquarys_s04_expedition_badge", Pickup.Kind.ITEM, Vector3(65.0, 3.0, 0.0))
	b.pickup("memory_old_expedition_recording_s04", Pickup.Kind.MEMORY, Vector3(66.2, 3.0, 0.0))
	# Decoracao aquatica: algas altas, janelas de observacao e um periscopio quebrado.
	for x in range(-2, 70, 6):
		b.decor(Vector3(float(x), 3.0, -4.0), Vector3(0.7, 6.0 + float(x % 3), 0.7), Color("2FD2B0"), true)
	for x in range(6, 64, 14):
		b.decor(Vector3(float(x), 4.5, -2.6), Vector3(3.0, 2.0, 0.2), Color("23CFF5"), true)
	b.decor(Vector3(40.0, 5.5, -3.0), Vector3(0.6, 5.0, 0.6), Color("6B7280"))
	var coins: Array[Vector3] = [Vector3(4, 1, 0), Vector3(12, 1, 0), Vector3(18, 1, 0), Vector3(26, 1, 0), Vector3(36, 1, 0),
			Vector3(44, 1, 0), Vector3(49, 2.2, 0), Vector3(55, 3.2, 0), Vector3(60, 3.2, 0)]
	for i in coins.size():
		b.pickup("aquarys_s04_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
