
\# Project Darklight: Kanak's Presentation Speech Notes & Demo Script (EXPANDED)
**Focus Areas:** Game State Architecture, Clue Logic, Software Engineering Principles, Project Management Execution, and Conducting the Live Demo.
**Estimated speaking time for these sections:** ~4 minutes of the 10-minute presentation.

---

## 1. Technical Deep Dive: Game State & Clue Logic (Slide 5)
*Speaker: Kanak*  
*Slide Visuals: Code snippets of `GameState.gd` (clue structure, gating functions, and ending logic).*

### Key Talking Points:

* **The Autoload Singleton as a Single Source of Truth (SSOT):**
  "In Godot's runtime model, scene transitions automatically destroy existing nodes and release their heap memory to prevent leaks. In a narrative-driven game, this presents a major architectural challenge: how do we prevent state fragmentation when moving between rooms? We solved this by implementing the **Singleton Pattern**, registering `GameState.gd` as an **Autoload singleton**. This means the script is instantiated by the engine at startup, resides at the root level of the scene tree (`/root/GameState`), and remains active for the entire application lifecycle. 

  This singleton acts as our **Single Source of Truth (SSOT)**. Instead of each location scene (like the Apartment or Film Set) maintaining its own local flags or attempting to pass parameters during scene changes, all data—including collected evidence, visited rooms, and suspect alibi flags—is centralized here. By centralizing our state, we eliminated race conditions and out-of-sync room variables, ensuring a robust and reliable foundation for the entire game loop."

* **Data Modeling & Encapsulation of the Clue Inventory:**
  "Our clue inventory is modeled as an `Array[Dictionary]`, enforcing a strict data contract. We applied the principle of **Encapsulation** by making the raw inventory list private and exposing it only through specific interface methods like `add_clue()`, `has_clue()`, and `get_collected_clues()`. This prevents external room scripts from directly modifying the array, which could lead to malformed data or duplicate entries. 

  Each clue dictionary follows a structured data schema with dedicated key-value pairs:
  * `id` (e.g., `"C4"`, `"C15"`): Unique alphanumeric string serving as a primary key.
  * `title` & `description`: Rich narrative strings consumed by the UI.
  * `scene`: The room origin ID, used to calculate location completeness metrics.
  * `image_path`: A string path to a sprite asset, allowing the UI to dynamically render Polaroid thumbnails.
  * `timestamp`: Recorded using `Time.get_ticks_msec() / 1000.0` at the moment of collection. This enables chronological tracking of the player's investigation sequence, providing valuable debugging logs and ordered UI displays."

* **Loose Coupling & Event-Driven Architecture (Observer Pattern):**
  "To write clean, maintainable, and testable code, we utilized an **Event-Driven Architecture (the Observer Pattern)** via Godot's custom signals. The game state singleton acts as the subject/publisher, while the UI panels and rooms act as observers/subscribers. We defined signals such as:
  `signal clue_added(clue: Dictionary)`  
  `signal scene_visited(scene_id: String)`  

  When a player clicks an interactive hotspot in a room, the hotspot script only needs to notify the global state: `GameState.add_clue(...)`. The room has absolutely no knowledge of the Clue Log, the Suspect List, or how they are rendered. Once the singleton updates the state, it broadcasts the `clue_added` signal. The `ClueLogPanel` and `RevisitPanel` listen for this signal and automatically refresh their visuals. This loose coupling meant that our team could work in parallel: Harsh could redesign the entire UI layout in isolation, and I could modify the core state logic, without either of us breaking the other's code. It also drastically simplified debugging, as data flow is unidirectional and event-driven."

* **Conditional Gating & Combinatorial Logic:**
  "To deliver a true detective experience, we programmed dynamic gameplay mechanics using two distinct logical patterns:
  * **Prerequisite Gating:** In `police_record.gd`, the property records cabinet (Clue `C15`) is physically hidden unless the player has already found Mallory's Address (Clue `C4`). We evaluate this dependency check dynamically at room load via `GameState.has_clue("C4")`. By gating hotspots based on global inventory state rather than hardcoding scene-to-scene dependencies, we keep room controllers highly decoupled and easy to manage.
  * **Combinatorial Clue Assembly:** In `film_set.gd`, the room script monitors incoming inventory changes. When both fragments of the torn letter (`C11` and `C12b`) are detected in the singleton, it automatically triggers a combination event. The script removes the two fragment dictionaries from the inventory and registers a single, unified `C_TORN_NOTE` ('Assembled Note') card. This demonstrates a mini rule-engine architecture, translating player discovery events into progression milestones without manual intervention."

---

## 2. Live Demo Script & Narration (Slide 9)
*Speaker: Kanak (operating the laptop and narrating)*  
*Live Visuals: Projecting the game running on Girish's PC.*

### Step-by-Step Demo Guide:

#### Step 1: The Start Screen
* **Action:** Launch the game, hover over the start button, and press play.
* **Narration:**
  "We begin our demo at the main menu. When we click play, the game loads the interactive Map screen. This represents our persistent shell, verifying our architectural goal of seamless container-based room routing without full window restarts. Let's travel to the Apartment first."

#### Step 2: Investigation & Hotspot Interactions (Apartment)
* **Action:** Move the mouse over the desk drawer/envelope, click to collect Clue `C4` (Torn envelope). Dismiss the card popup.
* **Narration:**
  "We are now inside the Apartment. Note that the cursor shape changes to a pointing hand when hovering over interactive objects, which is handled dynamically by our reusable `Hotspot.gd` class. Here we see the **Single Responsibility Principle (SRP)** in action: the hover effect is handled entirely by the hotspot node, while clicking delegates state modification to our global singleton. Clicking this torn envelope reveals our first **Key Clue: C4 - Torn envelope from Mallory**, showing her address. Once we dismiss the popup, we can travel back to the map."

#### Step 3: Clue Combination (Film Set)
* **Action:** Open the Map, select Film Set. Click on the first torn piece (`C11`) and then the second torn piece (`C12b`). Watch the auto-assembly.
* **Narration:**
  "Next, let's head to the Film Set. Here we find two pieces of a torn letter. When I collect the first piece, it registers as a normal clue. But watch what happens when I collect the second piece. The room controller detects both pieces in our inventory and automatically triggers the assembly of the **Assembled Note**, signed by a 'P'. This demonstrates dynamic clue combination—a feature we added incrementally in Phase 3 after our core database was fully stabilized."

#### Step 4: Gated Clue Progression (Police Records)
* **Action:** Go to the map, select Police Records. Look at the play area. Click on the folder/drawer for property records (`C15`).
* **Narration:**
  "Now we travel to the Police Records. Because we discovered Mallory's address (`C4`) in the apartment, the property records cabinet for `C15` is now active and visible on the screen. If we hadn't found C4 first, this hotspot would be completely hidden from the player. This shows our dependency gating pattern. By decoupling the room assets from the global state, we can easily change quest pre-requisites in a single configuration method without refactoring scene layout nodes."

#### Step 5: Interrogation (Police Records)
* **Action:** Click "Interrogate Mallory". Ask one or two questions (e.g., 'Why did you call Felicia that night?'), then click 'Leave Interrogation'.
* **Narration:**
  "While at the station, we can interrogate our suspects. Clicking 'Interrogate Mallory' hides our custom Godot UI and launches a branching dialogue tree powered by **Dialogic 2**. This interrogation loop highlights our component-based approach: we swap out our GUI controller for the dialogue engine dynamically using signal events, and returning from the timeline restores our navigation menu."

#### Step 6: Reviewing the Clue Log & Revisit Panel
* **Action:** Open the bottom menu, click "Clue Log". Scroll down. Then click "Revisit".
* **Narration:**
  "Before we make our final decision, we can check our Clue Log. Our UI dynamically generates cards showing the details of every clue we've collected, demonstrating the clean separation of concerns between data storage and display. The Revisit panel calculates remaining clues on-the-fly, serving as a functional validation metric for the player's progress."

#### Step 7: The Concluding Accusation (Chief's Office)
* **Action:** Go to the Map, select Chief's Office/Decision. Click "Accuse Mallory Perez". Wait for the epilogue box, click OK, and view the Star Award screen.
* **Narration:**
  "Finally, we enter the Chief's Office to make our final accusation. Because we have collected all 4 key clues and correctly identified Mallory Perez as the culprit, we achieve the **True Ending**. This validates our ending state validation algorithm, ensuring a deterministic game outcome. The epilogue dialog explains that the police raided 14 Crestview Lane and found Felicia safe, and the game rewards us with a Yellow Star Detective rating on the final evaluation screen. This concludes our live demonstration of a decoupled, clean-architecture game."
