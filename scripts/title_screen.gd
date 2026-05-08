extends Control

func _ready() -> void:
	AudioManager.play_bgm("theme")

func _on_start_pressed() -> void:
	AudioManager.stop_bgm()
	get_tree().change_scene_to_file("res://scenes/ui/map_screen.tscn")
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()