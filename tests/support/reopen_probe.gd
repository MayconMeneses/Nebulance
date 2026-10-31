extends SceneTree
## Segundo processo (TC-020): abre o save gravado por outro processo e imprime o estado.
## Uso: godot --headless --path . --script res://tests/support/reopen_probe.gd -- <caminho absoluto do save>


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var result: Dictionary = SaveService.new(args[0]).load_save()
	var balance: int = result["data"].get("economy", {}).get("coin_balance", -1)
	var best: Variant = result["data"].get("economy", {}).get("best_grade_by_level", {}).get("sylvara_01", -1)
	print("PROBE status=%d balance=%d best_grade=%s" % [result["status"], balance, str(best)])
	quit(0)
