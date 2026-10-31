class_name SylvaraLevelS01
extends LevelScene
## S01 — O Jardim Alem do Portal (Sylvara, fase secreta). Visual PROVISORIO.
## Gravidade localizada (baixa) e plataformas que se reorganizam; recompensa: objeto da antiga expedicao, acessorio e moedas.

const DEFINITION: String = "res://game/levels/sylvara/sylvara_s01_definition.tres"


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var soil := Color("3E7A63")
	b.zone(PhysicsLayers.WIND, "low_gravity", Vector3(16.0, 5.0, 0.0), Vector3(50.0, 20.0, 4.0), Color(0.6, 0.4, 1.0, 0.07), Vector3.ZERO, 0.4)
	b.zone(PhysicsLayers.ABYSS, "abyss_garden", Vector3(16.0, -7.0, 0.0), Vector3(50.0, 3.0, 4.0), Color(0.5, 0.0, 0.1, 0.2))
	b.solid(Vector3(0.0, -0.25, 0.0), Vector3(6.0, 0.5, 4.0), soil)
	b.solid(Vector3(5.0, 1.75, 0.0), Vector3(3.0, 0.5, 4.0), soil)
	_rupture(11.0, 3.75, 0.0)
	b.solid(Vector3(15.0, 5.75, 0.0), Vector3(4.0, 0.5, 4.0), soil)
	_rupture(20.0, 3.75, 2.2)
	b.solid(Vector3(25.0, 1.75, 0.0), Vector3(3.0, 0.5, 4.0), soil)
	b.solid(Vector3(31.0, -0.25, 0.0), Vector3(8.0, 0.5, 4.0), soil)
	b.chest("sylvara_s01_chest", Vector3(33.0, 0.6, 0.0))
	b.zone(PhysicsLayers.CHECKPOINT, "sylvara_s01_cp1", Vector3(0.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.2))
	for x in range(-4, 38, 8):
		b.decor(Vector3(float(x), 6.0, -4.0), Vector3(0.7, 12.0, 0.7), Color("5B3A29"))
		b.decor(Vector3(float(x), 12.5, -4.0), Vector3(4.0, 2.5, 4.0), Color("2FA879"), true)
	var coins: Array[Vector3] = [Vector3(5, 2.9, 0), Vector3(15, 6.9, 0), Vector3(25, 2.9, 0), Vector3(30, 0.9, 0)]
	for i in coins.size():
		b.pickup("sylvara_s01_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("sylvara_s01_expedition_relic", Pickup.Kind.ITEM, Vector3(15.0, 7.0, 0.0))
	b.pickup("sylvara_s01_leaf_crown", Pickup.Kind.ITEM, Vector3(16.0, 7.0, 0.0))


func _rupture(x: float, y: float, offset: float) -> void:
	var p := RupturePlatform.new()
	p.position = Vector3(x, y - 0.2, 0.0)
	p.size = Vector3(3.0, 0.4, 3.0)
	p.phase_offset = offset
	p.solid_time = 3.6
	p.gone_time = 1.2
	add_child(p)
