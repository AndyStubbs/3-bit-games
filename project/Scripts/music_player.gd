extends Node


const FADE_TIME: float = 0.75
const MAX_DB: float = 0
const MIN_DB: float = -80


var music = [
	load( "res://Assets/Music/easy-listening-233944.mp3" ),
	load( "res://Assets/Music/the-intro-ambient-233972.mp3" ),
	load( "res://Assets/Music/upturned-nose-233930.mp3" )
]


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_stream_player2: AudioStreamPlayer = $AudioStreamPlayer2


var tween_in: Tween
var tween_out: Tween


func play( song: int ) -> void:
	if tween_in and tween_in.is_running():
		tween_in.stop()
		audio_stream_player.stop()
		audio_stream_player2.stop()
	if tween_out and tween_out.is_running():
		tween_out.stop()
		audio_stream_player.stop()
		audio_stream_player2.stop()
	if audio_stream_player.playing:
		fade_out_song( audio_stream_player )
		fade_in_song( audio_stream_player2, song )
	elif audio_stream_player2.playing:
		fade_out_song( audio_stream_player2 )
		fade_in_song( audio_stream_player, song )
	else:
		fade_in_song( audio_stream_player, song )


func fade_out_song( audio: AudioStreamPlayer ) -> void:
	tween_out = create_tween()
	tween_out.tween_property( audio, "volume_db", MIN_DB, FADE_TIME )
	await tween_out.finished
	audio.stop()


func fade_in_song( audio: AudioStreamPlayer, song: int ) -> void:
	audio.volume_db = MIN_DB
	audio.stream = music[ song ]
	audio.play()
	tween_in = create_tween()
	tween_in.tween_property( audio, "volume_db", MAX_DB, FADE_TIME / 2.0 )
	await tween_in.finished
