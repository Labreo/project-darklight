extends Control

class_name ButtonContainer


func _ready() -> void:
	$VBoxContainer/Start.pressed.connect(_on_start_pressed)
	$VBoxContainer/Quit.pressed.connect(_on_quit_pressed)


func _on_start_pressed() -> void:
	get_parent()._on_start_pressed()


func _on_quit_pressed() -> void:
	get_parent()._on_quit_pressed()
