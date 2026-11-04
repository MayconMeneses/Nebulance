extends RefCounted
## Ataque de ASSINATURA dos chefes (TC-065): a partir da fase 2 as faixas 0 e 1 trocam o volume da erupcao de raiz pelo perfil proprio do
## chefe (mordida, petalas, espinhos, onda, rajada, fenda); aviso continua >= 0,6 s e so a faixa ATIVA fere, no volume avisado.

func _bosses() -> Array:
	return [[VyrkanBoss, &"bite", &"rocco"], [ZythraBoss, &"petal", &"prism"], [FerrorraizBoss, &"spike", &"power"],
			[ThalassaBoss, &"wave", &"flux"], [ZefrionBoss, &"gust", &"anchors"], [NecryonBoss, &"rift", &"combine"]]


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_profiles(tree, out)
	await _damage(tree, out)
	return out


func _volume_ok(lane: RootLane, id: StringName) -> bool:
	var span: Vector2 = RootLane.PROFILES[id]
	return lane.profile == id and is_equal_approx(lane._box.size.y, span.y - span.x) and is_equal_approx(lane._shape.position.y, (span.x + span.y) * 0.5)


func _profiles(tree: SceneTree, out: Array) -> void:
	var distinct: Dictionary = {}
	var phase1_ok: bool = true
	var phase_ok: bool = true
	var finish_ok: bool = true
	var restore_ok: bool = true
	var timing_ok: bool = true
	for entry in _bosses():
		var boss: VyrkanBoss = (entry[0] as GDScript).new()
		tree.get_root().add_child(boss)
		var sig: StringName = entry[1]
		distinct[sig] = true
		phase1_ok = phase1_ok and boss.signature == sig and boss.lanes.all(func(l: RootLane) -> bool: return _volume_ok(l, &"root"))
		boss.mechanism_done(entry[2])
		for p in 2:
			phase_ok = phase_ok and boss.phase == 2 + p
			for i in boss.lanes.size():
				phase_ok = phase_ok and _volume_ok(boss.lanes[i], sig if i < 2 else &"root")
			if p == 0:
				boss.mechanism_done(boss.stage_keys[2])
		boss.mechanism_done(boss.stage_keys[3])
		finish_ok = finish_ok and boss.phase == VyrkanBoss.Phase.FINISH and boss.lanes.all(func(l: RootLane) -> bool: return l.profile == &"root" or l.profile == sig) and true
		boss.restore(null)
		restore_ok = restore_ok and boss.phase == VyrkanBoss.Phase.ONE and boss.lanes.all(func(l: RootLane) -> bool: return _volume_ok(l, &"root"))
		for ph in [1, 2, 3]:
			timing_ok = timing_ok and boss.TIMING[ph].x >= VyrkanBoss.MIN_TELEGRAPH
		boss.queue_free()
	TestWorld.rec(out, "TC-065 assinatura: os seis chefes tem um perfil de golpe PROPRIO e diferente (mordida, petalas, espinhos, onda, rajada, fenda)",
			distinct.size() == 6 and not distinct.has(&"root"))
	TestWorld.rec(out, "TC-065 assinatura: na fase 1 todas as faixas sao erupcao de raiz (o golpe proprio so aparece depois)", phase1_ok)
	TestWorld.rec(out, "TC-065 assinatura: nas fases 2 e 3 so as faixas 0 e 1 usam o volume do chefe (as outras seguem raiz)", phase_ok)
	TestWorld.rec(out, "TC-065 assinatura: reiniciar no checkpoint volta ao perfil de raiz na fase 1", restore_ok)
	TestWorld.rec(out, "TC-065 assinatura: o aviso continua >= 0,6 s em todas as fases (o golpe novo nao encurta a leitura)", timing_ok)
	var lane := RootLane.new()
	tree.get_root().add_child(lane)
	lane.position = Vector3(10.0, 0.0, 0.0)
	var reach: Array[bool] = []
	for case in [[&"root", 6.0, false], [&"bite", 6.0, true], [&"petal", 4.0, true], [&"petal", 0.9, false], [&"spike", 0.5, true],
			[&"spike", 1.5, false], [&"wave", 1.2, true], [&"wave", 2.5, false], [&"gust", 10.0, true], [&"rift", 4.0, true], [&"rift", 7.0, false]]:
		lane.set_profile(case[0])
		reach.append(lane.covers(Vector3(10.0, case[1], 0.0)) == case[2])
	lane.set_profile(&"bite")
	reach.append(not lane.covers(Vector3(13.0, 2.0, 0.0)))
	TestWorld.rec(out, "TC-065 assinatura: o volume que fere tem a altura de cada perfil (mordida alcanca o alto; petalas so no ar; espinhos so no chao)",
			reach.all(func(v: bool) -> bool: return v), "(%s)" % str(reach))
	lane.queue_free()


func _arena(tree: SceneTree) -> SylvaraLevel06:
	var level := SylvaraLevel06.new()
	level.use_input_reader = false
	tree.get_root().add_child(level)
	return level


## Heroi parado a 5,5 m de altura na coluna da faixa 1: so a MORDIDA (fase 2+) o alcanca, e so quando ATIVA.
func _damage(tree: SceneTree, out: Array) -> void:
	var hit: Dictionary = {}
	for ph in [1, 2]:
		var level: SylvaraLevel06 = _arena(tree)
		await tree.physics_frame
		level.boss.phase = ph
		level.boss.restart_cycle()
		var lane: RootLane = level.boss.lanes[1]
		var hearts: int = level.rig.vitals.hearts
		var seen_active: bool = false
		var in_telegraph: bool = false
		var in_active: bool = false
		for i in 700:
			level.rig.body.global_position = Vector3(lane.position.x, 5.5, 0.0)
			level.rig.body.velocity = Vector3.ZERO
			await tree.physics_frame
			seen_active = seen_active or lane.state == RootLane.State.ACTIVE
			var now: int = level.rig.vitals.hearts
			if now < hearts:
				in_telegraph = in_telegraph or lane.state == RootLane.State.TELEGRAPH
				in_active = in_active or lane.state == RootLane.State.ACTIVE
			hearts = now
			level.rig.vitals.tick(2.0)
		hit[ph] = [seen_active, in_active, in_telegraph]
		level.queue_free()
	TestWorld.rec(out, "TC-065 assinatura: na fase 1 a erupcao baixa NAO alcanca o heroi no alto (refugio); na fase 2 a mordida alcanca, so ATIVA, nunca no aviso",
			hit[1][0] and not hit[1][1] and not hit[1][2] and hit[2][0] and hit[2][1] and not hit[2][2], "(fase1=%s fase2=%s)" % [str(hit[1]), str(hit[2])])
