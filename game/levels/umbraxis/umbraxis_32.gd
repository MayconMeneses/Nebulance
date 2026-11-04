class_name UmbraxisLevel32
extends LevelScene
## FASE 32 — As Fases Quebradas (Umbraxis). Visual PROVISORIO. Cinco modulos de ecossistemas anteriores, unidos por rupturas (vazios e
## checkpoints): Sylvara (barreira de Rocco), Cristalia (plataforma movel), Mecatron (esteira e elevadores de polaridade), Aquarys (mare) e
## Aerion (muro, corrente de ar e planeio). Os modulos sao CARREGADOS E DESCARREGADOS de verdade (ModuleStreamer): so ficam no mundo os
## que o heroi pode alcancar a partir do ultimo checkpoint (plano por checkpoint, no maximo 3 ao mesmo tempo), e o reinicio da fase recria
## os do comeco. Segredos: registro oculto na passarela do planeio e o ATALHO DIMENSIONAL (fenda numa plataforma alta do modulo de Cristalia,
## so alcancavel com o salto duplo de Zuri) que leva direto ao modulo de Aquarys, pulando a esteira (e as moedas dela).

const DEFINITION: String = "res://game/levels/umbraxis/umbraxis_32_definition.tres"
const OX_BARRIER: float = 0.0
const OX_MOVING: float = 20.0
const OX_BELT: float = 54.0
const OX_TIDE: float = 97.0
const OX_GLIDE: float = 137.0
## Modulos carregados por checkpoint (indice = ordem acima). Sempre inclui o modulo onde o heroi esta e o que ele pisa a seguir.
const PLAN: Dictionary = {&"start": [0, 1], &"umbraxis_32_cp1": [1, 2], &"umbraxis_32_cp2": [1, 2, 3], &"umbraxis_32_cp3": [3, 4], &"umbraxis_32_cp4": [4]}
## O atalho carrega o modulo de destino (3) sem descarregar o atual (1) ate o checkpoint do destino assumir.
const SHORTCUT_SET: Array = [1, 3]
const SHORTCUT_EXIT: Vector3 = Vector3(99.0, 1.0, 0.0)
const SHORTCUT_X: float = OX_MOVING + 6.5

var barrier_mod: Dictionary
var moving_mod: Dictionary
var belt_mod: Dictionary
var tide_mod: Dictionary
var glide_mod: Dictionary
var streamer: ModuleStreamer
## So existe enquanto o modulo de Cristalia esta carregado.
var shortcut: DimensionalShortcut


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	streamer = ModuleStreamer.new()
	streamer.world = self
	streamer.builder = b
	add_child(streamer)
	streamer.add_module(OX_BARRIER, _load_barrier)
	streamer.add_module(OX_MOVING, _load_moving)
	streamer.add_module(OX_BELT, _load_belt)
	streamer.add_module(OX_TIDE, _load_tide)
	streamer.add_module(OX_GLIDE, _load_glide)
	streamer.set_loaded(PLAN[&"start"])
	b.solid(Vector3(178.0, -0.5, 0.0), Vector3(14.0, 1.0, 4.0), Color("3A2F55"))
	b.chest("umbraxis_32_chest", Vector3(180.0, 0.6, 0.0))
	# Rede de seguranca: sem os modulos de tras, cair em qualquer ponto do vazio reaparece no checkpoint.
	b.zone(PhysicsLayers.ABYSS, "umbraxis_32_void", Vector3(92.0, -14.0, 0.0), Vector3(240.0, 3.0, 4.0), Color(0.0, 0.0, 0.0, 0.0))
	var cp_x: Array[float] = [22.0, 51.0, 99.0, 139.0]
	for i in cp_x.size():
		b.zone(PhysicsLayers.CHECKPOINT, "umbraxis_32_cp%d" % (i + 1), Vector3(cp_x[i], 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.75, 0.24, 0.66, 0.25))
	# Rupturas entre os modulos: fendas luminosas ao fundo.
	for x in range(18, 180, 34):
		b.decor(Vector3(float(x), 5.0, -5.0), Vector3(0.8, 10.0, 0.8), Color("C03CA8"), true)
		b.decor(Vector3(float(x) + 1.5, 7.0, -5.0), Vector3(0.5, 6.0, 0.5), Color("FFE14A"), true)
	b.pickup("memory_hidden_record_32", Pickup.Kind.MEMORY, Vector3(166.5, 4.0, 0.0))
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(28, 1, 0), Vector3(50, 1, 0), Vector3(58, 1, 0), Vector3(86, 5.0, 0),
			Vector3(106, 1, 0), Vector3(119, 1, 0), Vector3(165, 4.0, 0), Vector3(176, 1, 0)]
	for i in coins.size():
		b.pickup("umbraxis_32_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	controller.before_checkpoint.connect(func(zone_id: StringName) -> void: streamer.set_loaded(PLAN.get(zone_id, streamer.loaded_indices())))
	controller.before_restart.connect(func() -> void: streamer.set_loaded(PLAN[&"start"]))


## Atalho: carrega o modulo de destino e leva o heroi ate o checkpoint dele (que descarrega os de tras).
func take_shortcut() -> void:
	streamer.set_loaded(SHORTCUT_SET)
	rig.body.global_position = SHORTCUT_EXIT
	rig.body.velocity = Vector3.ZERO


func _load_barrier(c: Node3D, b: SegmentBuilder, ox: float) -> void:
	barrier_mod = UmbraxisModules.barrier(c, b, ox)


func _load_moving(c: Node3D, b: SegmentBuilder, ox: float) -> void:
	moving_mod = UmbraxisModules.moving(c, b, ox)
	b.solid(Vector3(SHORTCUT_X, 2.3, 0.0), Vector3(3.0, 0.2, 3.0), Color("7C6BC4"))
	shortcut = DimensionalShortcut.new()
	shortcut.position = Vector3(SHORTCUT_X, 3.6, 0.0)
	c.add_child(shortcut)
	shortcut.used.connect(func(_s: DimensionalShortcut) -> void: take_shortcut())


func _load_belt(c: Node3D, b: SegmentBuilder, ox: float) -> void:
	belt_mod = UmbraxisModules.belt_lift(c, b, ox)


func _load_tide(c: Node3D, b: SegmentBuilder, ox: float) -> void:
	tide_mod = UmbraxisModules.tide(c, b, ox)


func _load_glide(c: Node3D, b: SegmentBuilder, ox: float) -> void:
	glide_mod = UmbraxisModules.glide(c, b, ox)
