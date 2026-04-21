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
#     "id":          String  – unique identifier, e.g. "C4"
#     "title":       String  – display name shown on the clue card
#     "description": String  – what the clue reveals
#     "scene":       String  – scene / location where it was discovered
#     "image_path":  String  – res:// path to the clue thumbnail (may be "")
#     "timestamp":   float   – game-time when it was collected
#   }
# ---------------------------------------------------------------------------
var clues: Array[Dictionary] = []

# ---------------------------------------------------------------------------
# Key Clue tracking  (from Game Script v2 / GDD)
# ---------------------------------------------------------------------------
## The IDs of clues that are narratively critical.
## C4  = Torn envelope from Mallory   (The Apartment)
## C11, C12, C14, C15 are reserved for future scenes.
const KEY_CLUE_IDS : Array[String] = ["C4", "C11", "C12", "C14", "C15"]

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
# Scene handoff
# ---------------------------------------------------------------------------
## Written by map_screen.gd before calling change_scene_to_file("Main.tscn").
## main.gd reads this in _ready() to know which location to load into GameView.
## Cleared after use.
var pending_scene_path: String = ""

# ---------------------------------------------------------------------------
# add_clue
# Adds a clue to the inventory. Returns true if new, false if duplicate.
# Emits clue_added so any UI panel can refresh itself.
# ---------------------------------------------------------------------------
func add_clue(id: String, title: String, description: String, scene: String, image_path: String = "") -> bool:
	# Guard against duplicates
	for existing in clues:
		if existing["id"] == id:
			return false

	var clue: Dictionary = {
		"id":          id,
		"title":       title,
		"description": description,
		"scene":       scene,
		"image_path":  image_path,
		"timestamp":   Time.get_ticks_msec() / 1000.0,
	}
	clues.append(clue)
	print("[GameState] New clue added: ", id)
	emit_signal("clue_added", clue)

	# Log extra context for key clues so the console makes the importance clear.
	if id in KEY_CLUE_IDS:
		print("[GameState] ★ KEY CLUE collected: ", title, " (", id, ")")
		print("[GameState]   Key clues found so far: ", _found_key_clue_ids())
	else:
		print("[GameState] Clue collected: ", title, " (", id, ")")
	
	return true

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

# ---------------------------------------------------------------------------
# Key-clue helpers
# ---------------------------------------------------------------------------

## Returns an Array of KEY_CLUE_IDS that have already been collected.
func _found_key_clue_ids() -> Array[String]:
	var found : Array[String] = []
	for clue in clues:
		if clue["id"] in KEY_CLUE_IDS:
			found.append(clue["id"])
	return found

## Returns true when the player has collected every key clue.
## Useful for gating the act-two transition.
func has_all_key_clues() -> bool:
	for kid in KEY_CLUE_IDS:
		if not has_clue(kid):
			return false
	return true

## Returns how many key clues remain uncollected (handy for a HUD counter).
func remaining_key_clues() -> int:
	return KEY_CLUE_IDS.size() - _found_key_clue_ids().size()