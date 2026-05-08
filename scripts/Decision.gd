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

func _on_btn_back_pressed() -> void:
	print("[Decision] Player is returning to map.")
	get_tree().change_scene_to_file("res://scenes/ui/map_screen.tscn")


func _show_ending(suspect_name: String) -> void:
	var ending = GameState.get_ending(suspect_name)
	var epilogue_text = ""
	
	match ending:
		GameState.Ending.TRUE:
			epilogue_text = "Police drive to 14 Crestview Lane at dusk — the address from C15, unlocked by C4. Three cars, quiet approach.\n\nFelicia sits on the floor of the upstairs bedroom. Not hurt, just exhausted. Mallory sits on the dusty bed across from her, holding the childhood photograph.\n\nMallory: \"She was going to quit. Did you know that? She was going to quit and walk away and nobody would even notice I was never allowed to start.\"\n\nEpilogue: Felicia dropped all charges six weeks later. She never returned to acting. Mallory entered psychiatric care."
		
		GameState.Ending.BAD:
			epilogue_text = "Felix's lawyer arrives within the hour. Party guest list, bar tab, security footage. The alibi dismantles the case in under forty minutes.\n\nChief: \"He was at the Meridian party until 2 AM. We have him on three cameras. We have to let him go.\"\n\nEpilogue: An innocent man was detained. By the time the error was corrected, Mallory had crossed state lines. Felicia's whereabouts remained unknown."
		
		GameState.Ending.INCOMPLETE:
			epilogue_text = "Chief: \"You think it's the sister. Based on a torn note and a phone call. That's thin.\"\n\nA single patrol car reaches 14 Crestview Lane. The front door is open. The upstairs room is empty — a dusty impression on the floor where someone sat.\n\nEpilogue: Felicia was found three days later at a highway rest stop. Mallory had given her bus fare and let her go. The person responsible was never formally identified."

	# Show Epilogue
	var dialog = AcceptDialog.new()
	dialog.title = "The Investigation Concludes"
	dialog.dialog_text = epilogue_text
	dialog.dialog_autowrap = true
	dialog.min_size = Vector2(500, 300)
	
	dialog.confirmed.connect(func(): 
		# Show Star Award screen
		var award_scene = load("res://scenes/ui/StarAward.tscn").instantiate()
		get_tree().root.add_child(award_scene)
		award_scene.setup(ending)
		dialog.queue_free()
	)
	
	add_child(dialog)
	dialog.popup_centered()
