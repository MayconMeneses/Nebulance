class_name LevelBot
extends RefCounted
## Bot deterministico por scripts de entrada: percorre a fase usando SOMENTE intents (sem teleporte).

var tree: SceneTree
var level: LevelScene
var body: ActorController
var input: ScriptedInput = ScriptedInput.new()
var stage: String = "inicio"
var trace: bool = false


func _init(scene_tree: SceneTree, target_level: LevelScene) -> void:
	tree = scene_tree
	level = target_level
	body = level.rig.body
	body.intent_provider = input.read


func frames(count: int) -> void:
	for i in count:
		await tree.physics_frame


func x() -> float:
	return body.global_position.x


func run_to(target_x: float, cap: int = 900) -> bool:
	input.move_axis = 1.0
	for i in cap:
		await tree.physics_frame
		if trace and i % 20 == 0:
			print("   TRACE %s run_to(%.1f) x=%.2f y=%.2f vy=%.2f floor=%s hero=%s" % [stage, target_x, x(), body.global_position.y, body.velocity.y, body.is_on_floor(), level.rig.body.profile.hero_id])
		if x() >= target_x:
			return true
	return false


## Anda (nos dois sentidos, eixo analogico baixo) ate `target` e para.
func walk_to(target: float, tolerance: float = 0.15) -> bool:
	for i in 400:
		await tree.physics_frame
		var d: float = target - x()
		if absf(d) <= tolerance:
			input.move_axis = 0.0
			await frames(10)
			return true
		input.move_axis = clampf(d * 0.8, -0.4, 0.4)
	return false


## Corre para a ESQUERDA (eixo -1) ate x <= target.
func run_left_to(target_x: float, cap: int = 900) -> bool:
	input.move_axis = -1.0
	for i in cap:
		await tree.physics_frame
		if x() <= target_x:
			return true
	return false


func wait_floor(cap: int = 180) -> bool:
	for i in cap:
		await tree.physics_frame
		if body.is_on_floor():
			return true
	return false


func wait_airborne(cap: int = 20) -> void:
	for i in cap:
		await tree.physics_frame
		if not body.is_on_floor():
			return


## Corre ate target_x e salta (segurando a direcao) ate pousar.
func jump_at(target_x: float) -> bool:
	if not await run_to(target_x):
		return false
	input.press_jump()
	await wait_airborne()
	input.jump_held = true
	var ok: bool = await wait_floor()
	input.jump_held = false
	return ok


func swap_to(index: int) -> bool:
	input.move_axis = 0.0
	await frames(6)
	input.swap(1 if index > level.rig.active_index else -1)
	await frames(6)
	return level.rig.active_index == index


## Atravessa a criatura contaminada pulando quando ela esta perto e fere.
func cross_enemy(until_x: float, enemy: PatrolEnemy) -> bool:
	input.move_axis = 1.0
	for i in 900:
		await tree.physics_frame
		if x() >= until_x:
			return true
		var dx: float = enemy.global_position.x - x()
		if body.is_on_floor() and enemy.is_harmful() and dx > -0.5 and dx < 2.2:
			input.press_jump()
			input.jump_held = true
		elif body.is_on_floor():
			input.jump_held = false
	return false


func play() -> bool:
	stage = "chegada"
	await frames(40)
	stage = "salto no degrau (x=8.3)"
	if not await jump_at(8.3):
		return false
	stage = "ponte (tabua faltando)"
	if not await jump_at(26.4):
		return false
	stage = "barreira de impacto (Rocco)"
	if not await run_to(36.8):
		return false
	input.press_special()
	for i in 60:
		await tree.physics_frame
		if (level.find_children("*", "ImpactBarrier", true, false)[0] as ImpactBarrier).is_broken:
			break
	input.special_held = false
	stage = "checkpoint"
	if not await run_to(44.6):
		return false
	stage = "trocar para Zuri"
	if not await swap_to(1):
		return false
	stage = "muro alto (salto duplo de Zuri)"
	if not await run_to(47.0):
		return false
	input.press_jump()
	input.jump_held = true
	for i in 40:
		await tree.physics_frame
		if body.velocity.y <= 0.5:
			break
	input.press_jump()
	input.jump_held = true
	await frames(30)
	input.jump_held = false
	if not await wait_floor() or body.global_position.y < 3.2:
		return false
	stage = "trocar para Pipa no topo do muro"
	if not await swap_to(2):
		return false
	stage = "desvio com vento (planeio de Pipa)"
	if not await run_to(55.8):
		return false
	input.press_jump()
	input.jump_held = true
	await frames(18)
	input.press_special()
	var landed: bool = false
	for i in 240:
		await tree.physics_frame
		if body.is_on_floor():
			landed = true
			break
	input.move_axis = 0.0
	input.special_held = false
	input.jump_held = false
	if not landed or body.global_position.y < 3.2:
		stage += " (pousou em x=%.1f y=%.2f)" % [x(), body.global_position.y]
		return false
	await frames(10)
	stage = "segredo (itens da plataforma)"
	if not await run_to(70.6):
		return false
	stage = "descer e atravessar a criatura"
	var enemy: PatrolEnemy = level.find_children("*", "PatrolEnemy", true, false)[0] as PatrolEnemy
	if not await cross_enemy(90.0, enemy):
		return false
	stage = "bau"
	if not await run_to(101.4):
		return false
	input.move_axis = 0.0
	for i in 60:
		input.press_interact()
		await tree.physics_frame
		if level.controller.completed:
			return true
	return false
