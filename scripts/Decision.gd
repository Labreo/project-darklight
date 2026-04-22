extends Control

# ===========================================================================
# Decision.gd
# ---------------------------------------------------------------------------
# The final choice in the Chief's office.
# ===========================================================================

@onready var chief_label = $UI/ChiefLabel

func _ready() -> void:
	chief_label.text = "\"Clock's ticking. The press is outside. What have you got?\""
	print("[Decision] Final scene active.")

func _on_accuse_felix_pressed() -> void:
	print("[Decision] Player accused FELIX.")
	_show_ending("Felix Gonzalez")

func _on_accuse_mallory_pressed() -> void:
	print("[Decision] Player accused MALLORY.")
	_show_ending("Mallory Perez")

func _show_ending(suspect_name: String) -> void:
	# Simple ending reveal
	var dialog = AcceptDialog.new()
	dialog.title = "Case Closed?"
	dialog.dialog_text = "You have officially accused %s.\n\nThe investigation concludes here. Thank you for playing Project Darklight!" % suspect_name
	dialog.confirmed.connect(func(): get_tree().quit()) # Or return to menu
	add_child(dialog)
	dialog.popup_centered()
