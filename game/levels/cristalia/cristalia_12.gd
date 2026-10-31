class_name CristaliaLevel12
extends LevelScene
## FASE 12 — Zythra, a Orquidea de Cristal (Cristalia): arena do guardiao. Visual PROVISORIO. Tres fases, cada uma encerrada por uma
## etapa propria: 1) reposicionar o prisma ate o nucleo; 2) distinguir a flor REAL das ilusoes (a real nao pisca); 3) Pipa planeia ate
## o mecanismo alto. Depois, o Golpe Triade com tres herois. A semente e uma transacao unica (ProgressLedger).

signal seed_destroyed(first_time: bool)

const DEFINITION: String = "res://game/levels/cristalia/cristalia_12_definition.tres"
const RELIC_ID: String = "relic_cristalia"
const MEMORY_ID: String = "astralis_memory_cristalia"
const TRIAD_POSITIONS: Array[Vector3] = [Vector3(6.5, 0.8, 0.0), Vector3(11.5, 0.8, 0.0), Vector3(16.5, 0.8, 0.0)]
const FLOWER_X: Array[float] = [6.5, 16.5, 26.5]
const REAL_FLOWER: int = 1

var reaction_message: String = "CAELDRON\nReconhece a Astralis. Uma fissura forte se abre."
var boss: ZythraBoss
var triad: TriadFinisher
var field: BeamField
var prism: BeamPrism
var flowers: Array[FlowerCandidate] = []
var pipa_mechanism: Mechanism
var chest: Chest
var planet: PlanetDefinition

var _progress: ProgressLedger = ProgressLedger.new()


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	planet = GalaxyState.planets()[1]
	b.solid(Vector3(15.0, -0.5, 0.0), Vector3(38.0, 1.0, 4.0), Color("4A3F73"))
	b.zone(PhysicsLayers.CHECKPOINT, "cristalia_12_cp1", Vector3(0.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.2, 0.8, 1.0, 0.2))
	boss = ZythraBoss.new()
	boss.seed_id = planet.seed_id
	add_child(boss)
	# Etapa 1: o prisma desvia o feixe ate o nucleo exposto.
	field = BeamField.new()
	add_child(field)
	field.add_emitter(Vector2i(-2, 1), Vector2i(1, 0))
	prism = field.add_prism(Vector2i(1, 1), 1)
	field.add_target(Vector2i(1, 6), &"core")
	# Etapa 2: tres flores; so a real nao pisca.
	for i in FLOWER_X.size():
		var f := FlowerCandidate.new()
		f.is_real = i == REAL_FLOWER
		f.position = Vector3(FLOWER_X[i], 0.8, 0.0)
		add_child(f)
		flowers.append(f)
	# Etapa 3: escalar (Zuri), planear com vento (Pipa) ate o mecanismo alto.
	b.zone(PhysicsLayers.CLIMBABLE, "climb_12", Vector3(28.6, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(32.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B5CA5"))
	b.zone(PhysicsLayers.WIND, "wind_12", Vector3(24.5, 6.0, 0.0), Vector3(9.0, 12.0, 3.0), Color(0.7, 0.9, 1.0, 0.15), Vector3(0.0, 23.0, 0.0))
	b.solid(Vector3(17.0, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B5CA5"))
	pipa_mechanism = Mechanism.new()
	pipa_mechanism.mechanism_id = &"zythra_pipa"
	pipa_mechanism.prompt_text = "Pressione E para ativar o mecanismo"
	pipa_mechanism.position = Vector3(18.0, 5.8, 0.0)
	add_child(pipa_mechanism)
	triad = TriadFinisher.new()
	add_child(triad)
	var spots: Array[Vector3] = TRIAD_POSITIONS
	triad.build(spots)
	chest = b.chest("cristalia_12_chest", Vector3(32.0, 0.6, 0.0))
	chest.locked = true
	b.decor(Vector3(15.0, 3.0, -3.5), Vector3(8.0, 6.0, 2.0), Color("7C3AED"), true)
	b.decor(Vector3(15.0, 3.5, -2.4), Vector3(1.6, 1.6, 0.6), Color("56DDB5"), true)
	for x in range(-2, 34, 6):
		b.decor(Vector3(float(x), 2.0, -4.0), Vector3(1.4, 4.0, 1.4), Color("7C6BC4"), true)
	var coins: Array[Vector3] = [Vector3(1.0, 1, 0), Vector3(6.5, 1, 0), Vector3(11.5, 1, 0), Vector3(16.5, 1, 0), Vector3(21.5, 1, 0), Vector3(26.5, 1, 0)]
	for i in coins.size():
		b.pickup("cristalia_12_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	boss.save = save
	triad.link(boss, rig)
	for f in flowers:
		f.boss = boss
		f.vitals = rig.vitals
	field.changed.connect(_on_field_changed)
	boss.defeated.connect(_on_defeated)
	boss.phase_changed.connect(func(_p: int) -> void: _derive_enabled())
	pipa_mechanism.activated.connect(func(_m: Mechanism) -> void: boss.mechanism_done(&"pipa"))
	camera.target = null
	camera.global_position = Vector3(15.0, 5.5, 15.0)
	if _progress.is_seed_destroyed(save, planet):
		boss.restore(null)
		_apply_victory_state()


func _physics_process(_delta: float) -> void:
	if boss != null:
		_derive_enabled()


func _derive_enabled() -> void:
	if boss.is_defeated():
		return
	pipa_mechanism.enabled = boss.phase == VyrkanBoss.Phase.THREE


func _on_field_changed() -> void:
	if field.is_lit(&"core") and boss.phase == VyrkanBoss.Phase.ONE:
		boss.mechanism_done(&"prism")


func _on_defeated() -> void:
	var result: Dictionary = _progress.commit_seed(save, planet, RELIC_ID, MEMORY_ID)
	_apply_victory_state()
	seed_destroyed.emit(result["first_time"])


func _apply_victory_state() -> void:
	chest.locked = false
	pipa_mechanism.enabled = false
