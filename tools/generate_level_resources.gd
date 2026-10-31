extends SceneTree
## Gera as definicoes de fase (IDs estaveis e tabela de recompensas de TESTE).
## Uso: godot --headless --path . --script res://tools/generate_level_resources.gd

const OUT_DIR: String = "res://game/levels/sylvara"


func _initialize() -> void:
	_save(_def("sylvara_01", "O Primeiro Passo", "Alcance o bau no fim da trilha", 9,
			["sylvara_01_cp1"], ["sylvara_01_glow_scarf"], ["archive_symbol_sylvara_01"]))
	_save(_def("sylvara_02", "A Ponte Desaparecida", "Atravesse a ponte e alcance o bau", 9,
			["sylvara_02_cp1"], ["sylvara_02_vine_charm"], ["memory_roots_clue_02"]))
	quit(0)


func _def(id: String, title: String, goal: String, coin_count: int, cps: Array, items: Array, memories: Array) -> LevelDefinition:
	var d := LevelDefinition.new()
	d.level_id = StringName(id)
	d.display_name = title
	d.planet_id = &"sylvara"
	d.goal_text = goal
	d.chest_id = StringName(id + "_chest")
	var coins: PackedStringArray = PackedStringArray()
	for i in range(1, coin_count + 1):
		coins.append("%s_coin_%02d" % [id, i])
	d.coin_ids = coins
	d.checkpoint_ids = PackedStringArray(cps)
	d.secret_item_ids = PackedStringArray(items)
	d.secret_memory_ids = PackedStringArray(memories)
	return d


func _save(d: LevelDefinition) -> void:
	var path: String = "%s/%s_definition.tres" % [OUT_DIR, d.level_id]
	var err: int = ResourceSaver.save(d, path)
	print("%s %s (err=%d)" % ["OK" if err == OK else "ERRO", path, err])
