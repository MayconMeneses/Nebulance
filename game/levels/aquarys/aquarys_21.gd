class_name AquarysLevel21
extends LevelScene
## FASE 21 — Os Recifes Esquecidos (Aquarys). Visual PROVISORIO. Correntes de agua (esteiras: uma a favor, outra contra) levam ao recife,
## onde fica o checkpoint. Alem dele, plataformas transparentes (de ruptura) so ficam estaveis depois de ligar os mecanismos antigos.
## No recife, uma inscricao no alto (Zuri escala) revela o portal secreto para a S04 (Oceano Esquecido). Descoberta: o arquivo do primeiro explorador.

const DEFINITION: String = "res://game/levels/aquarys/aquarys_21_definition.tres"

var water: WaterBody
var current_with: ConveyorBelt
var current_against: ConveyorBelt
var stabilizer_a: Mechanism
var stabilizer_b: Mechanism
var inscription: Mechanism
var portal: Portal
var reef_platforms: Array[RupturePlatform] = []


func _definition_path() -> String:
	return DEFINITION


func _build_geometry(b: SegmentBuilder) -> void:
	var stone := Color("4F7C8C")
	water = WaterBody.new()
	water.surface_size = Vector2(130.0, 3.4)
	water.position = Vector3(70.0, 0.0, 0.0)
	add_child(water)
	b.solid(Vector3(9.0, -0.5, 0.0), Vector3(26.0, 1.0, 4.0), stone)
	current_with = _current(Vector3(28.0, -0.2, 0.0), 12.0, 1.0)
	b.solid(Vector3(38.0, -0.5, 0.0), Vector3(8.0, 1.0, 4.0), stone)
	current_against = _current(Vector3(48.0, -0.2, 0.0), 12.0, -1.0)
	# Recife: checkpoint ao alcanca-lo, escalada ate a inscricao e o primeiro mecanismo antigo.
	b.solid(Vector3(64.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), Color("5E8F8A"))
	b.zone(PhysicsLayers.CHECKPOINT, "aquarys_21_cp1", Vector3(57.0, 2.0, 0.0), Vector3(1.0, 4.0, 3.0), Color(0.14, 0.81, 0.96, 0.25))
	b.zone(PhysicsLayers.CLIMBABLE, "climb_21", Vector3(60.0, 2.75, 0.0), Vector3(1.2, 5.5, 3.0), Color(0.3, 0.9, 0.4, 0.3))
	b.solid(Vector3(63.6, 4.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("7FA6C4"))
	inscription = Mechanism.new()
	inscription.mechanism_id = &"aquarys_21_inscription"
	inscription.prompt_text = "Pressione E para ler a inscricao do recife"
	inscription.position = Vector3(64.0, 5.8, 0.0)
	add_child(inscription)
	stabilizer_a = _stabilizer(Vector3(70.0, 0.8, 0.0), &"reef_a", &"aquarys_21_stab_a")
	for i in 4:
		_reef_platform(77.5 + 4.5 * i, 0.0 if i % 2 == 0 else 2.1, &"reef_a")
	b.solid(Vector3(99.5, -0.5, 0.0), Vector3(13.0, 1.0, 4.0), stone)
	stabilizer_b = _stabilizer(Vector3(96.0, 0.8, 0.0), &"reef_b", &"aquarys_21_stab_b")
	for i in 2:
		_reef_platform(109.5 + 4.5 * i, 0.0 if i % 2 == 0 else 2.1, &"reef_b")
	b.solid(Vector3(129.0, -0.5, 0.0), Vector3(26.0, 1.0, 4.0), stone)
	b.zone(PhysicsLayers.ABYSS, "sea_21", Vector3(70.0, -7.0, 0.0), Vector3(140.0, 3.0, 4.0), Color(0.0, 0.2, 0.4, 0.3))
	b.chest("aquarys_21_chest", Vector3(122.0, 0.6, 0.0))
	b.pickup("memory_first_explorer_21", Pickup.Kind.MEMORY, Vector3(126.5, 1.0, 0.0))
	portal = Portal.new()
	portal.portal_id = &"aquarys_21_portal"
	portal.destination_level_id = &"aquarys_s04"
	portal.requires_open = true
	portal.position = Vector3(131.0, 1.2, 0.0)
	add_child(portal)
	# Decoracao de recife: colunas de coral emissivas ao fundo e um casco afundado.
	for x in range(-4, 140, 9):
		b.decor(Vector3(float(x), 2.0 + float(x % 3), -4.0), Vector3(0.9, 4.0 + float(x % 3) * 2.0, 0.9), Color("F2788F") if x % 2 == 0 else Color("7FE9F5"), true)
	b.decor(Vector3(88.0, 4.0, -6.0), Vector3(14.0, 1.2, 2.0), Color("3C3A52"))
	b.decor(Vector3(86.0, 7.0, -6.0), Vector3(0.6, 6.0, 0.6), Color("3C3A52"))
	var coins: Array[Vector3] = [Vector3(6, 1, 0), Vector3(14, 1, 0), Vector3(28, 1, 0), Vector3(38, 1, 0), Vector3(48, 1, 0),
			Vector3(62.5, 6.0, 0), Vector3(82, 1, 0), Vector3(100, 1, 0), Vector3(114, 1, 0)]
	for i in coins.size():
		b.pickup("aquarys_21_coin_%02d" % (i + 1), Pickup.Kind.COIN, coins[i])


func _after_setup() -> void:
	inscription.activated.connect(func(_m: Mechanism) -> void: portal.open())


func _current(pos: Vector3, length: float, dir: float) -> ConveyorBelt:
	var belt := ConveyorBelt.new()
	belt.size = Vector3(length, 0.4, 4.0)
	belt.direction = dir
	belt.speed = 3.0
	belt.position = pos
	add_child(belt)
	return belt


func _stabilizer(pos: Vector3, link: StringName, mechanism_id: StringName) -> Mechanism:
	var m := Mechanism.new()
	m.mechanism_id = mechanism_id
	m.link_id = link
	m.prompt_text = "Pressione E para estabilizar a passagem"
	m.position = pos
	add_child(m)
	return m


func _reef_platform(x: float, offset: float, link: StringName) -> void:
	var p := RupturePlatform.new()
	p.position = Vector3(x, -0.2, 0.0)
	p.phase_offset = offset
	p.link_id = link
	p.solid_time = 3.0
	p.gone_time = 1.2
	add_child(p)
	reef_platforms.append(p)
