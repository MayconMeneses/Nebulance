class_name UmbraxisLevel32
extends LevelScene
## FASE 32 — As Fases Quebradas (Umbraxis). Visual PROVISORIO. Cinco modulos de ecossistemas anteriores, unidos por rupturas (vazios e
## checkpoints): Sylvara (barreira de Rocco), Cristalia (plataforma movel), Mecatron (esteira e elevadores de polaridade), Aquarys (mare) e
## Aerion (muro, corrente de ar e planeio). Cada modulo e construido pelo UmbraxisModules (so um conjunto de nos por vez no mundo; os
## checkpoints entre modulos evitam depender do trecho anterior). Registro oculto na passarela do planeio.

const DEFINITION: String = "res://game/levels/umbraxis/umbraxis_32_definition.tres"
const OX_BARRIER: float = 0.0
const OX_MOVING: float = 20.0
const OX_BELT: float = 54.0
const OX_TIDE: float = 97.0
const OX_GLIDE: float = 137.0

var barrier_mod: Dictionary
var moving_mod: Dictionary
var belt_mod: Dictionary
var tide_mod: Dictionary
var glide_mod: Dictionary


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	barrier_mod = UmbraxisModules.barrier(self, b, OX_BARRIER)
	moving_mod = UmbraxisModules.moving(self, b, OX_MOVING)
	belt_mod = UmbraxisModules.belt_lift(self, b, OX_BELT)
	tide_mod = UmbraxisModules.tide(self, b, OX_TIDE)
	glide_mod = UmbraxisModules.glide(self, b, OX_GLIDE)
	b.solid(Vector3(178.0, -0.5, 0.0), Vector3(14.0, 1.0, 4.0), Color("3A2F55"))
	b.chest("umbraxis_32_chest", Vector3(180.0, 0.6, 0.0))
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
