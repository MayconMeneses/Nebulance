class_name TmpDir
extends RefCounted
## Pasta descartavel em user://test_tmp (testes NUNCA tocam o save real).

const ROOT: String = "user://test_tmp"


static func fresh(case_name: String) -> String:
	var dir: String = "%s/%s" % [ROOT, case_name]
	remove(dir)
	DirAccess.make_dir_recursive_absolute(dir)
	return dir


static func write(file_path: String, text: String) -> void:
	var f := FileAccess.open(file_path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


static func read(file_path: String) -> String:
	var f := FileAccess.open(file_path, FileAccess.READ)
	return "" if f == null else f.get_as_text()


static func remove(dir: String) -> void:
	if not DirAccess.dir_exists_absolute(dir):
		return
	for file_name in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute("%s/%s" % [dir, file_name])
	for sub in DirAccess.get_directories_at(dir):
		remove("%s/%s" % [dir, sub])
	DirAccess.remove_absolute(dir)
