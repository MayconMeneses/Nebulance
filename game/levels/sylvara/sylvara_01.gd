class_name SylvaraLevel01
extends LevelScene
## FASE 01 — O Primeiro Passo (Sylvara). Visual PROVISORIO (graybox colorido); IDs e regras sao os finais.
## Beats: aprender corrida/salto -> ponte -> barreira de impacto (Rocco) -> checkpoint -> muro (Zuri)
## -> desvio com vento (Pipa, segredo) -> criatura contaminada -> torre dos exploradores -> bau.

const DEFINITION: String = "res://game/levels/sylvara/sylvara_01_definition.tres"


func _definition_path() -> String:
	return DEFINITION


func _has_astralis() -> bool:
	return true


func _build_geometry(b: SegmentBuilder) -> void:
	var ground := Color("2F5D4A")
	var wood := Color("6B4A33")
	# A: desembarque e ensino de corrida/salto (area segura).
	b.solid(Vector3(7.0, -0.5, 0.0), Vector3(30.0, 1.0, 4.0), ground)
	b.solid(Vector3(10.0, 0.4, 0.0), Vector3(2.0, 0.8, 4.0), ground)
	# B: ponte simples com uma tabua faltando (abismo embaixo).
	b.solid(Vector3(24.5, -0.15, 0.0), Vector3(5.0, 0.3, 4.0), wood)
	b.solid(Vector3(31.75, -0.15, 0.0), Vector3(4.5, 0.3, 4.0), wood)
	b.zone(PhysicsLayers.ABYSS, "abyss_bridge", Vector3(28.0, -5.0, 0.0), Vector3(16.0, 3.0, 4.0), Color(0.5, 0.0, 0.1, 0.25))
	# C: resto da fase em piso continuo.
	b.solid(Vector3(72.0, -0.5, 0.0), Vector3(76.0, 1.0, 4.0), ground)
	b.barrier(Vector3(40.0, 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	b.zone(PhysicsLayers.CHECKPOINT, "sylvara_01_cp1", Vector3(44.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.25))
	# D: muro alto (so Zuri alcanca) e plataforma secreta com vento (Pipa).
	b.solid(Vector3(54.0, 1.5, 0.0), Vector3(4.0, 3.0, 4.0), Color("3E7A63"))
	b.solid(Vector3(68.0, 2.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("3E7A63"))
	b.zone(PhysicsLayers.WIND, "wind_01", Vector3(60.5, 6.0, 0.0), Vector3(9.0, 12.0, 3.0), Color(0.7, 0.9, 1.0, 0.15), Vector3(0.0, 23.0, 0.0))
	# E: criatura contaminada, torre dos exploradores (surpresa) e bau final.
	b.enemy(Vector3(76.0, 0.45, 0.0), 76.0, 86.0)
	b.decor(Vector3(94.0, 5.0, -2.5), Vector3(3.0, 10.0, 2.0), Color("52368A"), true)
	b.decor(Vector3(94.0, 3.5, -1.4), Vector3(1.4, 1.4, 0.1), Color("23CFF5"), true)
	b.chest("sylvara_01_chest", Vector3(102.0, 0.6, 0.0))
	for x in range(-6, 110, 6):
		b.tree(float(x), 3.5 + float(x % 4))
	# Coletaveis (IDs autorados; devem bater com a definicao).
	var coin_positions: Array[Vector3] = [Vector3(4, 1, 0), Vector3(10, 1.9, 0), Vector3(16, 1, 0),
			Vector3(24.5, 1, 0), Vector3(31.5, 1, 0), Vector3(54, 4.0, 0), Vector3(66, 4.0, 0),
			Vector3(68, 4.0, 0), Vector3(88, 1, 0)]
	for i in coin_positions.size():
		b.pickup("sylvara_01_coin_%02d" % (i + 1), Pickup.Kind.COIN, coin_positions[i])
	b.pickup("sylvara_01_glow_scarf", Pickup.Kind.ITEM, Vector3(69.6, 4.1, 0.0))
	b.pickup("archive_symbol_sylvara_01", Pickup.Kind.MEMORY, Vector3(70.4, 4.1, 0.0))
