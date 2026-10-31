extends SceneTree
## Gera as 6 definicoes de planeta (texto do PDF secoes 03 e 08). Uso: godot --headless --path . --script res://tools/generate_planet_resources.gd

const OUT: String = "res://game/astralis/data"

const DATA: Array = [
	["sylvara", "Sylvara", "Floresta biotecnologica", "Biotecnologia, raizes e plataformas de ruptura", "Vyrkan", "seed_sylvara", true, "5EC27A",
			["sylvara_01_glow_scarf", "archive_symbol_sylvara_01"]],
	["cristalia", "Cristalia", "Cristais e ressonancia", "Prismas, feixes e reflexos", "Zythra", "seed_cristalia", true, "A78BFA", ["cristalia_07_prism_symbol"]],
	["mecatron", "Mecatron", "Maquinaria e magnetismo", "Maquinas, esteiras e polaridade", "Ferrorraiz", "seed_mecatron", false, "F08A3B", []],
	["aquarys", "Aquarys", "Mares e tecnologia aquatica", "Comportas, mares e plataformas flutuantes", "Thalassa", "seed_aquarys", false, "23CFF5", []],
	["aerion", "Aerion", "Vento e gravidade", "Vento e gravidade localizada", "Zefrion", "seed_aerion", false, "EDB85E", []],
	["umbraxis", "Umbraxis", "Coracao do Colapso", "Combinacao e ruptura dimensional", "Necryon", "seed_umbraxis", false, "C03CA8", []],
]


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	for row in DATA:
		var p := PlanetDefinition.new()
		p.planet_id = StringName(row[0])
		p.display_name = row[1]
		p.theme = row[2]
		p.mechanic = row[3]
		p.guardian_name = row[4]
		p.seed_id = StringName(row[5])
		p.playable = row[6]
		p.tint = Color(row[7])
		p.secret_ids = PackedStringArray(row[8])
		var err: int = ResourceSaver.save(p, "%s/%s.tres" % [OUT, row[0]])
		print("%s %s (err=%d)" % ["OK" if err == OK else "ERRO", row[0], err])
	quit(0)
