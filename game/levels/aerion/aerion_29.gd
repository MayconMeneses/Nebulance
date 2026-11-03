class_name AerionLevel29
extends LevelScene
## FASE 29 — O Observatorio Celestial (Aerion). Visual PROVISORIO. Combina vento, gravidade e rota: tres "coordenadas" (mecanismos)
## so se alcancam vencendo um desafio ja aprendido (vento de popa, inversao de gravidade e planeio com corrente). O console narrativo
## so responde com as tres coordenadas ligadas; ele constroi a ponte da rota para o planeta final. Checkpoint antes do console.
## Recompensa: bau especial, memoria quase completa da primeira expedicao e a previa de Umbraxis.

const DEFINITION: String = "res://game/levels/aerion/aerion_29_definition.tres"

var tailwind: WindVent
var gravity_zone: LevelZone
var lift: WindVent
var coord_wind: Mechanism
var coord_gravity: Mechanism
var coord_route: Mechanism
var console: Mechanism
var bridge: ControlledPlatform
var chest: Chest


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var stone := Color("7FA6C4")
	var violet := Color(0.6, 0.35, 1.0, 0.12)
	b.solid(Vector3(4.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), stone)
	# Desafio 1 (vento de popa): vao de 7 m.
	tailwind = WindVent.new()
	tailwind.size = Vector3(7.0, 8.0, 3.0)
	tailwind.wind_on = Vector3(40.0, 0.0, 0.0)
	tailwind.position = Vector3(17.5, 2.0, 0.0)
	add_child(tailwind)
	b.solid(Vector3(31.5, -0.5, 0.0), Vector3(21.0, 1.0, 4.0), stone)
	coord_wind = _coord(&"aerion_29_coord_wind", Vector3(30.0, 0.8, 0.0), "Pressione E para fixar a coordenada do vento")
	# Desafio 2 (gravidade invertida): poco de 10 m pelo teto.
	gravity_zone = b.zone(PhysicsLayers.WIND, "invert_29", Vector3(47.0, 3.5, 0.0), Vector3(10.0, 11.0, 3.0), violet, Vector3.ZERO, -0.7)
	b.solid(Vector3(47.0, 6.5, 0.0), Vector3(12.0, 1.0, 4.0), Color("9A8FD0"))
	b.solid(Vector3(61.0, -0.5, 0.0), Vector3(18.0, 1.0, 4.0), stone)
	coord_gravity = _coord(&"aerion_29_coord_gravity", Vector3(58.0, 0.8, 0.0), "Pressione E para fixar a coordenada da gravidade")
	# Desafio 3 (planeio com corrente): lacuna de 9 m.
	lift = WindVent.new()
	lift.size = Vector3(9.0, 12.0, 3.0)
	lift.position = Vector3(74.5, 1.25, 0.0)
	add_child(lift)
	b.solid(Vector3(87.5, -0.5, 0.0), Vector3(17.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.CHECKPOINT, "aerion_29_cp1", Vector3(81.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.93, 0.72, 0.37, 0.25))
	coord_route = _coord(&"aerion_29_coord_route", Vector3(84.0, 0.8, 0.0), "Pressione E para fixar a coordenada da rota")
	# Console narrativo (so responde com as tres coordenadas) e a ponte da rota ate o planeta final.
	console = Mechanism.new()
	console.mechanism_id = &"aerion_29_console"
	console.prompt_text = "Pressione E para ler o registro dos exploradores"
	console.position = Vector3(92.0, 0.8, 0.0)
	console.enabled = false
	add_child(console)
	bridge = ControlledPlatform.new()
	bridge.size = Vector3(10.0, 0.5, 3.0)
	bridge.position = Vector3(101.0, -0.25, 0.0)
	bridge.control = console
	add_child(bridge)
	b.solid(Vector3(113.0, -0.5, 0.0), Vector3(14.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.ABYSS, "sky_29", Vector3(60.0, -9.0, 0.0), Vector3(150.0, 3.0, 4.0), Color(0.1, 0.1, 0.3, 0.2))
	b.pickup("memory_first_expedition_29", Pickup.Kind.MEMORY, Vector3(109.0, 1.0, 0.0))
	b.pickup("aerion_29_umbraxis_preview", Pickup.Kind.ITEM, Vector3(112.0, 1.0, 0.0))
	chest = b.chest("aerion_29_chest", Vector3(116.0, 0.6, 0.0))
	# Observatorio (decoracao) e previa sombria de Umbraxis ao fundo.
	b.decor(Vector3(92.0, 5.0, -3.5), Vector3(8.0, 6.0, 2.0), Color("D9E4F2"), true)
	b.decor(Vector3(92.0, 9.0, -3.5), Vector3(4.0, 1.4, 2.0), Color("EDB85E"), true)
	b.decor(Vector3(116.0, 6.0, -5.0), Vector3(5.0, 5.0, 1.0), Color("C03CA8"), true)
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(12, 1, 0), Vector3(26, 1, 0), Vector3(36, 1, 0), Vector3(47, 5.0, 0),
			Vector3(56, 1, 0), Vector3(65, 1, 0), Vector3(88, 1, 0), Vector3(103, 1, 0)]
	for i in coins.size():
		b.pickup("aerion_29_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _physics_process(_delta: float) -> void:
	if console == null:
		return
	# O console so responde com as tres coordenadas ligadas (estado derivado dos mecanismos, que sao capturados).
	console.enabled = coord_wind.is_active and coord_gravity.is_active and coord_route.is_active


func _coord(id: StringName, pos: Vector3, prompt: String) -> Mechanism:
	var m := Mechanism.new()
	m.mechanism_id = id
	m.prompt_text = prompt
	m.position = pos
	add_child(m)
	return m
