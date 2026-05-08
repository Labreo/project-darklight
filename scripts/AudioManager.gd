extends Node

var bgm_player: AudioStreamPlayer
var amb_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var bgm_streams = {
    "theme": preload("res://audio/bgm/theme_audio.ogg"),
    "case_start": preload("res://audio/bgm/case_Start.ogg"),
    "decision": preload("res://audio/bgm/decision.ogg"),
    "interrogation": preload("res://audio/bgm/interrogations.ogg")
}

var amb_streams = {
    "apartment": preload("res://audio/scene_ambience/apartment.ogg"),
    "police_station": preload("res://audio/scene_ambience/police_station.ogg")
}

var sfx_streams = {
    "play_click": preload("res://audio/ui_system_navigation/play_click_button.wav"),
    "ui_click": preload("res://audio/ui_system_navigation/inGame_click_button.wav"),
    "clue_found": preload("res://audio/ui_system_navigation/clue_found.wav"),
    "act_0": preload("res://audio/character_action_specific_sfx/act_0.ogg"),
    "act_2": preload("res://audio/character_action_specific_sfx/act_2.ogg"),
    "act1_3": preload("res://audio/character_action_specific_sfx/act1_3.ogg")
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
