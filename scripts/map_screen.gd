extends Control

# ===========================================================================
# map_screen.gd
# ---------------------------------------------------------------------------
# Handles the location map UI.  Each location button loads the game's
# persistent Main shell (which owns the BottomBar) and tells it to travel
# to that location.
#
# The flow is:
#   map_screen.tscn  -->  Main.tscn  (persistent shell with BottomBar)
#                              └── GameView  (swappable content area)
#                                       └── Apartment.tscn  (loaded here)
#
# If this script runs while ALREADY inside Main (i.e. the map is shown as
# an overlay panel), call Main's travel function directly instead of doing
# a full scene change.
# ===========================================================================

func _ready() -> void:
	# Wire every location button.
	# get_node_or_null is used so missing buttons silently skip rather than crash.
	var apartment_btn := get_node_or_null("ApartmentButton")
	if apartment_btn:
		apartment_btn.pressed.connect(_on_apartment_pressed)

	var film_btn := get_node_or_null("FilmSetButton")
	if film_btn:
		film_btn.pressed.connect(_on_film_set_pressed)

	var police_btn := get_node_or_null("PoliceStationButton")
	if police_btn:
		police_btn.pressed.connect(_on_police_station_pressed)

# ---------------------------------------------------------------------------
# Button callbacks
# ---------------------------------------------------------------------------

func _on_apartment_pressed() -> void:
	_travel_to("res://scenes/locations/Apartment.tscn")

func _on_film_set_pressed() -> void:
	# Placeholder: Film Set not built yet.
	print("[MapScreen] Film Set not yet implemented.")

func _on_police_station_pressed() -> void:
	# Placeholder: Police Station not built yet.
	print("[MapScreen] Police Station not yet implemented.")

# ---------------------------------------------------------------------------
# Core travel helper
# ---------------------------------------------------------------------------

## _travel_to
## Loads Main.tscn (the persistent BottomBar shell) and passes the target
## scene path so Main can display it in its GameView slot.
func _travel_to(scene_path: String) -> void:
	# Cache the destination so Main.gd can read it on _ready.
	GameState.pending_scene_path = scene_path

	# Change to Main. Main._ready() will pick up pending_scene_path and
	# load it into the GameView node.
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
