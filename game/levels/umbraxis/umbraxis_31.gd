class_name UmbraxisLevel31
extends LevelScene
## FASE 31 — O Limiar das Raizes (Umbraxis). Visual PROVISORIO. O trio pousa no dominio de Caeldron: tres plataformas dimensionais instaveis
## (transparentes quando somem, com aviso) levam a uma ilha; o checkpoint fica DEPOIS do pouso e do primeiro risco. Zuri alcanca a plataforma
## alta com o primeiro fragmento do Legado Celestial. Raizes colossais e o olho de Caeldron so ao fundo (decoracao).

const DEFINITION: String = "res://game/levels/umbraxis/umbraxis_31_definition.tres"

var platforms: Array[RupturePlatform] = []


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var rock := Color("3A2F55")
	b.solid(Vector3(5.0, -0.5, 0.0), Vector3(22.0, 1.0, 4.0), rock)
	for i in 3:
		var p := RupturePlatform.new()
		p.position = Vector3(19.0 + 4.5 * i, -0.2, 0.0)
		p.phase_offset = 0.0 if i % 2 == 0 else 2.1
		p.solid_time = 3.0
		p.gone_time = 1.2
		add_child(p)
		platforms.append(p)
	b.solid(Vector3(55.5, -0.5, 0.0), Vector3(49.0, 1.0, 4.0), rock)
	b.zone(PhysicsLayers.ABYSS, "rift_31", Vector3(40.0, -6.0, 0.0), Vector3(90.0, 3.0, 4.0), Color(0.5, 0.0, 0.3, 0.2))
	b.zone(PhysicsLayers.CHECKPOINT, "umbraxis_31_cp1", Vector3(35.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.75, 0.24, 0.66, 0.25))
	b.solid(Vector3(41.0, 2.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B4A8F"))
	b.chest("umbraxis_31_chest", Vector3(74.0, 0.6, 0.0))
	b.pickup("umbraxis_31_legacy_fragment", Pickup.Kind.ITEM, Vector3(42.0, 4.1, 0.0))
	# Raizes colossais e o olho de Caeldron ao fundo (decoracao).
	for x in range(-4, 80, 9):
		b.decor(Vector3(float(x), 4.0 + float(x % 4), -5.0), Vector3(2.2, 9.0 + float(x % 4) * 2.0, 2.2), Color("5B1F4F"), true)
	b.decor(Vector3(60.0, 9.0, -8.0), Vector3(6.0, 3.0, 0.6), Color("C03CA8"), true)
	b.decor(Vector3(60.0, 9.0, -7.6), Vector3(1.6, 1.6, 0.4), Color("FFE14A"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(11, 1, 0), Vector3(19, 1, 0), Vector3(28, 1, 0), Vector3(40.5, 4.0, 0),
			Vector3(50, 1, 0), Vector3(58, 1, 0), Vector3(66, 1, 0), Vector3(72, 1, 0)]
	for i in coins.size():
		b.pickup("umbraxis_31_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
