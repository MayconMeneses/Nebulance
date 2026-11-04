class_name UmbraxisModules
extends RefCounted
## Modulos de ecossistemas anteriores reutilizados em Umbraxis (fases 32 e 35). Cada modulo comeca em `ox` (coordenada x do mundo), apoia-se em
## piso a y=0 que continua no modulo seguinte e devolve {"len": comprimento, ...nos}. Visual PROVISORIO: so muda a cor por ecossistema.
## Geometria copiada de trechos ja validados com bot (mecatron_15/17, aquarys_19, sylvara_02/01).


## Sylvara: barreira marcada (Rocco) no meio de um piso de 20 m.
static func barrier(lv: Node3D, b: SegmentBuilder, ox: float) -> Dictionary:
	b.solid(Vector3(ox + 10.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), Color("2F5D4A"))
	var gate: ImpactBarrier = b.barrier(Vector3(ox + 10.0, 1.6, 0.0), Vector3(1.2, 3.2, 3.0))
	return {"len": 20.0, "barrier": gate}


## Cristalia: uma plataforma movel (vai e volta) sobre o vazio entre dois pisos. Com "reduzir movimento" vira uma ponte fixa (assistencia).
static func moving(lv: Node3D, b: SegmentBuilder, ox: float, assist: bool = false) -> Dictionary:
	var ground := Color("4A3F73")
	b.solid(Vector3(ox + 7.0, -0.5, 0.0), Vector3(14.0, 1.0, 4.0), ground)
	b.zone(PhysicsLayers.ABYSS, "gap_%d" % int(ox), Vector3(ox + 19.0, -6.0, 0.0), Vector3(12.0, 3.0, 4.0), Color(0.3, 0.0, 0.4, 0.3))
	var mp: MovingPlatform = null
	if assist:
		b.solid(Vector3(ox + 19.0, -0.2, 0.0), Vector3(10.0, 0.4, 3.0), Color("7C6BC4"))
	else:
		mp = MovingPlatform.new()
		mp.position = Vector3(ox + 19.0, -0.2, 0.0)
		mp.period = 6.0
		lv.add_child(mp)
	b.solid(Vector3(ox + 29.0, -0.5, 0.0), Vector3(10.0, 1.0, 4.0), ground)
	return {"len": 34.0, "mp": mp}


## Mecatron: esteira a favor, elevador de polaridade para o patamar e elevador de descida (alavancas de alternancia).
static func belt_lift(lv: Node3D, b: SegmentBuilder, ox: float) -> Dictionary:
	var steel := Color("4B5563")
	var belt := ConveyorBelt.new()
	belt.size = Vector3(8.0, 0.4, 4.0)
	belt.direction = 1.0
	belt.position = Vector3(ox + 4.0, -0.2, 0.0)
	lv.add_child(belt)
	b.solid(Vector3(ox + 15.0, -0.5, 0.0), Vector3(14.0, 1.0, 4.0), steel)
	var up: PolarityPlatform = _lift(lv, Vector3(ox + 23.5, -0.2, 0.0), Vector3(0.0, 4.0, 0.0), StringName("lift_up_%d" % int(ox)))
	b.solid(Vector3(ox + 32.5, 3.5, 0.0), Vector3(15.0, 1.0, 4.0), steel)
	var down: PolarityPlatform = _lift(lv, Vector3(ox + 41.5, 3.8, 0.0), Vector3(0.0, -4.0, 0.0), StringName("lift_down_%d" % int(ox)))
	b.zone(PhysicsLayers.ABYSS, "shaft_%d" % int(ox), Vector3(ox + 27.0, -9.0, 0.0), Vector3(30.0, 3.0, 4.0), Color(0.3, 0.0, 0.0, 0.2))
	return {"len": 43.0, "belt": belt, "up": up, "down": down}


## Aquarys: a comporta alta ergue tres plataformas flutuantes ate o nivel do piso.
static func tide(lv: Node3D, b: SegmentBuilder, ox: float) -> Dictionary:
	var sand := Color("3E6E8C")
	b.solid(Vector3(ox + 8.0, -0.5, 0.0), Vector3(16.0, 1.0, 4.0), sand)
	var water := WaterBody.new()
	water.surface_size = Vector2(44.0, 3.4)
	water.position = Vector3(ox + 22.0, 0.0, 0.0)
	lv.add_child(water)
	for cx in [18.0, 22.0, 26.0]:
		var f := FloatingPlatform.new()
		f.water = water
		f.offset = -0.2
		f.position = Vector3(ox + cx, 0.0, 0.0)
		lv.add_child(f)
	var control := SluiceControl.new()
	control.water = water
	control.target_level = 2
	control.prompt_text = "Pressione E para subir a mare"
	control.position = Vector3(ox + 14.0, 0.8, 0.0)
	lv.add_child(control)
	b.solid(Vector3(ox + 34.0, -0.5, 0.0), Vector3(12.0, 1.0, 4.0), sand)
	b.zone(PhysicsLayers.ABYSS, "sea_%d" % int(ox), Vector3(ox + 22.0, -7.0, 0.0), Vector3(14.0, 3.0, 4.0), Color(0.0, 0.2, 0.4, 0.3))
	return {"len": 40.0, "water": water, "control": control}


## Aerion: muro (Zuri, salto duplo), corrente de ar (Pipa planeia) e passarela alta.
static func glide(lv: Node3D, b: SegmentBuilder, ox: float) -> Dictionary:
	b.solid(Vector3(ox + 17.0, -0.5, 0.0), Vector3(34.0, 1.0, 4.0), Color("5B7FA6"))
	b.solid(Vector3(ox + 14.0, 1.5, 0.0), Vector3(4.0, 3.0, 4.0), Color("7FA6C4"))
	b.solid(Vector3(ox + 28.0, 2.75, 0.0), Vector3(6.0, 0.5, 4.0), Color("7FA6C4"))
	b.zone(PhysicsLayers.WIND, "wind_%d" % int(ox), Vector3(ox + 20.5, 6.0, 0.0), Vector3(9.0, 12.0, 3.0), Color(0.7, 0.9, 1.0, 0.15), Vector3(0.0, 23.0, 0.0))
	return {"len": 34.0}


## Sylvara: plataformas de ruptura (transparentes quando instaveis) estabilizadas por um mecanismo no fim do piso.
static func bridge(lv: Node3D, b: SegmentBuilder, ox: float, link: StringName) -> Dictionary:
	var ground := Color("2F5D4A")
	b.solid(Vector3(ox + 10.0, -0.5, 0.0), Vector3(20.0, 1.0, 4.0), ground)
	var stabilizer := Mechanism.new()
	stabilizer.mechanism_id = StringName("stab_%d" % int(ox))
	stabilizer.link_id = link
	stabilizer.prompt_text = "Pressione E para estabilizar a passagem"
	stabilizer.position = Vector3(ox + 16.0, 0.8, 0.0)
	lv.add_child(stabilizer)
	var platforms: Array[RupturePlatform] = []
	for i in 3:
		var p := RupturePlatform.new()
		p.position = Vector3(ox + 23.5 + 4.5 * i, -0.2, 0.0)
		p.phase_offset = 0.0 if i % 2 == 0 else 2.1
		p.link_id = link
		p.solid_time = 3.0
		p.gone_time = 1.2
		lv.add_child(p)
		platforms.append(p)
	b.solid(Vector3(ox + 40.0, -0.5, 0.0), Vector3(11.0, 1.0, 4.0), ground)
	b.zone(PhysicsLayers.ABYSS, "rift_%d" % int(ox), Vector3(ox + 28.0, -6.0, 0.0), Vector3(20.0, 3.0, 4.0), Color(0.5, 0.0, 0.1, 0.2))
	return {"len": 45.5, "stabilizer": stabilizer, "platforms": platforms}


static func _lift(lv: Node3D, pos: Vector3, axis: Vector3, lever_id: StringName) -> PolarityPlatform:
	var p := PolarityPlatform.new()
	p.position = pos
	p.axis = axis
	lv.add_child(p)
	var lever := Mechanism.new()
	lever.mechanism_id = lever_id
	lever.toggle = true
	lever.prompt_text = "Pressione E para inverter a polaridade"
	lever.position = Vector3(0.0, 0.8, 0.0)
	p.add_child(lever)
	p.control = lever
	return p
