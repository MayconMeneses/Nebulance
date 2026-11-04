extends RefCounted
## Camera lateral 2.5D: segue o heroi, mantem o plano (Z fixo).


func run(tree: SceneTree) -> Array:
	var out: Array = []
	var w := TestWorld.create(tree, 0)
	var cam := SideCamera.new()
	cam.target = w.body
	cam.position = Vector3(0.0, 3.0, SideCamera.DEFAULT_DISTANCE)
	w.root.add_child(cam)
	await w.step(20)
	w.input.move_axis = 1.0
	await w.step(120)
	var dx: float = absf(cam.global_position.x - w.body.global_position.x)
	TestWorld.rec(out, "camera: segue o heroi em X", cam.global_position.x > 4.0 and dx < 3.0,
			"(cam=%.2f heroi=%.2f)" % [cam.global_position.x, w.body.global_position.x])
	TestWorld.rec(out, "camera: mantem Z fixo no plano de jogo", is_equal_approx(cam.global_position.z, SideCamera.DEFAULT_DISTANCE))
	## Heroi maior na tela (era a 12 m): altura aparente ~ 1/distancia, entao <= 9,5 m e >= 7 m (abaixo disso o campo horizontal fica curto demais).
	var apparent: float = 12.0 / SideCamera.DEFAULT_DISTANCE
	TestWorld.rec(out, "camera: distancia padrao deixa o heroi pelo menos 25% maior que a 12 m, sem fechar demais o campo",
			apparent >= 1.25 and SideCamera.DEFAULT_DISTANCE >= 7.0, "(x%.2f a %.1f m)" % [apparent, SideCamera.DEFAULT_DISTANCE])
	TestWorld.rec(out, "camera: mantem enquadramento vertical do heroi", absf(cam.global_position.y - (w.body.global_position.y + 2.0)) < 1.0)
	w.dispose()
	return out
