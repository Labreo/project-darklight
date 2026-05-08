extends Control

# ===========================================================================
# police_record.gd
# ---------------------------------------------------------------------------
# Logic for the Police Records scene.
# Handles gating C15 behind C4 and the evidence board progression.
# ===========================================================================

@onready var hotspot_c15 = $PlayArea/Hotspots/C15_Hotspot

func _ready() -> void:
	# Main.gd handles adding this to visited scenes.
	
	# Initial check for C15 gating
	_update_gating()
	
	# Listen for clue additions to update gating dynamically
	GameState.clue_added.connect(_on_clue_added)
	
	print("[Police Records] Scene ready.")

func _on_clue_added(_clue: Dictionary) -> void:
	_update_gating()
	_check_evidence_board()

func _update_gating() -> void:
	# C15 only appears if C4 (Mallory's address) is found
	if hotspot_c15:
		var has_c4 = GameState.has_clue("C4")
		hotspot_c15.visible = has_c4
		if not has_c4:
			print("[Police Records] C15 hidden - C4 not found yet.")

func _check_evidence_board() -> void:
	# Check if the sequence clues are all found
	# C11: Note part 1, C14: Mallory's calls, C4: Mallory's address, C15: Property records
	var required = ["C11", "C14", "C4", "C15"]
	var all_found = true
	for cid in required:
		if not GameState.has_clue(cid):
			all_found = false
			break
	
	if all_found:
		print("[Police Records] Evidence board completed! Unlocking final decision.")
		# In a real game we'd play an animation or show a UI notification.
		# For now, we'll just ensure the player knows they can proceed.
		# We could automatically unlock the Decision scene on the map here.
		GameState.unlock_location("decision")
