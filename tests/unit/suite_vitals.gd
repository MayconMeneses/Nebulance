extends RefCounted
## Dano, vidas, coracoes e checkpoints: TC-009 a TC-012 (TC-012 parcial: sem persistencia ainda).


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _tc009(tree, out)
	await _tc010(tree, out)
	await _tc011(tree, out)
	await _tc012(tree, out)
	await _checkpoint(tree, out)
	return out


func _tc009(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	w.add_zone(PhysicsLayers.HAZARD, Vector3(0.0, 1.0, 0.0), Vector3(30.0, 6.0, 4.0))
	await w.step(2)
	TestWorld.rec(out, "TC-009 perigo tira 1 coracao", w.rig.vitals.hearts == 2, "(coracoes=%d)" % w.rig.vitals.hearts)
	TestWorld.rec(out, "TC-009 dano aplica estado HURT", w.body.state == MovementState.State.HURT)
	await w.step(30)
	TestWorld.rec(out, "TC-009 invulnerabilidade evita dano repetido", w.rig.vitals.hearts == 2 and w.rig.vitals.is_invulnerable(),
			"(coracoes=%d)" % w.rig.vitals.hearts)
	await w.step(70)
	TestWorld.rec(out, "TC-009 ao fim da invulnerabilidade, ainda no perigo, novo dano", w.rig.vitals.hearts == 1,
			"(coracoes=%d)" % w.rig.vitals.hearts)
	w.dispose()


func _tc010(tree: SceneTree, out: Array) -> void:
	for case in [["adventure", 3], ["explorer", 5], ["legend", 2]]:
		var w := TestWorld.create(tree, 0, case[0])
		TestWorld.rec(out, "TC-010 %s: 5 vidas e %d coracoes" % [case[0], case[1]],
				w.rig.vitals.lives == 5 and w.rig.vitals.hearts == case[1],
				"(vidas=%d coracoes=%d)" % [w.rig.vitals.lives, w.rig.vitals.hearts])
		w.dispose()


func _tc011(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	w.rig.checkpoint_position = Vector3(10.0, 1.0, 0.0)
	w.add_zone(PhysicsLayers.ABYSS, Vector3(0.0, 1.0, 0.0), Vector3(4.0, 6.0, 4.0))
	await w.step(60)
	TestWorld.rec(out, "TC-011 abismo consome exatamente 1 vida", w.rig.vitals.lives == 4, "(vidas=%d)" % w.rig.vitals.lives)
	TestWorld.rec(out, "TC-011 reaparece no checkpoint", absf(w.body.global_position.x - 10.0) < 1.5,
			"(x=%.2f)" % w.body.global_position.x)
	TestWorld.rec(out, "TC-011 coracoes restaurados", w.rig.vitals.hearts == 3)
	w.dispose()

	var h := TestWorld.create(tree, 0)
	h.rig.checkpoint_position = Vector3(10.0, 1.0, 0.0)
	for i in 3:
		h.body.take_hit()
		h.rig.vitals.tick(2.0)
	TestWorld.rec(out, "TC-011 zerar coracoes consome 1 vida, restaura coracoes e reaparece",
			h.rig.vitals.lives == 4 and h.rig.vitals.hearts == 3 and absf(h.body.global_position.x - 10.0) < 0.01,
			"(vidas=%d coracoes=%d)" % [h.rig.vitals.lives, h.rig.vitals.hearts])
	h.dispose()


func _tc012(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	var flags := {"restart": 0}
	w.rig.level_restart_requested.connect(func() -> void: flags["restart"] += 1)
	for i in 4:
		w.rig.vitals.fall()
	TestWorld.rec(out, "TC-012 com 1 vida restante nao reinicia a fase", flags["restart"] == 0 and w.rig.vitals.lives == 1)
	w.rig.vitals.fall()
	TestWorld.rec(out, "TC-012 zerar vidas pede reinicio da fase uma vez e restaura 5 vidas/3 coracoes (parcial: sem persistencia)",
			flags["restart"] == 1 and w.rig.vitals.lives == 5 and w.rig.vitals.hearts == 3)
	w.dispose()


func _checkpoint(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	w.add_zone(PhysicsLayers.CHECKPOINT, Vector3(8.0, 1.0, 0.0), Vector3(2.0, 4.0, 2.0))
	await w.step(2)
	TestWorld.rec(out, "checkpoint: nao ativa antes de tocar", absf(w.rig.checkpoint_position.x - 8.0) > 0.1)
	w.body.global_position = Vector3(8.0, 1.0, 0.0)
	await w.step(3)
	TestWorld.rec(out, "checkpoint: ativa ao tocar", absf(w.rig.checkpoint_position.x - 8.0) < 0.01)
	w.dispose()
