# Project Darklight: Harsh Raikar's Presentation Speech Notes (EXPANDED)
**Focus Areas:** UI Architecture, Bottom Navigation Bar, Panel Toggling Animations, Clue Log Card Rendering, and the Revisit Completion Board.
**Estimated speaking time for these sections:** ~2 minutes of the 10-minute presentation.

---

## 1. UI Control Architecture & BottomBar Layout
*Speaker: Harsh*
*Slide Visuals: Screen layouts highlighting the `BottomBar` structure and the hierarchy of overlay panels.*

### Key Talking Points:
* **The UI Layout Structure:**
  "My primary responsibility was to design and program the UI layout and menu navigation. In `Main.tscn`, we established a structured UI hierarchy using Godot's container nodes. We have a persistent **`BottomBar`** container anchored at the bottom of the viewport containing five buttons:
  * **Investigate:** Closes all menus to show the room.
  * **Talk:** Opens the suspect list.
  * **Map:** Opens the travel board.
  * **Clue Log:** Displays collected clues.
  * **Revisit:** Shows incomplete rooms."
* **Overlay Control Panels:**
  "We layered five distinct overlay control panels under an `Overlays` node. These panels act as modal menus that render on top of the main gameplay scene slot (`GameView`)."
* **Container Node Hierarchy:**
  "The UI is built using nested containers to maintain layout stability. Under `BottomBar`, we use an `HBoxContainer` to evenly space the buttons. For the overlay panels, we use a `ScrollContainer` wrapping a `VBoxContainer`. This guarantees that if the player collects a large number of clues, the menu scrolls automatically without overflowing or stretching the screen."

---

## 2. Interactive Panel Toggling & Tween Transitions
*Speaker: Harsh*
*Slide Visuals: GDScript snippet of `_toggle_panel` and tween animations from `main.gd`.*

### Key Talking Points:
* **Toggle Menu Logic:**
  "To handle opening and closing menus, we wrote `_toggle_panel(panel)` in `main.gd`. If the player clicks a button for an already open panel, the game closes it. If they click a button for a different panel, the game hides all other active panels and fades in the new one."
* **Polished Tween Modulations:**
  "To make the UI feel responsive, we used Godot's tweening API. When a panel opens, we set its visibility to true, set its opacity (`modulate:a`) to `0.0`, and slide the value to `1.0` over `0.18` seconds:
  ```gdscript
  func _show_panel(panel: Control) -> void:
      panel.visible = true
      panel.modulate.a = 0.0
      var tween := create_tween()
      tween.tween_property(panel, "modulate:a", 1.0, 0.18)
  ```
  When closing a panel, we tween it back to `0.0` over `0.14` seconds and then call a callback to set `visible = false`. This prevents the UI from feeling jarring."

---

## 3. Dynamic Card Rendering: The Clue Log
*Speaker: Harsh*
*Slide Visuals: Screenshot of the Clue Log Panel containing Polaroid-style cards. Code snippet of `_make_clue_card()`.*

### Key Talking Points:
* **Generating Clue Cards Dynamically:**
  "When the player opens the Clue Log, `_refresh_clue_log()` clears the list container and fetches the current array from `GameState.clues`. If empty, it adds a placeholder label. If clues are present, it loops through them and instantiates a visual `PanelContainer` card for each clue."
* **Card Components & Formatting Parameters:**
  "Each generated clue card is built programmatically inside `_make_clue_card(clue)` using a `PanelContainer` that houses a `VBoxContainer` with a theme separation parameter of `6` pixels. The card contains:
  * **Image Thumbnail:** Checks if the clue dictionary contains an `image_path`. If it does, the texture is loaded via `ResourceLoader.load(img_path, "Texture2D")` and displayed inside a `TextureRect`. We wrap it in a background `PanelContainer` set to a minimum height of `90` pixels. The image stretch mode is set to `STRETCH_KEEP_ASPECT_CENTERED` and expand mode is set to `EXPAND_FIT_WIDTH_PROPORTIONAL` to prevent distortion.
  * **Title Label:** Colored in gold/yellow (`Color(1.0, 0.85, 0.3)`) to denote importance.
  * **Location Stamp:** Displays which scene the clue belongs to, colored in light grey (`Color(0.7, 0.7, 0.7)`) with the font size set to `16` points.
  * **Description Field:** Uses auto-wrapping (`autowrap_mode = TextServer.AUTOWRAP_WORD_SMART`) to fit descriptive text within the card boundaries."

---

## 4. The Revisit Board: Guiding the Player
*Speaker: Harsh*
*Slide Visuals: Screenshot of the Revisit Panel showing active buttons vs. a completed location message.*

### Key Talking Points:
* **Helping the Player Navigate:**
  "To prevent players from getting stuck, we created the **Revisit Panel**. Instead of forcing the player to guess which rooms they haven't finished searching, the Revisit Panel dynamically evaluates the room states."
* **Progress Calculations & Dynamic Button Instancing:**
  "The script loops through all scenes in `GameState.visited_scenes`. For each visited scene, it calls `GameState.get_clues_remaining(scene_id)`. If the remaining count is greater than zero, it instantiates a button labeled with the room name and the number of clues remaining:
  `btn.text = "%s (%d clues left)" % [display_name, remaining]`
  We programmatically map the scene ID back to the level scene resource:
  `var path := "res://scenes/locations/%s.tscn" % scene_id`
  Then, we connect the button's `pressed` signal to a lambda function that triggers `travel_to(path)`.
* **Completed States:**
  "If the player has successfully found all clues in every visited room, the buttons are cleared, and a green success label is displayed reading: **'All visited locations fully searched.'** styled in light green (`Color(0.4, 0.9, 0.4)`) and centered on the panel. This tells the player they have enough evidence to proceed to the final accusation."
