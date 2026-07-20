# Project Darklight: Kanak's Technical Q&A Prep Sheet
Use this sheet to prepare for technical questions that the examiner or reviewer might ask about your part of the codebase (State Management, Clue Logic, Gating, and Demo execution).

---

### Q1: Why did you use an Autoload Singleton (`GameState.gd`) instead of just keeping state variables in `Main.gd` or `map_screen.gd`?
* **The Core Answer:** "To preserve data across scene transitions."
* **Technical Detail:** 
  "In Godot, whenever you call `get_tree().change_scene_to_file()`, the engine completely unloads the current scene and frees all its nodes and script variables from memory. If our inventory of clues, visited rooms, or unlocked locations were stored in `Main.gd` or `map_screen.gd`, that progress would be wiped out every time the player navigated back to the map screen. 
  By registering `GameState.gd` as an Autoload singleton in the Project Settings, it is instantiated directly under the root viewport (`/root/GameState`) at startup. It exists independently of the active scene tree, acting as a persistent 'single source of truth' that any script in the game can query or update at any time."

---

### Q2: How is the clue inventory structured under the hood, and how do you prevent duplicate clues if the player clicks an object twice?
* **The Core Answer:** "We store clues as an array of dictionaries, and use an ID guard clause inside `add_clue()`."
* **Technical Detail:**
  "The inventory is declared as a type-safe array of dictionaries: `var clues: Array[Dictionary] = []`. Each clue dictionary is formatted as:
  ```gdscript
  var clue: Dictionary = {
      "id":          id,            # e.g., "C4"
      "title":       title,         # e.g., "Torn Envelope"
      "description": description,   # Narrative text
      "scene":       scene,         # Source environment
      "image_path":  image_path,    # Sprite path
      "timestamp":   Time.get_ticks_msec() / 1000.0
  }
  ```
  To prevent duplicate entries when clicking a hotspot multiple times, `add_clue` executes a check before appending:
  ```gdscript
  for existing in clues:
      if existing["id"] == id:
          return false # Silently reject duplicates
  ```
  If the clue is already in the array, the function exits immediately and returns `false`, preventing duplicate Polaroid cards or UI listings."

---

### Q3: How is the logical clue gating for C15 (Property Records) implemented in the Police Records room?
* **The Core Answer:** "We tie the physical visibility of the C15 Hotspot node to the presence of C4 in our inventory."
* **Technical Detail:**
  "In `police_record.gd`, we have an `@onready` reference to the physical hotspot node:
  ```gdscript
  @onready var hotspot_c15 = $PlayArea/Hotspots/C15_Hotspot
  ```
  We created an `_update_gating()` function that executes in `_ready()` and connects to the global `clue_added` signal. Inside this function, we write:
  ```gdscript
  func _update_gating() -> void:
      if hotspot_c15:
          var has_c4 = GameState.has_clue("C4")
          hotspot_c15.visible = has_c4
  ```
  If `C4` (the address from the Apartment) is not found, `visible` is set to `false`. In Godot, when a Control node's visibility is disabled, it is no longer rendered and its `_gui_input` event handlers are deactivated. This locks the player out of clicking it until they have acquired the prerequisite address clue."

---

### Q4: How does the game automatically combine the two note pieces (C11 and C12b) on the Film Set?
* **The Core Answer:** "By monitoring clue addition signals in `film_set.gd` and executing a check."
* **Technical Detail:**
  "Inside `film_set.gd`, we connect to the global signal bus:
  `GameState.clue_added.connect(_on_clue_added)`
  Every time a clue is collected, it triggers `_check_torn_note()`, which executes the following validation:
  ```gdscript
  if GameState.has_clue("C11") and GameState.has_clue("C12b"):
      if not GameState.has_clue("C_TORN_NOTE"):
          GameState.add_clue("C_TORN_NOTE", "Assembled Note", ...)
  ```
  We then fetch the room's local `ClueCard` reference and wait one frame (`await get_tree().process_frame`) to let the second piece's popup finish showing, before displaying the newly assembled note card."

---

### Q5: Why did you choose to use custom signals in `GameState.gd` instead of having it directly call functions on the UI overlay panels?
* **The Core Answer:** "To maintain a decoupled, observer-pattern architecture."
* **Technical Detail:**
  "If `GameState.gd` had to call `get_node("/root/Main/Overlays/ClueLogPanel").update_ui()`, the global state would be tightly coupled to our UI node paths. If we renamed a node or changed the layout inside the Godot editor, our logic scripts would break.
  Instead, `GameState.gd` simply broadcasts events: `emit_signal("clue_added", clue)`. UI panels like the Clue Log or Revisit list connect to this signal on startup. They act as independent observers. This makes our game logic highly modular, modularity makes debugging and refactoring extremely simple."

---

### Q6: How does the final accusation algorithm in the Chief's Office determine which ending to show?
* **The Core Answer:** "We match the accused suspect's name and run a key clue checklist inside `GameState.gd`."
* **Technical Detail:**
  "When the player clicks an accusation button in `Decision.gd`, the button fires `_show_ending(suspect_name)`. This method queries the state manager:
  `var ending = GameState.get_ending(suspect_name)`
  Inside `GameState.gd`, `get_ending()` executes:
  ```gdscript
  func get_ending(accused_name: String) -> Ending:
      if accused_name == "Felix Gonzalez":
          return Ending.BAD
      if accused_name == "Mallory Perez":
          var required = ["C4", "C11", "C14", "C15"]
          for cid in required:
              if not has_clue(cid):
                  return Ending.INCOMPLETE
          return Ending.TRUE
  ```
  If the player selects Felix, it returns `Ending.BAD` (referencing his party alibi). If they select Mallory, the function checks if all four critical keys are present. If so, it returns `Ending.TRUE`; if any key is missing, it returns `Ending.INCOMPLETE`. `Decision.gd` matches this enum to show the correct epilogue text and stars."
