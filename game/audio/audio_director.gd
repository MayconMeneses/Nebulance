class_name AudioDirector
extends Node
## Toca SFX (bus SFX) e musica (bus Music). Sons originais gerados por tools/make_audio.py.

const SFX: Dictionary = {
	&"coin": "res://assets/audio/sfx_coin.wav",
	&"item": "res://assets/audio/sfx_item.wav",
	&"jump": "res://assets/audio/sfx_jump.wav",
	&"swap": "res://assets/audio/sfx_swap.wav",
	&"checkpoint": "res://assets/audio/sfx_checkpoint.wav",
	&"chest": "res://assets/audio/sfx_chest.wav",
	&"hurt": "res://assets/audio/sfx_hurt.wav",
}
const POOL_SIZE: int = 8

var _streams: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer
var _next: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for key in SFX:
		_streams[key] = load(SFX[key]) as AudioStream
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		_pool.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = &"Music"
	_music.volume_db = -8.0
	add_child(_music)


func play_sfx(sfx_name: StringName) -> void:
	var stream: AudioStream = _streams.get(sfx_name)
	if stream == null:
		return
	var player: AudioStreamPlayer = _pool[_next]
	_next = (_next + 1) % POOL_SIZE
	player.stream = stream
	player.play()


func play_music(path: String) -> void:
	var stream := (load(path) as AudioStreamWAV).duplicate() as AudioStreamWAV
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = stream.data.size() / 2
	_music.stream = stream
	_music.play()


func stop_music() -> void:
	_music.stop()


func is_music_playing() -> bool:
	return _music.playing
