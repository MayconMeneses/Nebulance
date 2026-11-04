extends RefCounted
## Acabamento da camera (TC-070): tremor curto nos impactos que decai a zero, campo de visao que abre com a velocidade, e tudo desligado
## por "reduzir movimento". A posicao de seguimento nao muda com o tremor (so o deslocamento da imagem).


func run(tree: SceneTree) -> Array:
	var out: Array = []
	await _feel(tree, out)
	return out


func _feel(tree: SceneTree, out: Array) -> void:
	var cam := SideCamera.new()
	tree.get_root().add_child(cam)
	await tree.physics_frame
	var rest: Vector3 = cam.global_position
	cam.shake(0.2, 0.3)
	for i in 6:
		await tree.physics_frame
	var shaking: bool = absf(cam.h_offset) > 0.0 or absf(cam.v_offset) > 0.0
	for i in 40:
		await tree.physics_frame
	TestWorld.rec(out, "TC-070 camera: o tremor desloca so a imagem (a posicao nao muda) e decai ate zero",
			shaking and is_equal_approx(cam.h_offset, 0.0) and is_equal_approx(cam.v_offset, 0.0) and cam.global_position.is_equal_approx(rest))
	var old_reduce: bool = Accessibility.reduce_motion
	Accessibility.reduce_motion = true
	cam.shake(0.3, 0.3)
	await tree.physics_frame
	var blocked: bool = cam.shake_left <= 0.0 and is_equal_approx(cam.h_offset, 0.0)
	Accessibility.reduce_motion = old_reduce
	TestWorld.rec(out, "TC-070 camera: com 'reduzir movimento' o tremor nem comeca", blocked)
	var body := CharacterBody3D.new()
	tree.get_root().add_child(body)
	cam.target = body
	body.velocity = Vector3(8.0, 0.0, 0.0)
	for i in 120:
		await tree.physics_frame
	var wide: float = cam.fov
	Accessibility.reduce_motion = true
	for i in 120:
		await tree.physics_frame
	var calm: float = cam.fov
	Accessibility.reduce_motion = old_reduce
	TestWorld.rec(out, "TC-070 camera: correndo o campo de visao abre ate +3 graus e volta ao normal com 'reduzir movimento'",
			wide > cam.base_fov + 2.5 and wide <= cam.base_fov + cam.speed_fov + 0.01 and absf(calm - cam.base_fov) < 0.3)
	body.queue_free()
	cam.queue_free()
	await tree.process_frame
