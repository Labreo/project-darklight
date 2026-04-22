extends Control

# ===========================================================================
# ChiefOffice.gd
# ---------------------------------------------------------------------------
# The intermediate scene before the final decision.
# ===========================================================================

func _ready() -> void:
	# Register visit (doesn't have clues so it won't show in Revisit)
	GameState.visit_scene("ChiefOffice")
	print("[Chief Office] Scene ready.")

func _on_desk_hotspot_activated(_clue_id: String) -> void:
	# When the player clicks the desk/chief, move to the decision scene.
	# We use change_scene_to_file because the decision is a standalone finale.
	get_tree().change_scene_to_file("res://scenes/Decision.tscn")
