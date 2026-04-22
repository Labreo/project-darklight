extends Control

# ===========================================================================
# film_set.gd
# ---------------------------------------------------------------------------
# Lightweight controller for the Film Set scene.
# Handles specific logic like the torn note pieces (C11 and C12b).
# ===========================================================================

func _ready() -> void:
	# Main.gd handles adding this to the visited scenes list.
	
	# Listen for clues being added
	GameState.clue_added.connect(_on_clue_added)
	
	# If we already have the pieces but haven't triggered the assembled note, check now
	_check_torn_note()
	
	print("[Film Set] Scene ready.")

func _on_clue_added(_clue: Dictionary) -> void:
	_check_torn_note()

func _check_torn_note() -> void:
	# Check if both pieces are collected
	if GameState.has_clue("C11") and GameState.has_clue("C12b"):
		# Check if we already assembled it
		if not GameState.has_clue("C_TORN_NOTE"):
			print("[Film Set] Both note pieces found! Assembling static note.")
			
			GameState.add_clue(
				"C_TORN_NOTE",
				"Assembled Note",
				"The two pieces fit perfectly together:\n'Meet me tonight. please. just talk.\nI know what you did, and I won't cover for you anymore.' — signed P.\n\nThis is a massive breakthrough.",
				"Film Set"
			)
			# Here we could theoretically trigger a popup minigame instead,
			# but a static reveal keeps us on schedule!
