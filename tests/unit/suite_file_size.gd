extends RefCounted
## Regra "sem god file" (dono): nenhum .gd de res://game e res://tests pode passar de 200 linhas. Sem lista de excecoes.

const MAX_LINES: int = 200
const ROOTS: Array[String] = ["res://game", "res://tests"]


func run(_tree: SceneTree) -> Array:
	var out: Array = []
	TestWorld.rec(out, "sem god file: o contador de linhas conta como o editor (fim com ou sem quebra final, vazio = 0)",
			count_lines("a\nb\n") == 2 and count_lines("a\nb") == 2 and count_lines("") == 0 and count_lines("\n") == 1)
	var checked: int = 0
	var offenders: PackedStringArray = []
	for root in ROOTS:
		for path in scripts_under(root):
			checked += 1
			var lines: int = count_lines(FileAccess.get_file_as_string(path))
			if lines > MAX_LINES:
				offenders.append("%s (%d linhas)" % [path, lines])
	TestWorld.rec(out, "sem god file: a varredura encontrou os scripts de game/ e tests/ (nao e vacuo)", checked > 150, "(%d arquivos .gd)" % checked)
	TestWorld.rec(out, "sem god file: nenhum .gd em game/ ou tests/ passa de %d linhas" % MAX_LINES, offenders.is_empty(), "(excedem: %s)" % ", ".join(offenders))
	return out


static func count_lines(text: String) -> int:
	if text == "":
		return 0
	var parts: PackedStringArray = text.split("\n")
	return parts.size() - 1 if parts[parts.size() - 1] == "" else parts.size()


static func scripts_under(dir_path: String) -> PackedStringArray:
	var found: PackedStringArray = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return found
	for sub in dir.get_directories():
		if not sub.begins_with("."):
			found.append_array(scripts_under(dir_path + "/" + sub))
	for file in dir.get_files():
		if file.ends_with(".gd"):
			found.append(dir_path + "/" + file)
	return found
