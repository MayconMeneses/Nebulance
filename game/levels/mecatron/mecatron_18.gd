class_name MecatronLevel18
extends LevelScene
## FASE 18 — Ferrorraiz, o Cacto Mecanico (Mecatron): arena do guardiao. Visual PROVISORIO. Tres fases, cada uma encerrada por uma etapa
## propria: 1) desligar os sistemas de energia (dois interruptores que precisam estar ligados ao mesmo tempo); 2) mover a ancora magnetica
## (a plataforma de polaridade sobe com o heroi); 3) abrir a protecao no alto. Depois, o Golpe Triade com tres herois.
## A semente e uma transacao unica (ProgressLedger); as maquinas reiniciam de forma idempotente no checkpoint.

signal seed_destroyed(first_time: bool)

const DEFINITION: String = "res://game/levels/mecatron/mecatron_18_definition.tres"
const RELIC_ID: String = "relic_mecatron"
const MEMORY_ID: String = "astralis_memory_mecatron"
const TRIAD_POSITIONS: Array[Vector3] = [Vector3(6.5, 0.8, 0.0), Vector3(11.5, 0.8, 0.0), Vector3(16.5, 0.8, 0.0)]

var reaction_message: String = "CAELDRON\nPerde a terceira raiz e ameaca a tripulacao da Astralis."
var boss: FerrorraizBoss
var triad: TriadFinisher
var power_a: Mechanism
var power_b: Mechanism
var anchor: PolarityPlatform
var shield: Mechanism
var chest: Chest
var planet: PlanetDefinition

var _progress: ProgressLedger = ProgressLedger.new()


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	planet = GalaxyState.planets()[2]
	var steel := Color("4B5563")
	b.solid(Vector3(15.0, -0.5, 0.0), Vector3(38.0, 1.0, 4.0), steel)
	b.zone(PhysicsLayers.CHECKPOINT, "mecatron_18_cp1", Vector3(0.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.95, 0.55, 0.2, 0.2))
	boss = FerrorraizBoss.new()
	boss.seed_id = planet.seed_id
	add_child(boss)
	# Etapa 1: dois interruptores sincronizados (cada um se desliga sozinho depois de 8 s).
	power_a = _switch(&"mecatron_18_power_a", Vector3(1.5, 0.8, 0.0))
	power_b = _switch(&"mecatron_18_power_b", Vector3(6.5, 0.8, 0.0))
	# Etapa 2: ancora magnetica = elevador de polaridade; sobe com o heroi ate o patamar.
	anchor = PolarityPlatform.new()
	anchor.position = Vector3(21.0, -0.2, 0.0)
	anchor.axis = Vector3(0.0, 4.0, 0.0)
	add_child(anchor)
	var lever := Mechanism.new()
	lever.mechanism_id = &"mecatron_18_anchor_lever"
	lever.toggle = true
	lever.prompt_text = "Pressione E para mover a ancora magnetica"
	lever.position = Vector3(0.0, 0.8, 0.0)
	anchor.add_child(lever)
	anchor.control = lever
	# Etapa 3: protecao no patamar alto.
	b.solid(Vector3(25.25, 3.5, 0.0), Vector3(5.5, 1.0, 4.0), steel)
	shield = Mechanism.new()
	shield.mechanism_id = &"mecatron_18_shield"
	shield.prompt_text = "Pressione E para abrir a protecao"
	shield.position = Vector3(25.0, 4.8, 0.0)
	add_child(shield)
	triad = TriadFinisher.new()
	add_child(triad)
	var spots: Array[Vector3] = TRIAD_POSITIONS
	triad.build(spots)
	chest = b.chest("mecatron_18_chest", Vector3(32.0, 0.6, 0.0))
	chest.locked = true
	for i in 6:
		var g := GearDecor.new()
		g.radius = 1.4 + float(i % 3) * 0.5
		g.spin_speed = 0.5 if i % 2 == 0 else -0.5
		g.position = Vector3(float(i) * 7.0, 7.0 + float(i % 2) * 2.0, -5.0)
		add_child(g)
	var coins: Array[Vector3] = [Vector3(1.0, 1, 0), Vector3(6.5, 1, 0), Vector3(11.5, 1, 0), Vector3(16.5, 1, 0), Vector3(26.8, 5.0, 0), Vector3(30.0, 1, 0)]
	for i in coins.size():
		b.pickup("mecatron_18_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	boss.save = save
	triad.link(boss, rig)
	boss.defeated.connect(_on_defeated)
	shield.activated.connect(func(_m: Mechanism) -> void: boss.mechanism_done(&"shield"))
	if _progress.is_seed_destroyed(save, planet):
		boss.restore(null)
		_apply_victory_state()


func _physics_process(_delta: float) -> void:
	if boss == null:
		return
	if boss.phase == VyrkanBoss.Phase.ONE and power_a.is_active and power_b.is_active:
		boss.mechanism_done(&"power")
	if boss.phase == VyrkanBoss.Phase.TWO and anchor.progress >= 1.0:
		boss.mechanism_done(&"anchors")
	_derive_enabled()


## Cada mecanismo so e interagivel na sua fase (estado derivado da fase, nunca guardado a parte).
func _derive_enabled() -> void:
	if boss.is_defeated():
		return
	power_a.enabled = boss.phase == VyrkanBoss.Phase.ONE
	power_b.enabled = boss.phase == VyrkanBoss.Phase.ONE
	anchor.control.enabled = boss.phase == VyrkanBoss.Phase.TWO
	shield.enabled = boss.phase == VyrkanBoss.Phase.THREE


func _on_defeated() -> void:
	var result: Dictionary = _progress.commit_seed(save, planet, RELIC_ID, MEMORY_ID)
	_apply_victory_state()
	seed_destroyed.emit(result["first_time"])


func _apply_victory_state() -> void:
	chest.locked = false
	for m in [power_a, power_b, shield, anchor.control]:
		m.enabled = false


func _switch(id: StringName, pos: Vector3) -> Mechanism:
	var m := Mechanism.new()
	m.mechanism_id = id
	m.hold_time = 8.0
	m.prompt_text = "Pressione E para desligar o sistema de energia"
	m.position = pos
	add_child(m)
	return m
