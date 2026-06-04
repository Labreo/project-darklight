extends Node

var bgm_player: AudioStreamPlayer
var amb_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var bgm_streams = {
	"theme": preload("res://audio/bgm/theme_audio.wav"),
	"case_start": preload("res://audio/bgm/case_start.mp3"),
	"decision": preload("res://audio/bgm/decision.mp3"),
	"interrogation": preload("res://audio/bgm/interrogations.mp3")
}

var amb_streams = {}

var sfx_streams = {
	"play_click": preload("res://audio/ui_system_navigation/play_click_button.mp3"),
	"clue_found": preload("res://audio/ui_system_navigation/clue_found.mp3")
}

func _ready():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"
	add_child(bgm_player)
	
	amb_player = AudioStreamPlayer.new()
	amb_player.bus = "Ambience"
	add_child(amb_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)

func play_bgm(track_name: String):
	if bgm_streams.has(track_name):
		var stream = bgm_streams[track_name]
		if bgm_player.stream != stream or not bgm_player.playing:
			bgm_player.stream = stream
			bgm_player.play()

func stop_bgm():
	bgm_player.stop()
	bgm_player.stream = null

func play_ambience(track_name: String):
	if amb_streams.has(track_name):
		var stream = amb_streams[track_name]
		if amb_player.stream != stream or not amb_player.playing:
			amb_player.stream = stream
			amb_player.play()

func stop_ambience():
	amb_player.stop()
	amb_player.stream = null

func play_sfx(sfx_name: String):
	if sfx_streams.has(sfx_name):
		# Create a temporary player so sounds can overlap
		var p = AudioStreamPlayer.new()
		p.stream = sfx_streams[sfx_name]
		p.bus = "SFX"
		add_child(p)
		p.play()
		p.finished.connect(p.queue_free)
