class_name ShaderWarmup
extends CanvasLayer
## Aquecimento de shaders: no renderizador Compatibility os shaders compilam no PRIMEIRO desenho. Desenhamos uma vez, atras de uma
## tela de carregamento, os modelos dos tres herois e todos os efeitos, para o travamento nao acontecer durante o jogo (nem na 1a troca).
## Nao altera estado de jogo: instancias temporarias, liberadas ao fim.

signal finished

var frames_left: int = 24

var _temps: Array[Node] = []


func run(level: LevelScene, frame_count: int) -> void:
	frames_left = frame_count
	var label := Label.new()
	label.text = "Carregando..."
	label.add_theme_font_size_override(&"font_size", 32)
	label.position = Vector2(540.0, 330.0)
	add_child(label)
	if frame_count <= 0:
		_finish()
		return
	var at: Vector3 = level.rig.body.global_position + Vector3(0.0, 0.0, -0.5)
	for profile in level.rig.profiles:
		var visual := HeroVisual.new()
		level.add_child(visual)
		visual.global_position = at + Vector3(0.0, 0.0, -0.5)
		visual.show_hero(profile)
		_temps.append(visual)
	if level.effects != null:
		for kind in EffectsDirector.KINDS:
			var p: CPUParticles3D = level.effects.burst(kind, at)
			if p != null:
				_temps.append(p)


func _process(_delta: float) -> void:
	if frames_left <= 0:
		return
	frames_left -= 1
	if frames_left == 0:
		_finish()


func _finish() -> void:
	for n in _temps:
		if is_instance_valid(n):
			n.queue_free()
	_temps.clear()
	finished.emit()
	queue_free()
