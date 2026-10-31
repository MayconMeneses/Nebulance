class_name CristaliaLevel09
extends LevelScene
## FASE 09 — O Jardim das Orquideas (Cristalia). Visual PROVISORIO. Tres sinais de luz escondidos (chao, pedestal alto de Zuri,
## plataforma de Pipa com vento) abrem o portao de luz do portal para a S02 (Camara das Frequencias Perdidas). Checkpoint junto ao portal.

const DEFINITION: String = "res://game/levels/cristalia/cristalia_09_definition.tres"

var field: BeamField
var prism_a: BeamPrism
var prism_b: BeamPrism
var prism_c: BeamPrism
var portal: Portal


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var rock := Color("4A3F73")
	b.solid(Vector3(47.0, -0.5, 0.0), Vector3(106.0, 1.0, 4.0), rock)
	field = BeamField.new()
	add_child(field)
	# Sinal 1 (chao).
	field.add_emitter(Vector2i(4, 1), Vector2i(1, 0))
	prism_a = field.add_prism(Vector2i(10, 1), 1)
	field.add_target(Vector2i(10, 6), &"s1")
	# Sinal 2 (pedestal alto; Zuri escala).
	b.zone(PhysicsLayers.CLIMBABLE, "climb_09", Vector3(13.4, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(17.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B5CA5"))
	field.add_emitter(Vector2i(15, 6), Vector2i(1, 0))
	prism_b = field.add_prism(Vector2i(18, 6), 1)
	field.add_target(Vector2i(18, 11), &"s2")
	# Sinal 3 (plataforma alem do vao com vento; Pipa planeia).
	b.zone(PhysicsLayers.WIND, "wind_09", Vector3(24.5, 6.0, 0.0), Vector3(9.0, 12.0, 3.0), Color(0.7, 0.9, 1.0, 0.15), Vector3(0.0, 23.0, 0.0))
	b.solid(Vector3(32.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B5CA5"))
	field.add_emitter(Vector2i(30, 6), Vector2i(1, 0))
	prism_c = field.add_prism(Vector2i(33, 6), 1)
	field.add_target(Vector2i(33, 11), &"s3")
	# Rota principal ate o bau; o portal fica ALEM do bau (opcional), atras do portao de luz dos tres sinais.
	b.chest("cristalia_09_chest", Vector3(84.0, 0.6, 0.0))
	b.zone(PhysicsLayers.CHECKPOINT, "cristalia_09_cp1", Vector3(90.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.25))
	var gate := LightBridge.new()
	gate.link_id = &"s1"
	gate.extra_links = [&"s2", &"s3"]
	gate.opens_when_lit = true
	gate.size = Vector3(1.5, 6.0, 3.0)
	gate.field = field
	gate.position = Vector3(94.0, 3.0, 0.0)
	add_child(gate)
	portal = Portal.new()
	portal.portal_id = &"cristalia_09_portal"
	portal.destination_level_id = &"cristalia_s02"
	portal.requires_open = true
	portal.position = Vector3(98.0, 1.2, 0.0)
	add_child(portal)
	b.pickup("memory_orchid_signals_09", Pickup.Kind.MEMORY, Vector3(98.0, 1.0, 0.0))
	for x in range(-6, 104, 7):
		b.decor(Vector3(float(x), 2.0, -4.0), Vector3(1.4, 4.0 + float(x % 3), 1.4), Color("C084FC"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(8, 1, 0), Vector3(15.5, 6.2, 0), Vector3(30.5, 6.2, 0), Vector3(40, 1, 0),
			Vector3(52, 1, 0), Vector3(64, 1, 0), Vector3(74, 1, 0), Vector3(80, 1, 0)]
	for i in coins.size():
		b.pickup("cristalia_09_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	field.changed.connect(_on_field_changed)


func _on_field_changed() -> void:
	if field.is_lit(&"s1") and field.is_lit(&"s2") and field.is_lit(&"s3"):
		portal.open()
