class_name UmbraxisLevel35
extends LevelScene
## FASE 35 — A Ultima Mensagem (Umbraxis). Visual PROVISORIO. Puzzle-sintese das cinco mecanicas, em ordem: ponte de ruptura estabilizada
## (Sylvara), plataforma movel (Cristalia), esteira e elevadores de polaridade (Mecatron), mare (Aquarys) e muro + planeio (Aerion). No fim,
## o terminal dos exploradores: ativa-lo destranca o bau e a mensagem (ultimo registro) esclarece a sexta semente. O checkpoint vem DEPOIS
## da mensagem e antes do chefe. Acessibilidade: com "reduzir movimento" a plataforma movel vira ponte fixa.

const DEFINITION: String = "res://game/levels/umbraxis/umbraxis_35_definition.tres"
const OX_BRIDGE: float = 0.0
const OX_MOVING: float = 45.5
const OX_BELT: float = 79.5
const OX_TIDE: float = 122.5
const OX_GLIDE: float = 162.5
const TERMINAL_X: float = 200.0

var bridge_mod: Dictionary
var moving_mod: Dictionary
var belt_mod: Dictionary
var tide_mod: Dictionary
var glide_mod: Dictionary
var terminal: Mechanism
var chest: Chest
var assisted: bool = false


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	assisted = Accessibility.reduce_motion
	bridge_mod = UmbraxisModules.bridge(self, b, OX_BRIDGE, &"synth_bridge")
	moving_mod = UmbraxisModules.moving(self, b, OX_MOVING, assisted)
	belt_mod = UmbraxisModules.belt_lift(self, b, OX_BELT)
	tide_mod = UmbraxisModules.tide(self, b, OX_TIDE)
	glide_mod = UmbraxisModules.glide(self, b, OX_GLIDE)
	b.solid(Vector3(208.25, -0.5, 0.0), Vector3(23.5, 1.0, 4.0), Color("3A2F55"))
	terminal = Mechanism.new()
	terminal.mechanism_id = &"umbraxis_35_terminal"
	terminal.prompt_text = "Pressione E para ler o terminal dos exploradores"
	terminal.position = Vector3(TERMINAL_X, 0.8, 0.0)
	add_child(terminal)
	b.pickup("memory_last_message_35", Pickup.Kind.MEMORY, Vector3(203.0, 1.0, 0.0))
	b.zone(PhysicsLayers.CHECKPOINT, "umbraxis_35_cp5", Vector3(206.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.75, 0.24, 0.66, 0.25))
	chest = b.chest("umbraxis_35_chest", Vector3(212.0, 0.6, 0.0))
	chest.locked = true
	var cp_x: Array[float] = [47.0, 82.0, 124.0, 164.0]
	for i in cp_x.size():
		b.zone(PhysicsLayers.CHECKPOINT, "umbraxis_35_cp%d" % (i + 1), Vector3(cp_x[i], 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.75, 0.24, 0.66, 0.25))
	for x in range(10, 220, 30):
		b.decor(Vector3(float(x), 5.0, -5.0), Vector3(0.8, 10.0, 0.8), Color("C03CA8"), true)
	b.decor(Vector3(TERMINAL_X, 2.2, -2.0), Vector3(2.4, 3.2, 0.4), Color("23CFF5"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(28, 1, 0), Vector3(40, 1, 0), Vector3(74.5, 1, 0), Vector3(92, 1, 0),
			Vector3(112, 5.0, 0), Vector3(144.5, 1, 0), Vector3(190.5, 4.0, 0), Vector3(205, 1, 0)]
	for i in coins.size():
		b.pickup("umbraxis_35_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _physics_process(_delta: float) -> void:
	if chest != null and terminal != null:
		# Estado derivado do terminal (que e snapshotable): nunca guardado a parte.
		chest.locked = not terminal.is_active
