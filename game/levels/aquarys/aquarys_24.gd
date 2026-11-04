class_name AquarysLevel24
extends LevelScene
## FASE 24 — Thalassa, a Vitoria-Regia (Aquarys): arena do guardiao. Visual PROVISORIO. Tres fases, cada uma encerrada por uma etapa
## propria: 1) estabilizar o fluxo (Oeste no nivel 2 e Leste no nivel 1; a comporta-isca do Leste leva ao nivel errado);
## 2) a onda ergue a folha flutuante (FloatingPlatform) com o heroi ate o patamar; 3) desativar a protecao da semente no alto.
## Depois, o Golpe Triade com tres herois. A semente e uma transacao unica (ProgressLedger); as aguas reiniciam de forma
## deterministica no checkpoint (os reservatorios sao snapshotable).

signal seed_destroyed(first_time: bool)

const DEFINITION: String = "res://game/levels/aquarys/aquarys_24_definition.tres"
const RELIC_ID: String = "relic_aquarys"
const MEMORY_ID: String = "astralis_memory_aquarys"
const TRIAD_POSITIONS: Array[Vector3] = [Vector3(6.5, 0.8, 0.0), Vector3(11.5, 0.8, 0.0), Vector3(16.5, 0.8, 0.0)]
## Combinacao de niveis do fluxo (Oeste, Leste).
const WEST_LEVEL: int = 2
const EAST_LEVEL: int = 1

var reaction_message: String = "CAELDRON\nSente MEDO ao perder a quarta raiz: as mares lhe escapam."
var boss: ThalassaBoss
var triad: TriadFinisher
var west: WaterBody
var east: WaterBody
var wave: WaterBody
var west_gate: SluiceControl
var east_gate: SluiceControl
var east_decoy: SluiceControl
var wave_gate: SluiceControl
var flux: TideFlux
var leaf: FloatingPlatform
var shield: Mechanism
var chest: Chest
var planet: PlanetDefinition

var _progress: ProgressLedger = ProgressLedger.new()


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	planet = GalaxyState.planets()[3]
	var stone := Color("3E6E8C")
	b.solid(Vector3(15.0, -0.5, 0.0), Vector3(38.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.CHECKPOINT, "aquarys_24_cp1", Vector3(0.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.14, 0.81, 0.96, 0.2))
	boss = ThalassaBoss.new()
	boss.seed_id = planet.seed_id
	add_child(boss)
	# Etapa 1: dois reservatorios (atras da arena) e o fluxo; a combinacao correta e Oeste 2 + Leste 1.
	west = _pool(Vector3(1.5, 0.0, -3.2))
	east = _pool(Vector3(9.0, 0.0, -3.2))
	west_gate = _gate(west, 1.5, 2, "Oeste")
	east_gate = _gate(east, 6.5, 1, "Leste")
	east_decoy = _gate(east, 11.5, 2, "Leste")
	flux = TideFlux.new()
	flux.blocks = false
	flux.position = Vector3(5.5, 3.2, -3.2)
	add_child(flux)
	flux.require_level(west, WEST_LEVEL, Vector3(1.5, 3.2, -2.6))
	flux.require_level(east, EAST_LEVEL, Vector3(9.0, 3.2, -2.6))
	# Etapa 2: a onda (reservatorio com degraus de 2 m) ergue a folha flutuante; ao nivel 0 ela fica rente ao chao.
	wave = WaterBody.new()
	wave.step = 2.0
	wave.rise_speed = 2.0
	wave.surface_size = Vector2(5.0, 3.0)
	wave.position = Vector3(21.5, 0.0, -3.2)
	add_child(wave)
	leaf = FloatingPlatform.new()
	leaf.water = wave
	leaf.offset = 1.0
	leaf.size = Vector3(4.0, 0.4, 3.0)
	leaf.position = Vector3(21.5, 0.0, 0.0)
	add_child(leaf)
	wave_gate = SluiceControl.new()
	wave_gate.water = wave
	wave_gate.target_level = 2
	wave_gate.prompt_text = "Pressione E para chamar a onda"
	wave_gate.position = Vector3(0.0, 1.0, 0.0)
	leaf.add_child(wave_gate)
	# Etapa 3: protecao da semente no patamar alto.
	b.solid(Vector3(26.0, 3.5, 0.0), Vector3(5.0, 1.0, 4.0), stone)
	shield = Mechanism.new()
	shield.mechanism_id = &"aquarys_24_shield"
	shield.prompt_text = "Pressione E para desativar a protecao da semente"
	shield.position = Vector3(26.0, 4.8, 0.0)
	add_child(shield)
	triad = TriadFinisher.new()
	add_child(triad)
	var spots: Array[Vector3] = TRIAD_POSITIONS
	triad.build(spots)
	chest = b.chest("aquarys_24_chest", Vector3(32.0, 0.6, 0.0))
	chest.locked = true
	var coins: Array[Vector3] = [Vector3(1.0, 1, 0), Vector3(6.5, 1, 0), Vector3(11.5, 1, 0), Vector3(16.5, 1, 0), Vector3(27.5, 5.0, 0), Vector3(30.0, 1, 0)]
	for i in coins.size():
		b.pickup("aquarys_24_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


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
	if boss.phase == VyrkanBoss.Phase.ONE and flux.is_lit():
		boss.mechanism_done(&"flux")
	if boss.phase == VyrkanBoss.Phase.TWO and wave.level == 2 and wave.is_settled():
		boss.mechanism_done(&"leaves")
	_derive_enabled()


## Cada comporta/mecanismo so e interagivel na sua fase (estado derivado da fase, nunca guardado a parte).
func _derive_enabled() -> void:
	if boss.is_defeated():
		return
	var one: bool = boss.phase == VyrkanBoss.Phase.ONE
	west_gate.enabled = one
	east_gate.enabled = one
	east_decoy.enabled = one
	wave_gate.enabled = boss.phase == VyrkanBoss.Phase.TWO
	shield.enabled = boss.phase == VyrkanBoss.Phase.THREE


func _on_defeated() -> void:
	var result: Dictionary = _progress.commit_seed(save, planet, RELIC_ID, MEMORY_ID)
	_apply_victory_state()
	seed_destroyed.emit(result["first_time"])


func _apply_victory_state() -> void:
	chest.locked = false
	shield.enabled = false
	for g in [west_gate, east_gate, east_decoy, wave_gate]:
		g.enabled = false


func _pool(pos: Vector3) -> WaterBody:
	var w := WaterBody.new()
	w.surface_size = Vector2(6.0, 2.4)
	w.position = pos
	add_child(w)
	return w


func _gate(w: WaterBody, x: float, level: int, side: String) -> SluiceControl:
	var c := SluiceControl.new()
	c.water = w
	c.target_level = level
	c.prompt_text = "Pressione E para levar a Comporta %s ao nivel %d" % [side, level]
	c.position = Vector3(x, 0.8, 0.0)
	add_child(c)
	return c
