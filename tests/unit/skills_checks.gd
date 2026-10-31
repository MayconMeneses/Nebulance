extends RefCounted
## Valida o formato das Agent Skills locais (agentskills.io): pasta com SKILL.md,
## frontmatter com name igual ao diretorio e description nao vazia.

const SKILLS_DIR: String = "res://agent-skills"


func run() -> Array:
	var out: Array = []
	var dirs: PackedStringArray = DirAccess.get_directories_at(SKILLS_DIR)
	out.append(["skills_dir_has_skills", dirs.size() >= 6, "(%d)" % dirs.size()])
	for d in dirs:
		var path: String = "%s/%s/SKILL.md" % [SKILLS_DIR, d]
		var f: FileAccess = FileAccess.open(path, FileAccess.READ)
		if f == null:
			out.append(["skill:%s tem SKILL.md" % d, false, ""])
			continue
		var text: String = f.get_as_text()
		var ok_name: bool = text.begins_with("---\nname: %s\n" % d)
		var ok_desc: bool = "\ndescription: " in text and text.count("---") >= 2
		out.append(["skill:%s formato" % d, ok_name and ok_desc, ""])
	return out
