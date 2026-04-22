extends CanvasLayer

# ===========================================================================
# StarAward.gd
# ---------------------------------------------------------------------------
# Shows the final rating based on the ending achieved.
# ===========================================================================

@onready var lbl_ending_name = $Panel/VBox/LblEndingName
@onready var lbl_stars       = $Panel/VBox/LblStars
@onready var lbl_rank        = $Panel/VBox/LblRank
@onready var btn_menu        = $Panel/VBox/BtnMenu

func setup(ending: GameState.Ending) -> void:
	match ending:
		GameState.Ending.TRUE:
			lbl_ending_name.text = "TRUE ENDING"
			lbl_stars.text = "★"
			lbl_rank.text = "Progress toward ★★ (2-star detective)"
			lbl_stars.add_theme_color_override("font_color", Color.YELLOW)
		GameState.Ending.BAD:
			lbl_ending_name.text = "BAD ENDING"
			lbl_stars.text = "✗"
			lbl_rank.text = "0 Stars - The wrong lead was followed."
			lbl_stars.add_theme_color_override("font_color", Color.RED)
		GameState.Ending.INCOMPLETE:
			lbl_ending_name.text = "INCOMPLETE ENDING"
			lbl_stars.text = "■"
			lbl_rank.text = "Insufficient evidence to secure a conviction."
			lbl_stars.add_theme_color_override("font_color", Color.GRAY)

func _on_btn_menu_pressed() -> void:
	# For now, just quit or reload the map. 
	# If there was a main menu, we'd go there.
	get_tree().quit()
