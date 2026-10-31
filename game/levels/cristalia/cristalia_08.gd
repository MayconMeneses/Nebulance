class_name CristaliaLevel08
extends LevelScene
## FASE 08 — O Labirinto dos Reflexos (Cristalia). Visual PROVISORIO. Dois prismas (um no chao, um no pedestal alto de Zuri) e um
## emissor ligado por um dispositivo aereo (Pipa) desviam o feixe ate um cristal; a parede so abre com a luz na orientacao correta.
## Checkpoint antes do conjunto de refletores.

const DEFINITION: String = "res://game/levels/cristalia/cristalia_08_definition.tres"

var field: BeamField
var prism_ground: BeamPrism
var prism_high: BeamPrism
var device: Mechanism


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var rock := Color("4A3F73")
	b.solid(Vector3(29.5, -0.5, 0.0), Vector3(71.0, 1.0, 4.0), rock)
	b.zone(PhysicsLayers.CHECKPOINT, "cristalia_08_cp1", Vector3(2.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.25))
	# Pedestal alto (Zuri escala pela face marcada).
	b.zone(PhysicsLayers.CLIMBABLE, "climb_08", Vector3(7.4, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(11.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B5CA5"))
	# Vao com vento ate a plataforma do dispositivo aereo (Pipa planeia).
	b.zone(PhysicsLayers.WIND, "wind_08", Vector3(18.5, 6.0, 0.0), Vector3(9.0, 12.0, 3.0), Color(0.7, 0.9, 1.0, 0.15), Vector3(0.0, 23.0, 0.0))
	b.solid(Vector3(26.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B5CA5"))
	device = Mechanism.new()
	device.mechanism_id = &"cristalia_08_device"
	device.prompt_text = "Pressione E para ativar o dispositivo aereo"
	device.position = Vector3(24.5, 5.8, 0.0)
	add_child(device)
	field = BeamField.new()
	add_child(field)
	field.add_emitter(Vector2i(3, 1), Vector2i(1, 0), device)
	prism_ground = field.add_prism(Vector2i(10, 1), 1)
	prism_high = field.add_prism(Vector2i(10, 6), 1)
	field.add_target(Vector2i(36, 6), &"wall")
	var wall := LightBridge.new()
	wall.link_id = &"wall"
	wall.opens_when_lit = true
	wall.size = Vector3(1.5, 6.0, 3.0)
	wall.field = field
	wall.position = Vector3(40.0, 3.0, 0.0)
	add_child(wall)
	b.chest("cristalia_08_chest", Vector3(60.0, 0.6, 0.0))
	for x in range(-6, 64, 7):
		b.decor(Vector3(float(x), 2.0, -4.0), Vector3(1.4, 4.0 + float(x % 3), 1.4), Color("7C6BC4"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(8, 1, 0), Vector3(9, 6.2, 0), Vector3(24.6, 6.2, 0), Vector3(26.5, 6.2, 0),
			Vector3(34, 1, 0), Vector3(45, 1, 0), Vector3(52, 1, 0), Vector3(56, 1, 0)]
	for i in coins.size():
		b.pickup("cristalia_08_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
	b.pickup("cristalia_08_music_crystal", Pickup.Kind.ITEM, Vector3(28.0, 6.1, 0.0))
