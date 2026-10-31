extends SceneTree
## Runner headless (sem plugin). Executa as suites listadas e imprime PASS/FAIL por checagem.
## Uso: godot --headless --path . --script res://tests/run_tests.gd [-- suite_nome]
## Codigo de saida 0 somente se tudo passar.

const SUITES: Array[String] = [
	"suite_foundation", "asset_pipeline_checks", "skills_checks",
	"suite_controller", "suite_swap", "suite_abilities", "suite_vitals", "suite_camera", "suite_playground", "suite_save", "suite_economy", "suite_level", "suite_level_bot", "suite_flow", "suite_visual", "suite_settings", "suite_galaxy", "suite_astralis", "suite_vfx", "suite_level_02", "suite_level_03",
]

var _failures: int = 0
var _total: int = 0


func _initialize() -> void:
	# No primeiro quadro os nos ainda nao receberam _ready: espera um quadro para qualquer suite rodar isolada.
	await process_frame
	var only: PackedStringArray = OS.get_cmdline_user_args()
	for suite_name in SUITES:
		if only.size() > 0 and not suite_name in only:
			continue
		var script: GDScript = load("res://tests/unit/%s.gd" % suite_name)
		var results: Array = await script.new().run(self)
		for r in results:
			_total += 1
			if not r[1]:
				_failures += 1
			print("%s  %s %s" % ["PASS" if r[1] else "FAIL", r[0], r[2]])
	print("RESULT: %s (%d checagens, %d falha(s))" % ["PASS" if _failures == 0 else "FAIL", _total, _failures])
	quit(0 if _failures == 0 else 1)
