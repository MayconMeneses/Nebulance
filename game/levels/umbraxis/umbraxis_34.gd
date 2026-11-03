class_name UmbraxisLevel34
extends LevelScene
## FASE 34 — A Estrada para o Coracao (Umbraxis). Visual PROVISORIO. Ascensao em dois lances rumo ao nucleo: uma prensa-raiz com aviso
## (ataque sinalizado), a barreira que Caeldron enfraquecido tenta usar para bloquear a estrada (so cede ao impacto de Rocco), o checkpoint
## ANTES do trecho dificil, a escalada de Zuri, plataformas temporarias (de ruptura, com aviso) e a segunda escalada ate o bau.
## Resgate opcional no meio da subida. O espelho de cosmeticos (interativo) troca o visual do heroi ativo entre o original e os cosmeticos possuidos (so a cor).

const DEFINITION: String = "res://game/levels/umbraxis/umbraxis_34_definition.tres"

var press: HydraulicPress
var barrier: ImpactBarrier
var platforms: Array[RupturePlatform] = []
var survivor: Rescue
var mirror: CosmeticMirror


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var rock := Color("3A2F55")
	b.solid(Vector3(22.0, -0.5, 0.0), Vector3(52.0, 1.0, 4.0), rock)
	press = HydraulicPress.new()
	press.position = Vector3(14.0, 0.0, 0.0)
	add_child(press)
	b.decor(Vector3(14.0, 6.0, -1.8), Vector3(4.0, 0.6, 0.6), Color("5B1F4F"), true)
	barrier = b.barrier(Vector3(26.0, 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	b.zone(PhysicsLayers.CHECKPOINT, "umbraxis_34_cp1", Vector3(34.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.75, 0.24, 0.66, 0.25))
	# Primeiro lance: escalada (Zuri) ate o patamar a 5 m.
	b.zone(PhysicsLayers.CLIMBABLE, "climb_34a", Vector3(40.0, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(43.6, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("6B4A8F"))
	# Plataformas temporarias (com aviso) sobre o vazio.
	for i in 3:
		var p := RupturePlatform.new()
		p.position = Vector3(50.0 + 4.5 * i, 4.8, 0.0)
		p.phase_offset = 0.0 if i % 2 == 0 else 2.1
		p.solid_time = 3.0
		p.gone_time = 1.2
		add_child(p)
		platforms.append(p)
	b.solid(Vector3(66.0, 4.75, 0.0), Vector3(10.0, 0.5, 4.0), Color("6B4A8F"))
	b.zone(PhysicsLayers.ABYSS, "void_34", Vector3(60.0, -7.0, 0.0), Vector3(60.0, 3.0, 4.0), Color(0.5, 0.0, 0.3, 0.2))
	survivor = Rescue.new()
	survivor.rescue_id = &"umbraxis_34_survivor"
	survivor.position = Vector3(64.0, 5.8, 0.0)
	add_child(survivor)
	# Segundo lance: escalada ate o patamar final a 10 m.
	b.zone(PhysicsLayers.CLIMBABLE, "climb_34b", Vector3(68.0, 7.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(71.6, 9.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("8C6BC4"))
	b.chest("umbraxis_34_chest", Vector3(73.2, 10.6, 0.0))
	# Espelho de cosmeticos (interativo, no patamar final) e raizes colossais ao fundo.
	mirror = CosmeticMirror.new()
	mirror.position = Vector3(70.0, 11.1, 0.0)
	add_child(mirror)
	for x in range(-2, 80, 9):
		b.decor(Vector3(float(x), 6.0, -5.5), Vector3(2.0, 12.0 + float(x % 3) * 2.0, 2.0), Color("5B1F4F"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(10, 1, 0), Vector3(22, 1, 0), Vector3(38, 1, 0), Vector3(43.6, 6.0, 0),
			Vector3(54.5, 6.0, 0), Vector3(66, 6.0, 0), Vector3(70.2, 11.0, 0), Vector3(72.0, 11.0, 0)]
	for i in coins.size():
		b.pickup("umbraxis_34_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	mirror.bind(save, rig, visual)
