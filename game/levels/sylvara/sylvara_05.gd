class_name SylvaraLevel05
extends LevelScene
## FASE 05 — A Torre Esquecida (Sylvara). Visual PROVISORIO. Combina os tres poderes em sequencia (Rocco abre a barreira,
## Zuri escala o muro da torre, Pipa planeia pelo vao com vento) e termina numa ponte de plataformas de ruptura.
## Holograma da Astralis na expedicao anterior (memoria). Checkpoint antes da sequencia dos tres poderes.

const DEFINITION: String = "res://game/levels/sylvara/sylvara_05_definition.tres"


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var ground := Color("2F5D4A")
	b.solid(Vector3(23.0, -0.5, 0.0), Vector3(58.0, 1.0, 4.0), ground)
	b.zone(PhysicsLayers.CHECKPOINT, "sylvara_05_cp1", Vector3(20.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.25))
	b.barrier(Vector3(26.0, 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	# Torre: bloco de 5 m (so se passa por cima, escalando a face marcada).
	b.solid(Vector3(40.0, 2.5, 0.0), Vector3(12.0, 5.0, 4.0), Color("3E7A63"))
	b.zone(PhysicsLayers.CLIMBABLE, "climb_05", Vector3(33.4, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	# Vao de 9 m com corrente de vento (planeio de Pipa).
	b.zone(PhysicsLayers.ABYSS, "abyss_gap", Vector3(56.5, -6.0, 0.0), Vector3(9.0, 3.0, 4.0), Color(0.5, 0.0, 0.1, 0.25))
	b.zone(PhysicsLayers.WIND, "wind_05", Vector3(56.5, 6.0, 0.0), Vector3(9.0, 12.0, 3.0), Color(0.7, 0.9, 1.0, 0.15), Vector3(0.0, 23.0, 0.0))
	b.solid(Vector3(68.5, -0.5, 0.0), Vector3(15.0, 1.0, 4.0), ground)
	# Holograma (memoria) com a Astralis na expedicao anterior.
	b.decor(Vector3(70.0, 1.2, 0.0), Vector3(0.9, 1.6, 0.1), Color("23CFF5"), true)
	b.pickup("memory_tower_hologram_05", Pickup.Kind.MEMORY, Vector3(70.0, 1.2, 0.0))
	# Ponte final de plataformas de ruptura.
	b.zone(PhysicsLayers.ABYSS, "abyss_bridge", Vector3(83.5, -6.0, 0.0), Vector3(15.0, 3.0, 4.0), Color(0.5, 0.0, 0.1, 0.25))
	for i in 3:
		var p := RupturePlatform.new()
		p.position = Vector3(79.0 + 4.5 * i, -0.2, 0.0)
		p.phase_offset = 0.0 if i % 2 == 0 else 2.1
		p.solid_time = 3.0
		p.gone_time = 1.2
		add_child(p)
	b.solid(Vector3(101.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), ground)
	b.chest("sylvara_05_chest", Vector3(106.0, 0.6, 0.0))
	b.decor(Vector3(60.0, 9.0, -3.5), Vector3(3.0, 18.0, 2.0), Color("52368A"), true)
	for x in range(-6, 110, 6):
		b.tree(float(x), 3.5 + float(x % 4))
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(22, 1, 0), Vector3(31, 1, 0), Vector3(41, 6.2, 0),
			Vector3(49, 1, 0), Vector3(66, 1, 0), Vector3(75, 1, 0), Vector3(96, 1, 0)]
	for i in coins.size():
		b.pickup("sylvara_05_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
