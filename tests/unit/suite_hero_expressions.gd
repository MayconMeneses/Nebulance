extends RefCounted
## Expressoes dos herois (TC-075): cada modelo tem palpebras (lid_l/lid_r) ocultas por padrao; piscam sozinhas de tempos em tempos,
## fecham ao tomar dano e "reduzir movimento" para so o piscar (o dano continua fechando os olhos).


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _lids(tree, out)
	return out


func _visual(tree: SceneTree, hero: String) -> HeroVisual:
	var profile := load("res://game/actors/data/%s.tres" % hero) as HeroProfile
	var visual := HeroVisual.new()
	tree.get_root().add_child(visual)
	visual.show_hero(profile)
	return visual


func _lids(tree: SceneTree, out: Array) -> void:
	var present: bool = true
	var hidden: bool = true
	var blinks: bool = true
	for hero in ["rocco", "zuri", "pipa"]:
		var v: HeroVisual = _visual(tree, hero)
		await tree.process_frame
		present = present and v._lids.size() == 2
		hidden = hidden and not v.eyes_closed and v._lids.all(func(l: Node3D) -> bool: return not l.visible)
		var seen_closed: bool = false
		var seen_open_after: bool = false
		for i in 600:
			v._update_eyes(1.0 / 60.0)
			if v.eyes_closed:
				seen_closed = true
			elif seen_closed:
				seen_open_after = true
		blinks = blinks and seen_closed and seen_open_after
		v.queue_free()
	TestWorld.rec(out, "TC-075 expressoes: os tres herois tem as duas palpebras, ocultas ao carregar", present and hidden)
	TestWorld.rec(out, "TC-075 expressoes: em 10 s cada heroi pisca (fecha e reabre) sozinho", blinks)
	var v2: HeroVisual = _visual(tree, "rocco")
	await tree.process_frame
	v2.set_state(MovementState.State.HURT)
	v2._update_eyes(0.016)
	var hurt_closed: bool = v2.eyes_closed and v2._lids.all(func(l: Node3D) -> bool: return l.visible)
	v2.set_state(MovementState.State.IDLE)
	v2._update_eyes(0.016)
	var reopened: bool = not v2.eyes_closed
	var old_reduce: bool = Accessibility.reduce_motion
	Accessibility.reduce_motion = true
	var never: bool = true
	for i in 900:
		v2._update_eyes(1.0 / 60.0)
		never = never and not v2.eyes_closed
	v2.set_state(MovementState.State.HURT)
	v2._update_eyes(0.016)
	var hurt_still: bool = v2.eyes_closed
	Accessibility.reduce_motion = old_reduce
	TestWorld.rec(out, "TC-075 expressoes: dano fecha os olhos e eles reabrem; com 'reduzir movimento' nao pisca mas o dano ainda fecha", hurt_closed and reopened and never and hurt_still)
	v2.queue_free()
	await tree.process_frame
