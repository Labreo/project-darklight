extends Control

func _ready() -> void:
	AudioManager.play_bgm("theme")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_on_start_pressed()

func _on_start_pressed() -> void:
	AudioManager.play_sfx("play_click")
	get_tree().change_scene_to_file("res://scenes/ui/map_screen.tscn")
	pass


func _on_quit_pressed() -> void:
	AudioManager.play_sfx("play_click")
	get_tree().quit()