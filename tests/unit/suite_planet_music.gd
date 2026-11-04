extends RefCounted
## Musica por planeta (TC-073): cada planeta tem seu tema proprio (loop de 24 s, audivel, que emenda sem estalo) e a fase toca o do seu planeta.
## LIMITE: o gosto musical nao e testavel; aqui so formato, nivel, emenda e que os temas sao diferentes entre si.


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_files(out)
	await _flow(tree, out)
	return out


func _files(out: Array) -> void:
	var seen: Dictionary = {}
	var formats_ok: bool = true
	var loud_ok: bool = true
	var seam_ok: bool = true
	for planet in GalaxyState.planets():
		var path: String = AudioDirector.music_for(planet.planet_id)
		var stream := load(path) as AudioStreamWAV
		formats_ok = formats_ok and stream != null and stream.mix_rate == 22050 and not stream.stereo and absf(stream.get_length() - 24.0) < 0.1
		# O WAV importado pode estar comprimido (QOA): a analise de nivel e emenda le o arquivo-fonte (cabecalho WAV de 44 bytes + PCM 16 bits).
		var raw: PackedByteArray = FileAccess.get_file_as_bytes(path)
		var samples: int = (raw.size() - 44) / 2
		var peak: int = 0
		var energy: float = 0.0
		var count: int = 0
		for i in range(0, samples, 7):
			var v: int = raw.decode_s16(44 + i * 2)
			peak = maxi(peak, absi(v))
			energy += float(v) * float(v)
			count += 1
		loud_ok = loud_ok and peak > 12000 and peak < 32768 and sqrt(energy / float(count)) > 1500.0
		seam_ok = seam_ok and absi(raw.decode_s16(44) - raw.decode_s16(44 + (samples - 1) * 2)) < 4000 and samples == 529200
		seen[raw.slice(44 + 2 * 40000, 44 + 2 * 40200).hex_encode()] = true
	TestWorld.rec(out, "TC-073 musica: os 6 planetas tem tema proprio no mesmo formato (mono 22050 Hz, 24 s)", formats_ok and seen.size() == 6)
	TestWorld.rec(out, "TC-073 musica: todos audiveis (pico e volume medio adequados, sem estourar) e o fim emenda com o comeco (sem estalo no loop)", loud_ok and seam_ok)
	TestWorld.rec(out, "TC-073 musica: planeta desconhecido cai no tema de Sylvara", AudioDirector.music_for(&"nada") == AudioDirector.music_for(&"sylvara"))
	var director := AudioDirector.new()
	Engine.get_main_loop().root.add_child(director)
	director.play_music(AudioDirector.music_for(&"aerion"))
	var looped := director._music.stream as AudioStreamWAV
	TestWorld.rec(out, "TC-073 musica: o loop cobre a musica INTEIRA (24 s), mesmo com o WAV importado comprimido (antes cortava em ~5 s)",
			looped.loop_mode == AudioStreamWAV.LOOP_FORWARD and looped.loop_end == 529200)
	director.queue_free()


func _flow(tree: SceneTree, out: Array) -> void:
	var dir: String = TmpDir.fresh("music")
	var flow := GameFlow.new()
	flow.save_path = dir + "/slot1.json"
	flow.settings_path = dir + "/settings.json"
	flow.play_intro = false
	tree.get_root().add_child(flow)
	await tree.process_frame
	flow.start_new_game(true)
	await tree.process_frame
	var sylvara_stream: AudioStream = flow.audio._music.stream
	var ok_sylvara: bool = flow.audio.is_music_playing() and flow.level.definition.planet_id == &"sylvara"
	flow.level.queue_free()
	flow.level = null
	flow._start_level("aerion_28")
	await tree.process_frame
	var aerion_stream: AudioStream = flow.audio._music.stream
	TestWorld.rec(out, "TC-073 musica: a fase toca o tema do SEU planeta (Sylvara numa fase de Sylvara e outro tema numa fase de Aerion)",
			ok_sylvara and flow.audio.is_music_playing() and sylvara_stream != aerion_stream and flow.level.definition.planet_id == &"aerion"
			and (aerion_stream as AudioStreamWAV).data == (load(AudioDirector.music_for(&"aerion")) as AudioStreamWAV).data)
	tree.paused = false
	flow.queue_free()
	await tree.process_frame
