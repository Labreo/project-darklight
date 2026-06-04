# Project Darklight: Kanak's Presentation Speech Notes & Demo Script (EXPANDED)
**Focus Areas:** Game State Architecture, Clue Inventory & Gating, Signal Decoupling, and Conducting the Live Demo.
**Estimated speaking time for these sections:** ~4 minutes of the 10-minute presentation.

---

## 1. Technical Deep Dive: Game State & Clue Logic (Slide 5)
*Speaker: Kanak*
*Slide Visuals: Code snippets of `GameState.gd` (clue structure, gating functions, and ending logic).*

### Key Talking Points:
* **The Role of the Autoload Singleton (`GameState.gd`):**
  "In Godot, when you change scenes, the active nodes are destroyed and memory is cleared. To keep track of what the player has done across the map, we registered `GameState.gd` as an **Autoload singleton**. This means the script is initialized when the game starts, sits at the root level of the engine, and persists its data regardless of which location scene is loaded in `GameView`."
* **Data Structure of the Clue Inventory:**
  "Our clue inventory is stored as an `Array[Dictionary]`. Each clue collected is stored as a structured dictionary containing:
  * `id` (e.g., `"C4"`, `"C15"`): Unique key.
  * `title` & `description`: Narratively rich display data.
  * `scene`: Where the clue was discovered, allowing filters.
  * `image_path`: Path to a sprite for Polaroid rendering.
  * `timestamp`: Captured using `Time.get_ticks_msec() / 1000.0` for chronological sorting."
* **Decoupled Architecture using Signals:**
  "To write clean, modular code, we avoided tight coupling between the scenes and the UI. `GameState` acts as an event broadcaster using custom signals:
  `signal clue_added(clue: Dictionary)`
  `signal scene_visited(scene_id: String)`
  When the player clicks a physical hotspot in a scene, the hotspot script only calls `GameState.add_clue()`. It has no knowledge of the Clue Log. `GameState` registers the clue and emits `clue_added`. The UI overlays (`ClueLogPanel`, `RevisitPanel`) listen to these signals and refresh themselves in real-time. This keeps the room scenes light and independent."
* **Logical Clue Gating & Combination:**
  "We programmed game mechanics that dynamically change environments based on inventory:
  * **Hotspot Gating:** In `police_record.gd`, the property records cabinet (Clue `C15`) is physically hidden unless the player has already found Mallory's Address (Clue `C4`). We evaluate this in `_update_gating()` with `GameState.has_clue("C4")`.
  * **Clue Auto-Assembly:** In `film_set.gd`, the script monitors clue additions. When both pieces of the torn note (`C11` and `C12b`) are in `GameState`, it automatically executes a combine function to reward the player with the unified clue card `C_TORN_NOTE` ('Assembled Note')."
* **Ending Validation Logic:**
  "When the player makes an accusation in the Chief's Office, the decision script calls `GameState.get_ending(accused_name)`. It checks if the critical evidence chain is complete:
  `var required = ["C4", "C11", "C14", "C15"]`
  If you accuse Mallory with all four, it returns `Ending.TRUE`. If you accuse Felix, it returns `Ending.BAD` (citing his alibi). If you accuse Mallory but are missing clues, it returns `Ending.INCOMPLETE`. This logic determines the epilogue text and the final star rating."

---

## 2. Live Demo Script & Narration (Slide 9)
*Speaker: Kanak (operating the laptop and narrating)*
*Live Visuals: Projecting the game running on Girish's PC.*

### Step-by-Step Demo Guide:

#### Step 1: The Start Screen
* **Action:** Launch the game, hover over the start button, and press play.
* **Narration:**
  "We begin our demo at the main menu. When we click play, the game loads the interactive Map screen. You can see the locations available to us. Let's travel to the Apartment first."

#### Step 2: Investigation & Hotspot Interactions (Apartment)
* **Action:** Move the mouse over the desk drawer/envelope, click to collect Clue `C4` (Torn envelope). Dismiss the card popup.
* **Narration:**
  "We are now inside the Apartment. Note that the cursor shape changes to a pointing hand when hovering over interactive objects, which is handled dynamically by our `Hotspot.gd` script. Clicking this torn envelope reveals our first **Key Clue: C4 - Torn envelope from Mallory**. This clue contains Mallory's address. Once we dismiss the popup, we can travel back to the map."

#### Step 3: Clue Combination (Film Set)
* **Action:** Open the Map, select Film Set. Click on the first torn piece (`C11`) and then the second torn piece (`C12b`). Watch the auto-assembly.
* **Narration:**
  "Next, let's head to the Film Set. Here we find two pieces of a torn letter. When I collect the first piece, it registers as a normal clue. But watch what happens when I collect the second piece. The room script detects both pieces are in our inventory, and automatically triggers the assembly of the **Assembled Note**, which is signed by a 'P'. This provides a critical breakthrough in our narrative."

#### Step 4: Gated Clue Progression (Police Records)
* **Action:** Go to the map, select Police Records. Look at the play area. Click on the folder/drawer for property records (`C15`).
* **Narration:**
  "Now we travel to the Police Records. Because we discovered Mallory's address (`C4`) in the apartment, the property records cabinet for `C15` is now active and visible on the screen. If we hadn't found C4 first, this hotspot would be completely hidden from the player. Clicking it yields the Property Records clue, locating Mallory's second address at 14 Crestview Lane."

#### Step 5: Interrogation (Police Records)
* **Action:** Click "Interrogate Mallory". Ask one or two questions (e.g., 'Why did you call Felicia that night?'), then click 'Leave Interrogation'.
* **Narration:**
  "While at the station, we can interrogate our suspects. Clicking 'Interrogate Mallory' hides our custom Godot UI and launches a branching dialogue tree powered by **Dialogic 2**. The player can ask questions in any order. The dialogue loop is managed via labels and jumps in GDScript, and returning from the timeline restores our navigation menu."

#### Step 6: Reviewing the Clue Log & Revisit Panel
* **Action:** Open the bottom menu, click "Clue Log". Scroll down. Then click "Revisit".
* **Narration:**
  "Before we make our final decision, we can check our Clue Log. Our UI dynamically generates cards showing the title, description, and source of every clue we've collected. The Revisit panel tracks our progress. It calculates the remaining clues in each scene and will display a green confirmation once all clues in a room have been fully discovered."

#### Step 7: The Concluding Accusation (Chief's Office)
* **Action:** Go to the Map, select Chief's Office/Decision. Click "Accuse Mallory Perez". Wait for the epilogue box, click OK, and view the Star Award screen.
* **Narration:**
  "Finally, we enter the Chief's Office to make our final accusation. Because we have collected all 4 key clues and correctly identified Mallory Perez as the culprit, we achieve the **True Ending**. The epilogue dialog explains that the police raided 14 Crestview Lane and found Felicia safe, and the game rewards us with a Yellow Star Detective rating on the final evaluation screen. This concludes our live demonstration."
