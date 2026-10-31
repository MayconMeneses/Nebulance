extends SceneTree
## Gera a definicao da fase 01 (IDs estaveis e tabela de recompensas de TESTE).
## Uso: godot --headless --path . --script res://tools/generate_level_resources.gd

const OUT: String = "res://game/levels/sylvara/sylvara_01_definition.tres"


func _initialize() -> void:
	var d := LevelDefinition.new()
	d.level_id = &"sylvara_01"
	d.display_name = "O Primeiro Passo"
	d.planet_id = &"sylvara"
	d.goal_text = "Alcance o bau no fim da trilha"
	d.chest_id = &"sylvara_01_chest"
	var coins: PackedStringArray = PackedStringArray()
	for i in range(1, 10):
		coins.append("sylvara_01_coin_%02d" % i)
	d.coin_ids = coins
	d.checkpoint_ids = PackedStringArray(["sylvara_01_cp1"])
	d.secret_item_ids = PackedStringArray(["sylvara_01_glow_scarf"])
	d.secret_memory_ids = PackedStringArray(["archive_symbol_sylvara_01"])
	var err: int = ResourceSaver.save(d, OUT)
	print("%s %s (err=%d)" % ["OK" if err == OK else "ERRO", OUT, err])
	quit(0 if err == OK else 1)
