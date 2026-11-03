class_name AerionLevel30
extends LevelScene
## FASE 30 — Zefrion, o Dente-de-Leao (Aerion): arena do guardiao. Visual PROVISORIO. Tres fases, cada uma encerrada por uma etapa
## propria: 1) ancorar os controles de vento (dois mecanismos ligados ao mesmo tempo); 2) escalar (Zuri) ate o farol no alto, que
## liga a corrente de ar; 3) planar (Pipa) na corrente ate o nucleo e desativar a protecao da semente (a zona de baixa gravidade
## em volta do nucleo e o "ar rarefeito" da semente). Depois, o Golpe Triade com tres herois.
## A semente e uma transacao unica (ProgressLedger); as maquinas reiniciam de forma idempotente no checkpoint.

signal seed_destroyed(first_time: bool)

const DEFINITION: String = "res://game/levels/aerion/aerion_30_definition.tres"
## Escala da gravidade em volta do nucleo ("ar rarefeito"): o heroi flutua bem mais alto (0,35 = pouco mais de um terco da gravidade normal).
const THIN_AIR: float = 0.35
const RELIC_ID: String = "relic_aerion"
const MEMORY_ID: String = "astralis_memory_aerion"
const TRIAD_POSITIONS: Array[Vector3] = [Vector3(6.5, 0.8, 0.0), Vector3(11.5, 0.8, 0.0), Vector3(16.5, 0.8, 0.0)]

var reaction_message: String = "CAELDRON\nEntra em DESESPERO ao perder a quinta raiz: a rota direta para Umbraxis esta aberta."
var boss: ZefrionBoss
var triad: TriadFinisher
var anchor_a: Mechanism
var anchor_b: Mechanism
var beacon: Mechanism
var shield: Mechanism
var updraft: WindVent
var chest: Chest
var planet: PlanetDefinition

var _progress: ProgressLedger = ProgressLedger.new()


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	planet = GalaxyState.planets()[4]
	var stone := Color("7FA6C4")
	b.solid(Vector3(27.0, -0.5, 0.0), Vector3(62.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.CHECKPOINT, "aerion_30_cp1", Vector3(0.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.93, 0.72, 0.37, 0.2))
	boss = ZefrionBoss.new()
	boss.seed_id = planet.seed_id
	add_child(boss)
	# Etapa 1: dois controles de vento sincronizados (cada um se desliga sozinho depois de 8 s).
	anchor_a = _anchor(&"aerion_30_anchor_a", Vector3(1.5, 0.8, 0.0))
	anchor_b = _anchor(&"aerion_30_anchor_b", Vector3(6.5, 0.8, 0.0))
	# Etapa 2: face marcada (Zuri) ate o farol no deck alto.
	b.zone(PhysicsLayers.CLIMBABLE, "climb_30", Vector3(21.5, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(26.5, 4.75, 0.0), Vector3(8.0, 0.5, 4.0), Color("8FD3C0"))
	beacon = Mechanism.new()
	beacon.mechanism_id = &"aerion_30_beacon"
	beacon.prompt_text = "Pressione E para acender o farol de vento"
	beacon.position = Vector3(27.0, 5.8, 0.0)
	add_child(beacon)
	# Etapa 3: a corrente so sopra com o farol aceso; planar ate o nucleo e abrir a protecao.
	updraft = WindVent.new()
	updraft.size = Vector3(9.0, 12.0, 3.0)
	updraft.position = Vector3(35.0, 6.0, 0.0)
	updraft.control = beacon
	add_child(updraft)
	b.solid(Vector3(43.0, 4.5, 0.0), Vector3(7.0, 1.0, 4.0), Color("EDB85E"))
	b.zone(PhysicsLayers.WIND, "thin_air_30", Vector3(43.0, 8.5, 0.0), Vector3(9.0, 7.0, 3.0), Color(0.6, 0.4, 1.0, 0.1), Vector3.ZERO, THIN_AIR)
	shield = Mechanism.new()
	shield.mechanism_id = &"aerion_30_shield"
	shield.prompt_text = "Pressione E para desativar a protecao da semente"
	shield.position = Vector3(43.0, 5.8, 0.0)
	add_child(shield)
	triad = TriadFinisher.new()
	add_child(triad)
	var spots: Array[Vector3] = TRIAD_POSITIONS
	triad.build(spots)
	chest = b.chest("aerion_30_chest", Vector3(54.0, 0.6, 0.0))
	chest.locked = true
	b.zone(PhysicsLayers.ABYSS, "sky_30", Vector3(27.0, -9.0, 0.0), Vector3(100.0, 3.0, 4.0), Color(0.1, 0.1, 0.3, 0.2))
	# Dente-de-leao gigante ao fundo (decoracao): haste e pluma de sementes.
	b.decor(Vector3(15.0, 4.0, -4.5), Vector3(0.8, 8.0, 0.8), Color("5B3A29"))
	b.decor(Vector3(15.0, 9.0, -4.5), Vector3(7.0, 3.0, 2.0), Color("F3E9C6"), true)
	var coins: Array[Vector3] = [Vector3(1.0, 1, 0), Vector3(6.5, 1, 0), Vector3(11.5, 1, 0), Vector3(16.5, 1, 0), Vector3(28.5, 6.2, 0), Vector3(44.0, 6.2, 0)]
	for i in coins.size():
		b.pickup("aerion_30_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	boss.save = save
	triad.link(boss, rig)
	boss.defeated.connect(_on_defeated)
	shield.activated.connect(func(_m: Mechanism) -> void: boss.mechanism_done(&"glide"))
	if _progress.is_seed_destroyed(save, planet):
		boss.restore(null)
		_apply_victory_state()


func _physics_process(_delta: float) -> void:
	if boss == null:
		return
	if boss.phase == VyrkanBoss.Phase.ONE and anchor_a.is_active and anchor_b.is_active:
		boss.mechanism_done(&"anchors")
	if boss.phase == VyrkanBoss.Phase.TWO and beacon.is_active:
		boss.mechanism_done(&"climb")
	_derive_enabled()


## Cada mecanismo so e interagivel na sua fase (estado derivado da fase, nunca guardado a parte).
func _derive_enabled() -> void:
	if boss.is_defeated():
		return
	anchor_a.enabled = boss.phase == VyrkanBoss.Phase.ONE
	anchor_b.enabled = boss.phase == VyrkanBoss.Phase.ONE
	beacon.enabled = boss.phase == VyrkanBoss.Phase.TWO
	shield.enabled = boss.phase == VyrkanBoss.Phase.THREE


func _on_defeated() -> void:
	var result: Dictionary = _progress.commit_seed(save, planet, RELIC_ID, MEMORY_ID)
	_apply_victory_state()
	seed_destroyed.emit(result["first_time"])


func _apply_victory_state() -> void:
	chest.locked = false
	for m in [anchor_a, anchor_b, beacon, shield]:
		m.enabled = false


func _anchor(id: StringName, pos: Vector3) -> Mechanism:
	var m := Mechanism.new()
	m.mechanism_id = id
	m.hold_time = 8.0
	m.prompt_text = "Pressione E para ancorar o controle de vento"
	m.position = pos
	add_child(m)
	return m
