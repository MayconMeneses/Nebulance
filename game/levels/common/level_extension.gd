class_name LevelExtension
extends RefCounted
## Dobra o tamanho de uma fase: a partir do bau original monta um TRECHO EXTRA com desafios novos e muda o bau para o fim dele.
## Tudo o que existia (IDs de moedas, segredos, checkpoint, rota ate o bau antigo) fica igual; o trecho novo nao tem moedas nem entra na
## definicao (o save e a economia nao mudam), e ganha checkpoints proprios (`<fase>_xcpN`) e um abismo proprio.
## O trecho (rota, inicio, tamanho) fica em `level.extension` para o bot de teste (tests/support/extension_runner.gd).
## Fora do trecho extra: chefes (arenas), segredos e as fases listadas em EXCLUDED.

const EXCLUDED: Array[StringName] = [&"umbraxis_32", &"umbraxis_35"]
## Fases com algo trancado DEPOIS do bau (o portao de luz da fase 09 fecha o portal opcional): so nelas o trecho empurra o que esta alem do bau
## para depois do bau novo. Nas outras, segredos e moedas alem do bau (fases 13, 16...) continuam onde estao: o trecho e so uma laje por cima.
const MOVE_TAIL: Array[StringName] = [&"cristalia_09"]


static func applies(level_id: StringName) -> bool:
	var text: String = String(level_id)
	if "_s0" in text or level_id in EXCLUDED:
		return false
	var number: int = text.get_slice("_", 1).to_int()
	return number > 0 and number % 6 != 0


## Monta o trecho. Devolve {route, start (Vector3 do inicio), original (x do bau antigo), length}; vazio se a fase nao recebe trecho.
static func build(level_id: StringName, b: SegmentBuilder, palette: Dictionary) -> Dictionary:
	var chest: Chest = b.last_chest
	if not applies(level_id) or chest == null:
		return {}
	var number: int = String(level_id).get_slice("_", 1).to_int()
	var original: float = chest.position.x
	var tail: Array[Node3D] = []
	if level_id in MOVE_TAIL:
		tail = _tail_after(b, chest)
	var old_max: float = b.max_x
	var c := ExtCursor.new(b, chest.position.x - 1.5, chest.position.y - 0.6, number, (palette["ground"] as Color).lerp(palette["trim"], 0.35).darkened(0.1))
	c.checkpoint_prefix = String(level_id)
	c.slab(9.0)
	c.checkpoint(5.0)
	ExtensionPlans.fill(c, level_id, original)
	c.slab(7.0)
	chest.position = Vector3(c.x - 2.5, c.y + 0.6, 0.0)
	_move_tail(c, tail, original, old_max)
	_abyss(c, String(level_id))
	return {"route": c.route, "start": Vector3(c.start_x, c.start_y, 0.0), "original": original, "length": c.x - c.start_x}


static func _abyss(c: ExtCursor, level_id: String) -> void:
	var width: float = c.x - c.start_x + 8.0
	c.b.zone(PhysicsLayers.ABYSS, "%s_xabyss" % level_id, Vector3(c.start_x + width * 0.5, c.low_y - 7.0, 0.0), Vector3(width, 3.0, 4.0), Color(0.5, 0.0, 0.1, 0.2))


## O que a fase tem ALEM do bau (portal e portao de luz da fase 09, checkpoint final...) e opcional e fica atras do bau: o trecho extra nao pode
## passar por cima disso, entao tudo isso vai para depois do bau novo (mesma distancia do bau, mesma altura relativa). So para as fases em MOVE_TAIL.
static func _tail_after(b: SegmentBuilder, chest: Chest) -> Array[Node3D]:
	var tail: Array[Node3D] = []
	for node in b.parent.get_children():
		if node is Node3D and node != chest and (node as Node3D).position.x > chest.position.x + 2.5:
			tail.append(node as Node3D)
	return tail


static func _move_tail(c: ExtCursor, tail: Array[Node3D], original: float, old_max: float) -> void:
	if tail.is_empty():
		return
	var shift := Vector3(c.x - 2.5 - original, c.y - c.start_y, 0.0)
	for node in tail:
		node.position += shift
	c.slab(maxf(old_max - original, 4.0) + 3.0)
	c.b.max_x = maxf(c.b.max_x, c.x)
