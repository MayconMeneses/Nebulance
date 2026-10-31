extends RefCounted
## Feixes e prismas (PDF §09): solver deterministico, reflexo, bloqueio, laco, alvo, prisma girateis, ponte de luz.

const BOUNDS: Rect2i = Rect2i(0, 0, 30, 20)


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_solver(out)
	await _field(tree, out)
	return out


func _solver(out: Array) -> void:
	var straight: Dictionary = BeamSolver.trace(Vector2i(0, 5), Vector2i(1, 0), {}, {}, {Vector2i(10, 5): &"t"}, BOUNDS)
	TestWorld.rec(out, "feixe: reto ate o alvo e acende o alvo", straight["hits"] == [&"t"] and straight["segments"] == [[Vector2i(0, 5), Vector2i(10, 5)]])
	TestWorld.rec(out, "feixe: prisma '/' desvia para cima e o alvo la acende",
			BeamSolver.trace(Vector2i(0, 5), Vector2i(1, 0), {Vector2i(5, 5): 0}, {}, {Vector2i(5, 9): &"up"}, BOUNDS)["hits"] == [&"up"])
	TestWorld.rec(out, "feixe: prisma '\\' desvia para baixo (nao acende o alvo de cima)",
			BeamSolver.trace(Vector2i(0, 5), Vector2i(1, 0), {Vector2i(5, 5): 1}, {}, {Vector2i(5, 9): &"up"}, BOUNDS)["hits"].is_empty())
	TestWorld.rec(out, "feixe: reflexos encadeados (2 prismas) chegam ao alvo",
			BeamSolver.trace(Vector2i(0, 2), Vector2i(1, 0), {Vector2i(6, 2): 0, Vector2i(6, 8): 0}, {}, {Vector2i(12, 8): &"far"}, BOUNDS)["hits"] == [&"far"])
	TestWorld.rec(out, "feixe: bloqueio para o feixe antes do alvo",
			BeamSolver.trace(Vector2i(0, 5), Vector2i(1, 0), {}, {Vector2i(4, 5): true}, {Vector2i(10, 5): &"t"}, BOUNDS)["hits"].is_empty())
	var loop: Dictionary = BeamSolver.trace(Vector2i(2, 2), Vector2i(1, 0), {Vector2i(6, 2): 0, Vector2i(6, 6): 1, Vector2i(2, 6): 0, Vector2i(2, 4): 1}, {}, {}, BOUNDS)
	TestWorld.rec(out, "feixe: laco infinito termina no limite de passos (sem travar)", loop["segments"].size() > 0 and loop["segments"].size() <= BeamSolver.MAX_STEPS + 1)
	TestWorld.rec(out, "feixe: sai dos limites e para", BeamSolver.trace(Vector2i(28, 5), Vector2i(1, 0), {}, {}, {}, BOUNDS)["segments"] == [[Vector2i(28, 5), Vector2i(29, 5)]])
	var a: Dictionary = BeamSolver.trace(Vector2i(0, 5), Vector2i(1, 0), {Vector2i(5, 5): 0}, {}, {Vector2i(5, 9): &"u"}, BOUNDS)
	var b: Dictionary = BeamSolver.trace(Vector2i(0, 5), Vector2i(1, 0), {Vector2i(5, 5): 0}, {}, {Vector2i(5, 9): &"u"}, BOUNDS)
	TestWorld.rec(out, "feixe: deterministico (mesma entrada, mesma saida)", a == b)


func _field(tree: SceneTree, out: Array) -> void:
	var w := TestWorld.create(tree, 0)
	var field := BeamField.new()
	field.origin = Vector3(0.0, 0.0, 0.0)
	field.bounds = BOUNDS
	w.root.add_child(field)
	field.add_emitter(Vector2i(0, 1), Vector2i(1, 0))
	var prism: BeamPrism = field.add_prism(Vector2i(5, 1), 1)
	field.add_target(Vector2i(5, 6), &"b1")
	var bridge := LightBridge.new()
	bridge.link_id = &"b1"
	bridge.field = field
	bridge.position = Vector3(9.0, 0.0, 0.0)
	w.root.add_child(bridge)
	await w.step(3)
	TestWorld.rec(out, "campo: com o prisma virado para baixo o alvo esta apagado e a ponte intangivel", not field.is_lit(&"b1") and not bridge.is_solid()
			and bridge.collision_layer == 0)
	prism.interact()
	await w.step(3)
	TestWorld.rec(out, "campo: girar o prisma acende o alvo e a ponte de luz fica solida", field.is_lit(&"b1") and bridge.is_solid()
			and bridge.collision_layer == PhysicsLayers.WORLD)
	prism.interact()
	await w.step(3)
	TestWorld.rec(out, "campo: girar de novo apaga o alvo e a ponte some (derivado, sem estado a parte)", not field.is_lit(&"b1") and not bridge.is_solid())
	prism.interact()
	var saved: Variant = prism.capture()
	prism.interact()
	prism.restore(saved)
	await w.step(3)
	TestWorld.rec(out, "campo: restaurar o prisma (checkpoint) refaz o feixe", prism.orientation == int(saved) and field.is_lit(&"b1"))
	var gate := LightBridge.new()
	gate.link_id = &"b1"
	gate.opens_when_lit = true
	gate.field = field
	w.root.add_child(gate)
	await w.step(3)
	TestWorld.rec(out, "campo: portao de luz (opens_when_lit) abre quando o alvo acende", not gate.is_solid())
	w.dispose()
