class_name SettingsStore
extends RefCounted
## Configuracoes do jogador em ARQUIVO PROPRIO (nao no save da campanha): "Nova Aventura" nao as apaga.
## Escrita atomica; valores invalidos ou chaves desconhecidas voltam ao padrao, sem travar (ADR-0007).

var path: String
var data: Dictionary = defaults()


static func defaults() -> Dictionary:
	return {"version": 1, "graphics_profile": "medium", "max_fps": 0, "vsync": true, "keys": {}, "reduce_motion": false, "reduce_flashing": false, "check_updates": true, "touch_mode": "auto", "touch_size": 1, "touch_opacity": 1, "touch_mirror": false}


func _init(settings_path: String) -> void:
	path = settings_path


## Carrega e saneia. Retorna true se leu um arquivo valido; false se usou padrao (ausente/corrompido).
func load_settings() -> bool:
	data = defaults()
	if not FileAccess.file_exists(path):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		return false
	var profile: Variant = parsed.get("graphics_profile")
	if typeof(profile) == TYPE_STRING and profile in GraphicsProfile.IDS:
		data["graphics_profile"] = profile
	var fps: Variant = parsed.get("max_fps")
	if typeof(fps) in [TYPE_INT, TYPE_FLOAT] and int(fps) in GraphicsProfile.FPS_OPTIONS:
		data["max_fps"] = int(fps)
	var vsync: Variant = parsed.get("vsync")
	if typeof(vsync) == TYPE_BOOL:
		data["vsync"] = vsync
	if typeof(parsed.get("touch_mode")) == TYPE_STRING and parsed["touch_mode"] in TouchLayout.MODES:
		data["touch_mode"] = parsed["touch_mode"]
	var size_i: Variant = parsed.get("touch_size")
	if typeof(size_i) in [TYPE_INT, TYPE_FLOAT] and int(size_i) >= 0 and int(size_i) < TouchLayout.SIZE_SCALES.size():
		data["touch_size"] = int(size_i)
	var opacity_i: Variant = parsed.get("touch_opacity")
	if typeof(opacity_i) in [TYPE_INT, TYPE_FLOAT] and int(opacity_i) >= 0 and int(opacity_i) < TouchLayout.OPACITIES.size():
		data["touch_opacity"] = int(opacity_i)
	for flag in ["reduce_motion", "reduce_flashing", "check_updates", "touch_mirror"]:
		if typeof(parsed.get(flag)) == TYPE_BOOL:
			data[flag] = parsed[flag]
	data["keys"] = KeyBindings.sanitize(parsed.get("keys"))
	return true


func save_settings() -> Error:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var tmp_path: String = path + ".tmp"
	var tmp := FileAccess.open(tmp_path, FileAccess.WRITE)
	if tmp == null:
		return FileAccess.get_open_error()
	tmp.store_string(JSON.stringify(data, "\t"))
	tmp.flush()
	tmp.close()
	if DirAccess.rename_absolute(tmp_path, path) != OK:
		DirAccess.remove_absolute(path)
		return DirAccess.rename_absolute(tmp_path, path)
	return OK
