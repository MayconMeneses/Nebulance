extends SceneTree
## Runner headless (sem plugin). Executa as suites listadas e imprime PASS/FAIL por checagem.
## Uso: godot --headless --path . --script res://tests/run_tests.gd [-- suite_nome]
## Codigo de saida 0 somente se tudo passar.

const SUITES: Array[String] = [
	"suite_foundation", "suite_file_size", "asset_pipeline_checks", "skills_checks",
	"suite_controller", "suite_swap", "suite_abilities", "suite_vitals", "suite_camera", "suite_playground", "suite_save", "suite_economy", "suite_level", "suite_level_bot", "suite_flow", "suite_visual", "suite_settings", "suite_galaxy", "suite_astralis", "suite_vfx", "suite_level_02", "suite_level_03", "suite_level_04", "suite_level_05", "suite_boss", "suite_boss_flow", "suite_beams", "suite_cristalia_07", "suite_cristalia_08", "suite_cristalia_09", "suite_cristalia_10", "suite_cristalia_11", "suite_boss_zythra", "suite_warmup", "suite_keybindings", "suite_accessibility", "suite_mecatron_13", "suite_mecatron_14", "suite_mecatron_15", "suite_mecatron_16", "suite_mecatron_17", "suite_mecatron_s03", "suite_boss_ferrorraiz", "suite_aquarys_19", "suite_aquarys_20", "suite_updates", "suite_touch", "suite_prompt_text", "suite_gravity_frame", "suite_cosmetics", "suite_liberation", "suite_astralis_vault", "suite_boss_signature", "suite_visual_look", "suite_space_stage", "suite_adaptive_quality", "suite_camera_feel", "suite_wind_streaks", "suite_aquarys_23", "suite_aquarys_24", "suite_aquarys_21", "suite_aquarys_22", "suite_aquarys_s04", "suite_aerion_25", "suite_aerion_26", "suite_aerion_27", "suite_aerion_28", "suite_umbraxis_31", "suite_umbraxis_32", "suite_umbraxis_33", "suite_umbraxis_34", "suite_umbraxis_35", "suite_umbraxis_s06", "suite_umbraxis_36", "suite_ending", "suite_aerion_29", "suite_boss_zefrion", "suite_aerion_s05",
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
