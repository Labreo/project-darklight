extends Node

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------
signal clue_added(clue: Dictionary)
signal location_unlocked(location_id: String)
signal scene_visited(scene_id: String)

# ---------------------------------------------------------------------------
# Clue Inventory
# Each clue is a Dictionary:
#   {
#     "id":          String  – unique identifier, e.g. "bloody_knife"
#     "title":       String  – display name shown on the clue card
#     "description": String  – what the clue reveals
#     "scene":       String  – scene / location where it was discovered
#     "timestamp":   float   – game-time when it was collected
#   }
# ---------------------------------------------------------------------------
var clues: Array[Dictionary] = []

# ---------------------------------------------------------------------------
# Location & scene tracking
# ---------------------------------------------------------------------------
## All location ids that the player has unlocked so far.
var unlocked_locations: Array[String] = ["apartment"]

## All scene ids the player has visited (for the Revisit panel).
var visited_scenes: Array[String] = []

# Current mode enum (mirrors BottomBar button order)
enum Mode { NONE, INVESTIGATE, TALK, MAP, CLUE_LOG, REVISIT }
var current_mode: Mode = Mode.NONE

# ---------------------------------------------------------------------------
# add_clue
# Adds a clue to the inventory.  Silently ignores duplicates (same id).
# Emits clue_added so any UI panel can refresh itself.
# ---------------------------------------------------------------------------
func add_clue(id: String, title: String, description: String, scene: String) -> void:
	# Guard against duplicates
	for existing in clues:
		if existing["id"] == id:
			return

	var clue: Dictionary = {
		"id":          id,
		"title":       title,
		"description": description,
		"scene":       scene,
		"timestamp":   Time.get_ticks_msec() / 1000.0,
	}
	clues.append(clue)
	emit_signal("clue_added", clue)
	print("[GameState] Clue collected: ", title, " (", id, ")")

# ---------------------------------------------------------------------------
# unlock_location
# ---------------------------------------------------------------------------
func unlock_location(location_id: String) -> void:
	if location_id not in unlocked_locations:
		unlocked_locations.append(location_id)
		emit_signal("location_unlocked", location_id)

# ---------------------------------------------------------------------------
# visit_scene
# ---------------------------------------------------------------------------
func visit_scene(scene_id: String) -> void:
	if scene_id not in visited_scenes:
		visited_scenes.append(scene_id)
		emit_signal("scene_visited", scene_id)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
func get_clue_by_id(id: String) -> Dictionary:
	for clue in clues:
		if clue["id"] == id:
			return clue
	return {}

func has_clue(id: String) -> bool:
	return get_clue_by_id(id).is_empty() == false