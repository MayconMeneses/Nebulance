class_name UmbraxisLevel36
extends LevelScene
## FASE 36 — Necryon e a Ultima Semente (Umbraxis): arena do guardiao. Visual PROVISORIO. Tres fases, cada uma encerrada por uma etapa
## propria: 1) combinacao: tocar os quatro cristais na ordem da fechadura; 2) ilusoes: so UMA das tres pedras-eco e real (as outras piscam
## ou sao finas); 3) ruptura: estabilizar a travessia de plataformas de ruptura, escalar e selar o nucleo no alto. Depois, o Golpe Triade com
## tres herois (no patamar final). A semente e uma transacao unica (ProgressLedger). NAO ha final nem cutscene de Caeldron aqui: so a
## mensagem de reacao; a semente 6 fica registrada e o bau final e liberado.

signal seed_destroyed(first_time: bool)

const DEFINITION: String = "res://game/levels/umbraxis/umbraxis_36_definition.tres"
const RELIC_ID: String = "relic_umbraxis"
const MEMORY_ID: String = "astralis_memory_umbraxis"
const TRIAD_POSITIONS: Array[Vector3] = [Vector3(74.0, 0.8, 0.0), Vector3(77.5, 0.8, 0.0), Vector3(81.0, 0.8, 0.0)]
const CRYSTAL_X: Array[float] = [1.5, 6.5, 11.5, 16.5]
const STONE_X: Array[float] = [21.5, 26.5, 31.5]
const REAL_STONE: int = 1

var reaction_message: String = "CAELDRON\nPerde a sexta raiz. O Coracao do Colapso se rompe e ele nao tem mais onde se esconder."
var boss: NecryonBoss
var triad: TriadFinisher
var lock: SequenceLock
var stones: Array[EchoStone] = []
var stabilizer: Mechanism
var platforms: Array[RupturePlatform] = []
var core: Mechanism
var chest: Chest
var planet: PlanetDefinition

var _progress: ProgressLedger = ProgressLedger.new()


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	planet = GalaxyState.planets()[5]
	var rock := Color("3A2F55")
	b.solid(Vector3(20.0, -0.5, 0.0), Vector3(52.0, 1.0, 4.0), rock)
	b.zone(PhysicsLayers.CHECKPOINT, "umbraxis_36_cp1", Vector3(0.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.75, 0.24, 0.66, 0.2))
	boss = NecryonBoss.new()
	boss.seed_id = planet.seed_id
	add_child(boss)
	# Etapa 1: combinacao (fechadura de sequencia; a dica pisca em ordem).
	lock = SequenceLock.new()
	add_child(lock)
	for i in CRYSTAL_X.size():
		var c := SequenceCrystal.new()
		c.index = i
		c.lock = lock
		c.position = Vector3(CRYSTAL_X[i], 1.0, 0.0)
		add_child(c)
		lock.crystals.append(c)
	# Etapa 2: tres pedras-eco; a real (a do meio) nao pisca e tem forma cheia; uma ilusao pisca, a outra e fina.
	var cues: Array[EchoStone.Cue] = [EchoStone.Cue.BLINK, EchoStone.Cue.BLINK, EchoStone.Cue.SHAPE]
	for i in STONE_X.size():
		var s := EchoStone.new()
		s.is_real = i == REAL_STONE
		s.cue = cues[i]
		s.enabled = false
		s.position = Vector3(STONE_X[i], 0.9, 0.0)
		add_child(s)
		stones.append(s)
	# Etapa 3: estabilizador, travessia de ruptura, escalada e nucleo no alto.
	stabilizer = Mechanism.new()
	stabilizer.mechanism_id = &"umbraxis_36_stabilizer"
	stabilizer.link_id = &"boss_rift"
	stabilizer.prompt_text = "Pressione E para estabilizar a ruptura"
	stabilizer.position = Vector3(42.0, 0.8, 0.0)
	add_child(stabilizer)
	for i in 3:
		var p := RupturePlatform.new()
		p.position = Vector3(49.5 + 4.5 * i, -0.2, 0.0)
		p.phase_offset = 0.0 if i % 2 == 0 else 2.1
		p.link_id = &"boss_rift"
		p.solid_time = 3.0
		p.gone_time = 1.2
		add_child(p)
		platforms.append(p)
	b.solid(Vector3(75.25, -0.5, 0.0), Vector3(29.5, 1.0, 4.0), rock)
	b.zone(PhysicsLayers.ABYSS, "rift_36", Vector3(53.0, -6.0, 0.0), Vector3(20.0, 3.0, 4.0), Color(0.5, 0.0, 0.3, 0.2))
	b.zone(PhysicsLayers.CLIMBABLE, "climb_36", Vector3(66.0, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(69.6, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("8C6BC4"))
	core = Mechanism.new()
	core.mechanism_id = &"umbraxis_36_core"
	core.prompt_text = "Pressione E para selar o nucleo da semente"
	core.position = Vector3(70.0, 5.8, 0.0)
	add_child(core)
	triad = TriadFinisher.new()
	add_child(triad)
	var spots: Array[Vector3] = TRIAD_POSITIONS
	triad.build(spots)
	chest = b.chest("umbraxis_36_chest", Vector3(86.0, 0.6, 0.0))
	chest.locked = true
	# Coracao do Colapso ao fundo: nucleo pulsante e raizes colossais.
	for x in range(-4, 90, 11):
		b.decor(Vector3(float(x), 6.0, -5.0), Vector3(2.0, 12.0, 2.0), Color("5B1F4F"), true)
	var coins: Array[Vector3] = [Vector3(1.0, 1, 0), Vector3(6.5, 1, 0), Vector3(11.5, 1, 0), Vector3(16.5, 1, 0), Vector3(69.2, 6.0, 0), Vector3(84.0, 1, 0)]
	for i in coins.size():
		b.pickup("umbraxis_36_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	boss.save = save
	triad.link(boss, rig)
	boss.defeated.connect(_on_defeated)
	core.activated.connect(func(_m: Mechanism) -> void: boss.mechanism_done(&"core"))
	for s in stones:
		s.vitals = rig.vitals
		s.real_touched.connect(func(_s: EchoStone) -> void: boss.mechanism_done(&"real"))
		s.wrong_touched.connect(func(_s: EchoStone) -> void: boss.wrong_illusion())
	if _progress.is_seed_destroyed(save, planet):
		boss.restore(null)
		_apply_victory_state()


func _physics_process(_delta: float) -> void:
	if boss == null:
		return
	if boss.phase == VyrkanBoss.Phase.ONE and lock.is_unlocked:
		boss.mechanism_done(&"combine")
	_derive_enabled()


## Cada etapa so e interagivel na sua fase (estado derivado da fase, nunca guardado a parte).
func _derive_enabled() -> void:
	if boss.is_defeated():
		return
	for s in stones:
		s.enabled = boss.phase == VyrkanBoss.Phase.TWO
	stabilizer.enabled = boss.phase == VyrkanBoss.Phase.THREE
	core.enabled = boss.phase == VyrkanBoss.Phase.THREE


func _on_defeated() -> void:
	var result: Dictionary = _progress.commit_seed(save, planet, RELIC_ID, MEMORY_ID)
	_apply_victory_state()
	seed_destroyed.emit(result["first_time"])


func _apply_victory_state() -> void:
	chest.locked = false
	stabilizer.enabled = false
	core.enabled = false
	for s in stones:
		s.enabled = false
