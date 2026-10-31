class_name SylvaraLevel06
extends LevelScene
## FASE 06 — O Guardiao das Raizes (Sylvara): arena de Vyrkan. Visual PROVISORIO. Tres fases, cada uma encerrada por um
## mecanismo de um heroi (Rocco: apoio marcado; Zuri: escalar; Pipa: planear com vento) e o Golpe Triade com tres herois.
## A semente e destruida por UMA transacao idempotente (ProgressLedger); depois da vitoria a arena abre ja restaurada.

signal seed_destroyed(first_time: bool)

const DEFINITION: String = "res://game/levels/sylvara/sylvara_06_definition.tres"
const RELIC_ID: String = "relic_sylvara"
const MEMORY_ID: String = "astralis_memory_sylvara"
const TRIAD_POSITIONS: Array[Vector3] = [Vector3(6.5, 0.8, 0.0), Vector3(11.5, 0.8, 0.0), Vector3(16.5, 0.8, 0.0)]

var boss: VyrkanBoss
var triad: TriadFinisher
var barrier: ImpactBarrier
var zuri_mechanism: Mechanism
var pipa_mechanism: Mechanism
var chest: Chest
var planet: PlanetDefinition

var _progress: ProgressLedger = ProgressLedger.new()


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	planet = GalaxyState.planets()[0]
	b.solid(Vector3(15.0, -0.5, 0.0), Vector3(38.0, 1.0, 4.0), Color("2F5D4A"))
	b.zone(PhysicsLayers.CHECKPOINT, "sylvara_06_cp1", Vector3(0.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.2))
	boss = VyrkanBoss.new()
	boss.seed_id = planet.seed_id
	add_child(boss)
	# Etapa 1 (Rocco): apoio marcado que so cede a investida.
	barrier = b.barrier(Vector3(2.2, 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	# Etapa 2 (Zuri): mecanismo no alto, depois de escalar.
	b.zone(PhysicsLayers.CLIMBABLE, "climb_06", Vector3(28.6, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(32.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("3E7A63"))
	zuri_mechanism = _mechanism(&"vyrkan_zuri", Vector3(33.5, 5.8, 0.0))
	# Etapa 3 (Pipa): mecanismo alem do vao, com vento (planeio para o oeste a partir da plataforma da Zuri).
	b.zone(PhysicsLayers.WIND, "wind_06", Vector3(24.5, 6.0, 0.0), Vector3(9.0, 12.0, 3.0), Color(0.7, 0.9, 1.0, 0.15), Vector3(0.0, 23.0, 0.0))
	b.solid(Vector3(17.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("3E7A63"))
	pipa_mechanism = _mechanism(&"vyrkan_pipa", Vector3(18.0, 5.8, 0.0))
	zuri_mechanism.enabled = false
	pipa_mechanism.enabled = false
	triad = TriadFinisher.new()
	add_child(triad)
	var spots: Array[Vector3] = TRIAD_POSITIONS
	triad.build(spots)
	chest = b.chest("sylvara_06_chest", Vector3(32.0, 0.6, 0.0))
	chest.locked = true
	# O chefe: flor vermelha de petalas largas com o ponto vulneravel (bulbo) ao centro, ao fundo.
	b.decor(Vector3(15.0, 3.0, -3.5), Vector3(8.0, 6.0, 2.0), Color("8A2A2A"), true)
	b.decor(Vector3(15.0, 3.5, -2.4), Vector3(1.6, 1.6, 0.6), Color("56DDB5"), true)
	for x in range(-2, 34, 6):
		b.tree(float(x), 3.0)
	var coins: Array[Vector3] = [Vector3(1.0, 1, 0), Vector3(6.5, 1, 0), Vector3(11.5, 1, 0), Vector3(16.5, 1, 0), Vector3(21.5, 1, 0), Vector3(26.5, 1, 0)]
	for i in coins.size():
		b.pickup("sylvara_06_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	boss.save = save
	triad.link(boss, rig)
	barrier.broken.connect(func() -> void: boss.mechanism_done(&"rocco"))
	zuri_mechanism.activated.connect(func(_m: Mechanism) -> void: boss.mechanism_done(&"zuri"))
	pipa_mechanism.activated.connect(func(_m: Mechanism) -> void: boss.mechanism_done(&"pipa"))
	boss.phase_changed.connect(_on_phase_changed)
	boss.defeated.connect(_on_defeated)
	# Camera de arena: fixa, enquadrando todo o campo e o ponto vulneravel.
	camera.target = null
	camera.global_position = Vector3(15.0, 5.5, 15.0)
	# Vitoria ja registrada no save: a arena abre restaurada, sem luta e com o bau liberado.
	if _progress.is_seed_destroyed(save, planet):
		boss.restore(null)
		_apply_victory_state()


func _on_phase_changed(phase: int) -> void:
	zuri_mechanism.enabled = phase == VyrkanBoss.Phase.TWO
	pipa_mechanism.enabled = phase == VyrkanBoss.Phase.THREE


func _on_defeated() -> void:
	var result: Dictionary = _progress.commit_seed(save, planet, RELIC_ID, MEMORY_ID)
	_apply_victory_state()
	seed_destroyed.emit(result["first_time"])


func _apply_victory_state() -> void:
	chest.locked = false
	zuri_mechanism.enabled = false
	pipa_mechanism.enabled = false


func _mechanism(id: StringName, pos: Vector3) -> Mechanism:
	var m := Mechanism.new()
	m.mechanism_id = id
	m.prompt_text = "Pressione E para ativar o mecanismo"
	m.position = pos
	add_child(m)
	return m
