class_name AerionLevel27
extends LevelScene
## FASE 27 — Corredores do Vento (Aerion). Visual PROVISORIO. Dominio do planeio e de correntes previsiveis: Pipa guia as travessias,
## Zuri escala e liga o painel de vento, Rocco rompe a barreira que cobria a base da corrente; so com o painel LIGADO e a base
## LIVRE a segunda corrente sopra. Segredo: uma valvula opcional no fim do corredor INVERTE uma terceira corrente (para baixo, com
## faixas descendentes) e so entao a ilha oculta com a pista do portal secreto aparece. Checkpoint depois da primeira travessia.

const DEFINITION: String = "res://game/levels/aerion/aerion_27_definition.tres"

var lift_a: WindVent
var lift_b: WindVent
var panel: Mechanism
var valve: Mechanism
var inverted: WindVent
var barrier: ImpactBarrier
var island: ControlledPlatform
var chest: Chest


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var stone := Color("7FA6C4")
	b.solid(Vector3(4.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), stone)
	# Primeira travessia: corrente permanente (Pipa guia).
	lift_a = WindVent.new()
	lift_a.size = Vector3(9.0, 12.0, 3.0)
	lift_a.position = Vector3(18.5, 1.25, 0.0)
	add_child(lift_a)
	b.solid(Vector3(34.5, -0.5, 0.0), Vector3(23.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.CHECKPOINT, "aerion_27_cp1", Vector3(25.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.93, 0.72, 0.37, 0.25))
	# Painel de vento no alto (Zuri escala).
	b.zone(PhysicsLayers.CLIMBABLE, "climb_27", Vector3(27.4, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(31.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("8FD3C0"))
	panel = Mechanism.new()
	panel.mechanism_id = &"aerion_27_panel"
	panel.prompt_text = "Pressione E para ligar o painel de vento"
	panel.position = Vector3(31.0, 5.8, 0.0)
	add_child(panel)
	# Base da segunda corrente, coberta por uma barreira marcada (Rocco).
	barrier = b.barrier(Vector3(38.0, 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	b.decor(Vector3(41.5, 0.3, 0.0), Vector3(3.0, 0.6, 3.0), Color("23CFF5"), true)
	lift_b = WindVent.new()
	lift_b.size = Vector3(9.0, 12.0, 3.0)
	lift_b.position = Vector3(50.5, 1.25, 0.0)
	lift_b.control = panel
	lift_b.blocker = barrier
	add_child(lift_b)
	b.solid(Vector3(72.5, -0.5, 0.0), Vector3(35.0, 1.0, 4.0), stone)
	# Segredo: a valvula (opcional, no fim do corredor) inverte a corrente sobre a ilha; so com ela invertida a ilha oculta existe.
	valve = Mechanism.new()
	valve.mechanism_id = &"aerion_27_valve"
	valve.prompt_text = "Pressione E para inverter a corrente"
	valve.position = Vector3(57.0, 0.6, 0.0)
	add_child(valve)
	inverted = WindVent.new()
	inverted.size = Vector3(6.0, 8.0, 3.0)
	inverted.wind_on = Vector3(0.0, -18.0, 0.0)
	inverted.position = Vector3(63.0, 4.0, 0.0)
	inverted.control = valve
	add_child(inverted)
	island = ControlledPlatform.new()
	island.size = Vector3(5.0, 0.5, 3.0)
	island.position = Vector3(63.0, 0.65, 0.0)
	island.control = valve
	add_child(island)
	b.pickup("memory_secret_portal_clue_27", Pickup.Kind.MEMORY, Vector3(63.0, 1.8, 0.0))
	b.zone(PhysicsLayers.ABYSS, "sky_27", Vector3(40.0, -9.0, 0.0), Vector3(130.0, 3.0, 4.0), Color(0.1, 0.1, 0.3, 0.2))
	chest = b.chest("aerion_27_chest", Vector3(84.0, 0.6, 0.0))
	for x in range(0, 90, 9):
		b.decor(Vector3(float(x), -2.5, -5.0), Vector3(6.0, 1.4, 3.0), Color("E8F0FA"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(25.5, 1, 0), Vector3(30, 6.2, 0), Vector3(33, 6.2, 0),
			Vector3(41, 1, 0), Vector3(58, 1, 0), Vector3(70, 1, 0), Vector3(78, 1, 0)]
	for i in coins.size():
		b.pickup("aerion_27_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])
