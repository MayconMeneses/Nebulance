class_name SylvaraLevel02
extends LevelScene
## FASE 02 — A Ponte Desaparecida (Sylvara). Visual PROVISORIO. Introduz plataformas de ruptura (solida/intangivel com aviso),
## o Estabilizador (escolha de rota) e o primeiro indicio claro das raizes ligadas a semente. Segredo: plataforma alta (Zuri).

const DEFINITION: String = "res://game/levels/sylvara/sylvara_02_definition.tres"


func _definition_path() -> String:
	return DEFINITION


func _has_astralis() -> bool:
	return false


func _build_geometry(b: SegmentBuilder) -> void:
	var ground := Color("2F5D4A")
	# Area inicial segura, checkpoint imediatamente antes da primeira sequencia longa.
	b.solid(Vector3(5.0, -0.5, 0.0), Vector3(22.0, 1.0, 4.0), ground)
	b.zone(PhysicsLayers.CHECKPOINT, "sylvara_02_cp1", Vector3(14.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.25))
	b.zone(PhysicsLayers.ABYSS, "abyss_bridge", Vector3(56.0, -6.0, 0.0), Vector3(74.0, 3.0, 4.0), Color(0.5, 0.0, 0.1, 0.2))
	# Primeira sequencia: 3 plataformas de ruptura alternadas (introducao legivel do estado solido/intangivel).
	_rupture(b, 19.0, 0.0, &"")
	_rupture(b, 23.5, 2.1, &"")
	_rupture(b, 28.0, 0.0, &"")
	# Ilha central: estabilizador (escolha de rota) e plataforma alta com o segredo.
	b.solid(Vector3(39.0, -0.5, 0.0), Vector3(16.0, 1.0, 4.0), ground)
	b.solid(Vector3(41.0, 2.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("3E7A63"))
	var stabilizer := Mechanism.new()
	stabilizer.mechanism_id = &"sylvara_02_stabilizer"
	stabilizer.link_id = &"bridge_b"
	stabilizer.prompt_text = "Pressione E para estabilizar a ponte"
	stabilizer.position = Vector3(45.5, 0.8, 0.0)
	add_child(stabilizer)
	# Segunda sequencia: so fica solida depois do estabilizador (ou atravesse no tempo).
	for i in 4:
		_rupture(b, 50.5 + 4.5 * i, 0.0 if i % 2 == 0 else 2.1, &"bridge_b")
	b.solid(Vector3(88.0, -0.5, 0.0), Vector3(44.0, 1.0, 4.0), ground)
	b.chest("sylvara_02_chest", Vector3(103.0, 0.6, 0.0))
	# Surpresa: raizes gigantes e brilhantes atravessam o fundo (indicio da conexao com a semente).
	for x in range(30, 80, 10):
		b.decor(Vector3(float(x), 3.0, -3.5), Vector3(1.2, 9.0, 1.2), Color("5B2A4A"), true)
		b.decor(Vector3(float(x) + 5.0, 6.0, -3.5), Vector3(10.0, 0.8, 0.8), Color("C03CA8"), true)
	for x in range(-6, 110, 7):
		b.tree(float(x), 3.5 + float(x % 3))
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(11, 1, 0), Vector3(19, 1, 0), Vector3(28, 1, 0),
			Vector3(32, 1, 0), Vector3(40.5, 4.0, 0), Vector3(55, 1, 0), Vector3(64, 1, 0), Vector3(90, 1, 0)]
	for i in coins.size():
		b.pickup("sylvara_02_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("sylvara_02_vine_charm", Pickup.Kind.ITEM, Vector3(42.0, 4.1, 0.0))
	b.pickup("memory_roots_clue_02", Pickup.Kind.MEMORY, Vector3(43.0, 4.1, 0.0))


func _rupture(b: SegmentBuilder, x: float, offset: float, link: StringName) -> RupturePlatform:
	var p := RupturePlatform.new()
	p.position = Vector3(x, -0.2, 0.0)
	p.phase_offset = offset
	p.link_id = link
	p.solid_time = 3.0
	p.gone_time = 1.2
	b.parent.add_child(p)
	return p
