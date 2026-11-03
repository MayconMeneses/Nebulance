class_name AerionLevel28
extends LevelScene
## FASE 28 — O Ceu de Cabeca para Baixo (Aerion). Visual PROVISORIO. Gravidade local INVERTIDA em areas definidas (zonas violeta com
## simbolos no chao): quem entra sobe ate o teto da zona e segue encostado nele (o teto vira trajeto) ate sair, quando volta a cair.
## Tres inversoes: um poco, um pilar alto e um poco longo. Nada de controles ou camera invertidos. Paisagem em plano duplo com
## templos espelhados. Checkpoint antes da primeira inversao complexa (a do pilar).

const DEFINITION: String = "res://game/levels/aerion/aerion_28_definition.tres"
const INVERTED: float = -0.7

var zones: Array[LevelZone] = []
var chest: Chest
var secret_panel: Mechanism
var portal: Portal


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var stone := Color("7B6FB5")
	var violet := Color(0.6, 0.35, 1.0, 0.12)
	b.solid(Vector3(5.0, -0.5, 0.0), Vector3(22.0, 1.0, 4.0), stone)
	# Inversao 1 (simples): poco de 10 m com teto.
	zones.append(b.zone(PhysicsLayers.WIND, "invert_28_a", Vector3(21.0, 3.5, 0.0), Vector3(10.0, 11.0, 3.0), violet, Vector3.ZERO, INVERTED))
	b.solid(Vector3(21.0, 6.5, 0.0), Vector3(12.0, 1.0, 4.0), Color("9A8FD0"))
	# Piso central com checkpoint e a inversao 2 (complexa): um pilar de 3,5 m so passa pelo teto.
	b.solid(Vector3(44.0, -0.5, 0.0), Vector3(36.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.CHECKPOINT, "aerion_28_cp1", Vector3(40.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.93, 0.72, 0.37, 0.25))
	b.solid(Vector3(50.0, 1.75, 0.0), Vector3(2.0, 3.5, 4.0), Color("C03CA8"), true)
	zones.append(b.zone(PhysicsLayers.WIND, "invert_28_b", Vector3(48.0, 3.5, 0.0), Vector3(12.0, 11.0, 3.0), violet, Vector3.ZERO, INVERTED))
	b.solid(Vector3(48.0, 6.5, 0.0), Vector3(14.0, 1.0, 4.0), Color("9A8FD0"))
	# Inversao 3: poco longo de 10 m ate a ilha final.
	zones.append(b.zone(PhysicsLayers.WIND, "invert_28_c", Vector3(66.0, 3.5, 0.0), Vector3(12.0, 11.0, 3.0), violet, Vector3.ZERO, INVERTED))
	b.solid(Vector3(66.0, 6.5, 0.0), Vector3(14.0, 1.0, 4.0), Color("9A8FD0"))
	b.solid(Vector3(82.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.ABYSS, "sky_28", Vector3(45.0, -9.0, 0.0), Vector3(130.0, 3.0, 4.0), Color(0.1, 0.1, 0.3, 0.2))
	chest = b.chest("aerion_28_chest", Vector3(86.0, 0.6, 0.0))
	b.pickup("aerion_28_gravity_clue", Pickup.Kind.ITEM, Vector3(50.0, 4.8, 0.0))
	# Painel escondido (pista na fase 27) que abre o portal da S05 (Jardim Sem Gravidade) na ilha final.
	secret_panel = Mechanism.new()
	secret_panel.mechanism_id = &"aerion_28_secret_panel"
	secret_panel.prompt_text = "Pressione E para ligar o painel de gravidade"
	secret_panel.position = Vector3(78.0, 0.8, 0.0)
	add_child(secret_panel)
	portal = Portal.new()
	portal.portal_id = &"aerion_28_portal"
	portal.destination_level_id = &"aerion_s05"
	portal.requires_open = true
	portal.position = Vector3(90.5, 1.2, 0.0)
	add_child(portal)
	# Simbolos de inversao no chao, na entrada de cada zona (seta para cima).
	for sx in [15.0, 41.0, 59.0]:
		b.decor(Vector3(sx, 0.08, 1.2), Vector3(0.8, 0.12, 0.8), Color("C03CA8"), true)
		b.decor(Vector3(sx, 0.08, -1.2), Vector3(0.8, 0.12, 0.8), Color("C03CA8"), true)
	# Templos espelhados em plano duplo: um no chao e o mesmo de cabeca para baixo no alto.
	b.decor(Vector3(84.0, 2.0, -3.5), Vector3(5.0, 4.0, 2.0), Color("B8A9F0"), true)
	b.decor(Vector3(84.0, 10.0, -3.5), Vector3(5.0, 4.0, 2.0), Color("B8A9F0"), true)
	b.decor(Vector3(6.0, 2.0, -3.5), Vector3(5.0, 4.0, 2.0), Color("B8A9F0"), true)
	b.decor(Vector3(6.0, 10.0, -3.5), Vector3(5.0, 4.0, 2.0), Color("B8A9F0"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(21, 5.0, 0), Vector3(36, 1, 0), Vector3(40, 1, 0),
			Vector3(46, 5.0, 0), Vector3(53, 5.0, 0), Vector3(67, 5.0, 0), Vector3(78, 1, 0)]
	for i in coins.size():
		b.pickup("aerion_28_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	secret_panel.activated.connect(func(_m: Mechanism) -> void: portal.open())
