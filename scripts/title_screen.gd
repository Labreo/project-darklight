extends Control



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_on_start_pressed()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/map_screen.tscn")
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()