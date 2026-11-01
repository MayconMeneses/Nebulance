class_name AquarysLevel23
extends LevelScene
## FASE 23 — O Templo das Mares (Aquarys). Visual PROVISORIO. Sala central com DOIS reservatorios independentes (Oeste e Leste), comportas,
## plataformas flutuantes e um fluxo luminoso. A comporta alta do Oeste leva ao templo (checkpoint); ali e preciso combinar os niveis:
## Oeste no nivel 1 e Leste no nivel 2 acendem o fluxo e abrem a porta. Sem fisica de fluidos: cada nivel e discreto.
## Depois da porta: bau especial, a memoria antiga (raizes ligadas as sementes) e a entrada para Thalassa.

const DEFINITION: String = "res://game/levels/aquarys/aquarys_23_definition.tres"
## Combinacao correta (nivel do Oeste, nivel do Leste).
const WEST_LEVEL: int = 1
const EAST_LEVEL: int = 2

var west: WaterBody
var east: WaterBody
var west_raise: SluiceControl
var west_mid: SluiceControl
var west_low: SluiceControl
var east_mid: SluiceControl
var east_high: SluiceControl
var flux: TideFlux
var chest: Chest
var floaters: Array[FloatingPlatform] = []


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var stone := Color("5B7C99")
	b.solid(Vector3(7.0, -0.5, 0.0), Vector3(14.0, 1.0, 4.0), stone)
	west = _pool(Vector3(20.0, 0.0, 0.0), [16.0, 20.0, 24.0])
	west_raise = _control(west, 12.0, 2, "Oeste")
	# Templo central (checkpoint logo na entrada, antes do puzzle final).
	b.solid(Vector3(40.0, -0.5, 0.0), Vector3(28.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.CHECKPOINT, "aquarys_23_cp1", Vector3(28.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.14, 0.81, 0.96, 0.25))
	east = _pool(Vector3(60.0, 0.0, 0.0), [56.0, 60.0, 64.0])
	west_mid = _control(west, 31.0, 1, "Oeste")
	west_low = _control(west, 33.5, 0, "Oeste")
	east_mid = _control(east, 40.0, 1, "Leste")
	east_high = _control(east, 43.0, 2, "Leste")
	flux = TideFlux.new()
	flux.position = Vector3(70.0, 1.6, 0.0)
	add_child(flux)
	flux.require_level(west, WEST_LEVEL, Vector3(32.0, 3.6, -1.6))
	flux.require_level(east, EAST_LEVEL, Vector3(41.5, 3.6, -1.6))
	b.solid(Vector3(82.0, -0.5, 0.0), Vector3(32.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.ABYSS, "sea_23", Vector3(45.0, -7.0, 0.0), Vector3(120.0, 3.0, 4.0), Color(0.0, 0.2, 0.4, 0.3))
	b.pickup("memory_ancient_roots_23", Pickup.Kind.MEMORY, Vector3(85.0, 1.0, 0.0))
	chest = b.chest("aquarys_23_chest", Vector3(90.0, 0.6, 0.0))
	# Entrada para Thalassa: arco luminoso no fim do templo (a travessia e a conclusao da fase).
	b.decor(Vector3(94.0, 2.5, -1.8), Vector3(0.8, 5.0, 0.8), Color("7FE9F5"), true)
	b.decor(Vector3(98.0, 2.5, -1.8), Vector3(0.8, 5.0, 0.8), Color("7FE9F5"), true)
	b.decor(Vector3(96.0, 5.2, -1.8), Vector3(5.6, 0.6, 0.8), Color("23CFF5"), true)
	for x in range(-4, 100, 8):
		b.decor(Vector3(float(x), 2.5, -4.0), Vector3(0.6, 5.0, 0.6), Color("7FE9F5"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(11, 1, 0), Vector3(19, 1, 0), Vector3(24, 1, 0), Vector3(30, 1, 0),
			Vector3(37, 1, 0), Vector3(47, 1, 0), Vector3(62, 1, 0), Vector3(76, 1, 0)]
	for i in coins.size():
		b.pickup("aquarys_23_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _pool(pos: Vector3, floater_xs: Array) -> WaterBody:
	var w := WaterBody.new()
	w.surface_size = Vector2(12.0, 3.4)
	w.position = pos
	add_child(w)
	for cx in floater_xs:
		var f := FloatingPlatform.new()
		f.water = w
		f.offset = -0.2
		f.position = Vector3(cx, 0.0, 0.0)
		add_child(f)
		floaters.append(f)
	return w


func _control(w: WaterBody, x: float, level: int, side: String) -> SluiceControl:
	var c := SluiceControl.new()
	c.water = w
	c.target_level = level
	c.prompt_text = "Pressione E para levar a Comporta %s ao nivel %d" % [side, level]
	c.position = Vector3(x, 0.8, 0.0)
	add_child(c)
	return c
