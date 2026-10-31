extends SceneTree
## Gera os .tres iniciais de herois e dificuldades (valores sujeitos a playtest).
## Uso: godot --headless --path . --script res://tools/generate_hero_resources.gd

const OUT_DIR: String = "res://game/actors/data"


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	_save(_hero(&"rocco", "Rocco", 5.5, 8.5, 0.5, 1.8, RoccoAbility.new()), "rocco")
	_save(_hero(&"zuri", "Zuri", 7.0, 9.5, 0.35, 1.5, ZuriAbility.new()), "zuri")
	_save(_hero(&"pipa", "Pipa", 6.0, 8.0, 0.3, 1.1, PipaAbility.new()), "pipa")
	_save(_difficulty(&"explorer", 5, 5), "difficulty_explorer")
	_save(_difficulty(&"adventure", 5, 3), "difficulty_adventure")
	_save(_difficulty(&"legend", 5, 2), "difficulty_legend")
	quit(0)


func _hero(id: StringName, label: String, run: float, jump: float, radius: float,
		height: float, ability: HeroAbility) -> HeroProfile:
	var tuning := MovementTuning.new()
	tuning.run_speed = run
	tuning.jump_velocity = jump
	var profile := HeroProfile.new()
	profile.hero_id = id
	profile.display_name = label
	profile.tuning = tuning
	profile.capsule_radius = radius
	profile.capsule_height = height
	profile.ability = ability
	return profile


func _difficulty(id: StringName, lives: int, hearts: int) -> DifficultyProfile:
	var d := DifficultyProfile.new()
	d.id = id
	d.lives_per_level = lives
	d.hearts_per_attempt = hearts
	return d


func _save(res: Resource, file_name: String) -> void:
	var err: int = ResourceSaver.save(res, "%s/%s.tres" % [OUT_DIR, file_name])
	print("%s %s.tres (err=%d)" % ["OK" if err == OK else "ERRO", file_name, err])
