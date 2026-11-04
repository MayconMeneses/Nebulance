extends RefCounted
## Guardioes em 3D (TC-071): cada chefe tem seu corpo procedural proprio (6 silhuetas), que REAGE ao ciclo de ataques (junta forca no aviso,
## golpeia na erupcao, acalma ao ser derrotado), sem colisao e enxuto. Aparencia conferida a parte em janela real.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _bodies(tree, out)
	await _reactions(tree, out)
	return out


func _classes() -> Array:
	return [VyrkanBoss, ZythraBoss, FerrorraizBoss, ThalassaBoss, ZefrionBoss, NecryonBoss]


func _bodies(tree: SceneTree, out: Array) -> void:
	var kinds: Dictionary = {}
	var sane: bool = true
	for cls in _classes():
		var boss: VyrkanBoss = (cls as GDScript).new()
		tree.get_root().add_child(boss)
		await tree.process_frame
		var avatar: BossAvatar = boss.avatar
		kinds[avatar.kind] = true
		var nodes: int = avatar.find_children("*", "", true, false).size()
		sane = sane and avatar.kind == boss.signature and nodes > 10 and nodes < 120 and avatar.core != null \
				and avatar.find_children("*", "CollisionObject3D", true, false).is_empty() and avatar.position.is_equal_approx(BossModels.POSITIONS[avatar.kind])
		boss.queue_free()
	TestWorld.rec(out, "TC-071 guardioes 3D: os seis chefes tem corpo proprio (6 silhuetas), enxuto (< 120 nos), com nucleo, sem colisao e no lugar do arena", kinds.size() == 6 and sane)


func _reactions(tree: SceneTree, out: Array) -> void:
	var boss := VyrkanBoss.new()
	tree.get_root().add_child(boss)
	await tree.process_frame
	var gathered: bool = false
	var struck: bool = false
	var max_open: float = 0.0
	var min_open_strike: float = 1.0
	for i in 420:
		await tree.physics_frame
		var avatar: BossAvatar = boss.avatar
		if avatar.mood == BossAvatar.Mood.GATHER:
			gathered = true
			max_open = maxf(max_open, avatar.open)
		elif avatar.mood == BossAvatar.Mood.STRIKE:
			struck = true
			min_open_strike = minf(min_open_strike, avatar.open)
	TestWorld.rec(out, "TC-071 guardioes 3D: no AVISO o guardiao junta forca (abre ao maximo) e na erupcao ATIVA fecha de uma vez (leitura clara do ataque)",
			gathered and struck and max_open > 0.9 and min_open_strike < 0.35, "(abertura max no aviso=%.2f, min no golpe=%.2f)" % [max_open, min_open_strike])
	boss.phase = VyrkanBoss.Phase.FINISH
	boss.finish_triad()
	for i in 90:
		await tree.process_frame
	var avatar_done: BossAvatar = boss.avatar
	TestWorld.rec(out, "TC-071 guardioes 3D: derrotado, o guardiao fica em forma calma (encolhe um pouco e o brilho do nucleo cai)",
			avatar_done.mood == BossAvatar.Mood.DEFEATED and avatar_done._root.scale.x < 0.95
			and (avatar_done.core.mesh.material as StandardMaterial3D).emission_energy_multiplier < 1.0)
	boss.queue_free()
	await tree.process_frame
