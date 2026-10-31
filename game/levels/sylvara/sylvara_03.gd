class_name SylvaraLevel03
extends LevelScene
## FASE 03 — Segredos da Floresta (Sylvara). Visual PROVISORIO. Rota principal: barreira (Rocco) -> bau.
## Desafio vertical OPCIONAL com tres mecanismos antigos (Rocco abre o nicho, Zuri escala, Pipa planeia ate o simbolo no alto);
## ativados os tres, o portao da arvore abre e libera o portal para S01 (O Jardim Alem do Portal).

const DEFINITION: String = "res://game/levels/sylvara/sylvara_03_definition.tres"


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var ground := Color("2F5D4A")
	b.solid(Vector3(47.0, -0.5, 0.0), Vector3(106.0, 1.0, 4.0), ground)
	b.zone(PhysicsLayers.CHECKPOINT, "sylvara_03_cp1", Vector3(16.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.25))
	# Mecanismo 1 (Rocco): atras da barreira de impacto.
	b.barrier(Vector3(29.0, 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	_mechanism(&"sylvara_03_m1", Vector3(31.5, 0.8, 0.0))
	# Mecanismo 2 (Zuri): no alto, depois de escalar a superficie marcada.
	b.zone(PhysicsLayers.CLIMBABLE, "climb_03", Vector3(39.4, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(43.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("3E7A63"))
	_mechanism(&"sylvara_03_m2", Vector3(44.5, 5.8, 0.0))
	# Mecanismo 3 (Pipa): simbolo no alto, alem do vao com vento.
	b.zone(PhysicsLayers.WIND, "wind_03", Vector3(50.5, 8.0, 0.0), Vector3(9.0, 12.0, 3.0), Color(0.7, 0.9, 1.0, 0.15), Vector3(0.0, 23.0, 0.0))
	b.solid(Vector3(58.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("3E7A63"))
	_mechanism(&"sylvara_03_m3", Vector3(56.5, 5.8, 0.0))
	var gate := MechanismGate.new()
	gate.link_id = &"forest_a"
	gate.position = Vector3(59.3, 6.5, 0.0)
	gate.size = Vector3(0.8, 3.0, 3.0)
	add_child(gate)
	var portal := Portal.new()
	portal.portal_id = &"sylvara_03_portal"
	portal.destination_level_id = &"sylvara_s01"
	portal.requires_open = true
	portal.position = Vector3(60.4, 6.2, 0.0)
	add_child(portal)
	gate.opened.connect(portal.open)
	b.chest("sylvara_03_chest", Vector3(98.0, 0.6, 0.0))
	for x in range(-6, 104, 6):
		b.tree(float(x), 3.5 + float(x % 4))
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(25, 1, 0), Vector3(32.2, 1, 0), Vector3(43, 6.2, 0),
			Vector3(57, 6.2, 0), Vector3(75, 1, 0), Vector3(85, 1, 0), Vector3(92, 1, 0)]
	for i in coins.size():
		b.pickup("sylvara_03_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("memory_portal_tree_03", Pickup.Kind.MEMORY, Vector3(60.4, 6.0, 0.0))


func _mechanism(id: StringName, pos: Vector3) -> Mechanism:
	var m := Mechanism.new()
	m.mechanism_id = id
	m.link_id = &"forest_a"
	m.prompt_text = "Pressione E para ativar o mecanismo antigo"
	m.position = pos
	add_child(m)
	return m
