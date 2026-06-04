# Project Darklight: Malcolm's (Mallu) Presentation Speech Notes (EXPANDED)
**Focus Areas:** Game Idea/Concept, Software Process Model, Godot Engine Architecture, Sound Design (Audio Manager), and Art/Visual Direction.
**Estimated speaking time for these sections:** ~6 minutes of the 10-minute presentation.

---

## 1. Project Concept & Game Narrative (The Idea)
*Speaker: Malcolm*
*Slide Visuals: Main menu screen, map screen showing locations, and character portraits.*

### Key Talking Points:
* **The Elevator Pitch:** 
  "Project Darklight is a narrative-driven, point-and-click detective mystery game developed in the Godot engine. Players step into the shoes of a lead investigator tasked with solving the sudden and high-profile disappearance of Felicia Gonzalez, a rising film actress."
* **The Core Suspect Dynamics:**
  "Our narrative revolves around a classic tension triangle between two primary suspects:
  1. **Felix Gonzalez (The Husband):** A man under financial pressure, who argued frequently with Felicia about money and her desire to quit acting. He claims she stayed out after an argument and presents a seemingly bulletproof alibi.
  2. **Mallory Perez (The Estranged Sister):** Felicia’s sister, who harbors a deep, complex mix of sibling jealousy over Felicia's fame and a protective desire to shield her from the industry's pressures."
* **Gameplay Loop & Progression:**
  "The gameplay is split into three core phases:
  * **Traversing the Map:** Traveling between environments (The Apartment, The Film Set, and Police Records) using an interactive map.
  * **Searching for Hotspots:** Investigating environments to find and collect clues. Out of all the clues, there are **four Key Clues** (`C4` - Torn envelope, `C11` - Torn note piece 1, `C14` - Call history, and `C15` - Property deed) that are critical to the case.
  * **Interrogation:** Questioning Felix and Mallory at the police station using branching dialogue trees to gather context and cross-reference their stories.
  * **The Final Accusation:** The game culminates in the Chief's Office, where the player must choose who to charge based on the evidence collected."
* **The Three Narrative Endings:**
  "Depending on the evidence gathered and the suspect chosen, the player triggers one of three ending states:
  1. **The True Ending (Accuse Mallory + All 4 Key Clues Found):** The detective traces the clues to Mallory's property at 14 Crestview Lane, finding Felicia safe. It is revealed that Felicia wanted to escape the spotlight, and Mallory was hiding her.
  2. **The Bad Ending (Accuse Felix):** Felix's alibi immediately dismantles the case with his airtight alibi (confirmed by security cameras and guest lists at the Meridian party). Felix is released, Mallory flees across state lines, and Felicia remains missing.
  3. **The Incomplete Ending (Accuse Mallory but missing Key Clues):** The police raid 14 Crestview Lane but arrive too late. Felicia is found days later at a highway rest stop, Mallory has fled, and the case remains cold."

---

## 2. Software Development Process Model
*Speaker: Malcolm*
*Slide Visuals: Diagram showing Iterative & Incremental cycle.*

### Key Talking Points:
* **Iterative and Incremental Development:**
  "Because game development requires a tight, continuous integration of visual art, dialogue scripts, engine logic, and audio systems, we adopted an **Iterative and Incremental Development Model** rather than a linear Waterfall approach. This allowed us to build, test, and polish the game in distinct cycles."
* **Breakdown of Development Iterations:**
  * **Iteration 1: Core Framework & Traversal:** "We began by setting up the persistent main shell (`Main.tscn`), building the global state singleton (`GameState.gd`), and establishing scene transitions (`travel_to()`) so the player could navigate the map and trigger click events on hotspots."
  * **Iteration 2: Narrative & Branching Dialogue:** "We integrated the **Dialogic 2** plug-in, configured the character database, and wrote the node-based branching logic for Felix's and Mallory's interrogations."
  * **Iteration 3: Audio, Gating & Polishing:** "In the final iteration, we developed the dynamic `AudioManager`, added clue gating logic (e.g., locking the property records clue `C15` until Mallory's address clue `C4` is found), and integrated ending epilogues and the Star Award evaluation screen."
* **Benefits of This Approach:**
  "Adopting this model ensured we had a playable build at the end of each sprint. If we encountered bugs—such as dialogue trees breaking or signals failing to refresh the UI—we could isolate and fix them immediately without disrupting other parts of the codebase."

---

## 3. Tech Stack & Godot Engine Architecture
*Speaker: Malcolm*
*Slide Visuals: Code snippets of `Main.gd` and `GameState.gd` structure, and a diagram of the Node Tree.*

### Key Talking Points:
* **Why Godot Engine 4.6 (GL Compatibility)?**
  "We chose Godot 4 because it is open-source, lightweight, compiles instantly, and features a state-of-the-art UI system that is perfect for point-and-click, UI-driven narrative games."
* **Persistent Shell Architecture:**
  "Rather than changing the entire viewport scene (which would break UI persistence), we designed a **Persistent Shell Pattern** inside `Main.tscn`. The main scene owns the permanent `BottomBar` navigation menu and an empty `GameView` control container. When traveling, `Main.gd` dynamically loads and instantiates the target location scene (`Apartment.tscn`, `Film_Set.tscn`, etc.) as a child of `GameView`, applying fullscreen layouts programmatically:
  `_current_scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)`
  This makes transitions instantaneous and keeps the underlying game structure clean."
* **Scene Transition Handoff Protocol:**
  "We resolved a classic Godot scene management challenge using a **caching handoff protocol** in `map_screen.gd` and `main.gd`. 
  1. When a location button is clicked on the map screen, `map_screen.gd` caches the destination path inside `GameState.pending_scene_path`.
  2. It then changes the scene to `Main.tscn` via `get_tree().change_scene_to_file()`.
  3. When `Main.tscn` initializes, its `_ready()` function checks if `pending_scene_path` is populated. If it is, it consumes the path, clears the global variable, and calls `travel_to()` to load the level inside the persistent shell. This prevents double scene loads and guarantees UI overlays remain perfectly aligned."
* **The Global Game State Singleton (`GameState.gd`):**
  "We registered `GameState.gd` as an Autoload singleton. It manages all persistent variables across scenes:
  * A `clues` array of dictionaries containing unique IDs, titles, descriptions, and scene sources.
  * Helper logic like `has_all_key_clues()` and `get_clues_remaining()` to drive UI rendering.
  * Ending validation checks: `get_ending()` checks for key clue IDs (`C4`, `C11`, `C14`, `C15`) to decide whether to trigger the True or Incomplete ending when Mallory is accused."
* **Decoupled Architecture using Signals:**
  "To prevent spaghetti code, our components communicate through native Godot signals. For example, when a clue is discovered, `GameState` emits `clue_added`. The `ClueLogPanel` and `RevisitPanel` listen for this signal and automatically update themselves. There is no direct dependency between a room's physical hotspot and the UI panels."
* **UI Animation Tweens:**
  "We leveraged Godot's built-in `Tween` engine to create smooth transitions. For instance, when opening or closing overlay panels, we fade them in and out by interpolating the `modulate:a` (alpha) property between `0.0` and `1.0` over `0.18` seconds, giving the UI a premium, responsive feel."

---

## 4. Sound Design & Audio Manager
*Speaker: Malcolm*
*Slide Visuals: Code snippet from `AudioManager.gd` showing the dynamic SFX spawning and bus routing.*

### Key Talking Points:
* **Atmospheric Audio Integration:**
  "To build the noir detective atmosphere, our sound design needed to be dynamic and layered. We created a custom singleton called **`AudioManager.gd`** to handle all audio operations."
* **Separate Audio Buses:**
  "We configured three dedicated hardware-equivalent buses in the Godot mixer: **Music**, **Ambience**, and **SFX**. This allows us to balance levels independently and apply different acoustic effects (like low-pass filters for phone audio) depending on the scene."
* **Compile-Time Preloading:**
  "To eliminate runtime stuttering or lag, we preload all audio streams (like `theme_audio.ogg`, `interrogations.ogg`, and UI click waves) into dictionary structures at compilation. This ensures zero-latency playback."
* **Preloaded Asset Directory Mapping:**
  "Our preloaded music streams map directly to:
  * **BGM:** `res://audio/bgm/theme_audio.ogg` (Main Theme), `res://audio/bgm/case_Start.ogg` (Intro), `res://audio/bgm/decision.ogg` (Final Choice), and `res://audio/bgm/interrogations.ogg` (Interrogation screen).
  * **Ambience:** `res://audio/scene_ambience/apartment.ogg` and `res://audio/scene_ambience/police_station.ogg` which play in the background to build presence.
  * **SFX:** `res://audio/ui_system_navigation/play_click_button.wav` (UI Navigation) and `res://audio/ui_system_navigation/clue_found.wav` (Clue unlock cue)."
* **Dynamic SFX Player Spawning (Memory Optimization):**
  "A common bug in basic game audio is that playing a sound effect will cut off a currently playing one. We solved this by implementing a **Dynamic Spawning Pattern** in GDScript:
  ```gdscript
  func play_sfx(sfx_name: String):
      if sfx_streams.has(sfx_name):
          var p = AudioStreamPlayer.new()
          p.stream = sfx_streams[sfx_name]
          p.bus = "SFX"
          add_child(p)
          p.play()
          p.finished.connect(p.queue_free)
  ```
  Every time a sound effect is requested, a new player is instantiated in code, added to the tree, and played. Crucially, we connect the `finished` signal to `queue_free`, ensuring that the player automatically deletes itself from memory once the sound finishes. This allows multiple sounds to overlap perfectly and prevents memory leaks."

---

## 5. Art Direction & Visual Aesthetics
*Speaker: Malcolm*
*Slide Visuals: Comparison slide showing Room Backgrounds, custom Bottom Bar, and Polaroid Clue Cards.*

### Key Talking Points:
* **The Noir Visual Identity:**
  "As the artist, my objective was to craft a dark, atmospheric Neo-noir visual language. The muted, high-contrast backgrounds of the Apartment, the Film Set, and the Police Records office are designed to place the player in a gritty, high-stakes investigation."
* **Visual Asset Directories:**
  "The custom graphics for our scenes are organized as follows:
  * **Environments:** `res://art/backgrounds/ApartmentFinal.jpg`, `res://art/backgrounds/FilmSet.png`, and `res://art/backgrounds/PoliceRecords.png`.
  * **UI Assets:** `res://art/Bottom screen/bottom Screen.png` (Base layout) and `res://art/Bottom screen/bottom Screen inputs.png` (Console Buttons).
  * **Character Sprites:** `res://art/Character sprites/FelixSprite1.png` and `res://art/Character sprites/mallory.png`."
* **Custom Diegetic HUD:**
  "Instead of using generic modern buttons, we designed custom assets for the navigation panels (`bottom Screen.png` and `bottom Screen inputs.png`). The HUD acts as a physical terminal, grounding the player in the detective role."
* **Interactive Hotspot Micro-Animations:**
  "To ensure a satisfying user experience and prevent frustrating pixel-hunting, we added a subtle pulse animation to crucial items. In `Hotspot.gd`, we utilize a loop tween to scale the interactive Control nodes:
  `tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.9)`
  This creates a gentle, breathing visual cue (scaling up and down by 6% every 0.9 seconds) that naturally guides the player's eye to important evidence."
* **Polaroid-Style Clue Cards:**
  "When a player discovers a clue, the game displays a Polaroid-style card popup (`ClueCard.tscn`). This card fetches the associated sprite asset path from the `GameState` clue dictionary and renders a physical-looking photograph alongside the text. This reinforces the player's sense of discovery."
