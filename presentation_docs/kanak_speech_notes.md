# Project Darklight: Kanak's Presentation Speech Notes & Demo Script (EXPANDED)
**Focus Areas:** Game State Architecture, Clue Logic, Software Engineering Principles, Project Management Execution, and Conducting the Live Demo.
**Estimated speaking time for these sections:** ~4 minutes of the 10-minute presentation.

---

## 1. Technical Deep Dive: Game State & Clue Logic (Slide 5)
*Speaker: Kanak*  
*Slide Visuals: Code snippets of `GameState.gd` (clue structure, gating functions, and ending logic).*

### Key Talking Points:

* **The Autoload Singleton as a Single Source of Truth (SSOT):**
  "In Godot, changing scenes normally destroys active nodes and clears their memory. To maintain global state consistency across room transitions, we established `GameState.gd` as an **Autoload singleton**. From a Software Engineering perspective, this acts as our **Single Source of Truth (SSOT)**. It initializes once at launch, sits at the root of the engine's viewport tree, and encapsulates all persistent player data, protecting it from room lifecycle changes in the `GameView` container."

* **Data Modeling & Encapsulation of the Clue Inventory:**
  "Our clue inventory is modeled as an `Array[Dictionary]`. We adhered to the principle of **Encapsulation**—raw data manipulation is restricted to specific API methods within our singleton. Each clue dictionary defines a strict schema:
  * `id` (e.g., `"C4"`, `"C15"`): Unique key.
  * `title` & `description`: Presentation-layer display strings.
  * `scene`: The origin room ID (supporting queries and completion statistics).
  * `image_path`: Path to a sprite for dynamic UI rendering.
  * `timestamp`: Captured using `Time.get_ticks_msec() / 1000.0` to guarantee chronologically sortable event streams."

* **Loose Coupling & Event-Driven Architecture (Observer Pattern):**
  "To maintain high maintainability, we strictly avoided tight coupling between scene logic and UI overlays. We implemented an **Event-Driven Architecture** utilizing Godot's custom signals:
  `signal clue_added(clue: Dictionary)`  
  `signal scene_visited(scene_id: String)`  
  When a player clicks a hotspot, the room script has zero knowledge of the UI; it simply calls `GameState.add_clue()`. The singleton updates its internal data structure and broadcasts the `clue_added` signal. UI components like the `ClueLogPanel` act as observers, listening for this event and updating themselves reactively. This separation of concerns made it possible for our UI lead, Harsh, and myself to develop features in parallel without merge conflicts."

* **Conditional Gating & Combinatorial Logic:**
  "To handle complex detective logic, we implemented two software patterns:
  * **Prerequisite Gating:** In `police_record.gd`, the property cabinet hotspot (Clue `C15`) is physically hidden unless the prerequisite `C4` (Mallory's Address) is registered. This dependency check is evaluated cleanly via `GameState.has_clue("C4")`.
  * **Asymmetric Clue Combination:** In `film_set.gd`, the room controller monitors the inventory stream. When both pieces of the torn note (`C11` and `C12b`) exist, it triggers a combiner function that deletes the fragments and instantiates a unified `C_TORN_NOTE`. This keeps our game rules deterministic."

* **Deterministic Ending Validation:**
  "When the player makes an accusation in the Chief's Office, the decision script calls `GameState.get_ending(accused_name)`. It evaluates the inventory against a hard contract:
  `var required = ["C4", "C11", "C14", "C15"]`
  If all four are present and Mallory is accused, it returns `Ending.TRUE`. If Felix is accused, it returns `Ending.BAD` (Felix's alibi breaks the case). If Mallory is accused but keys are missing, it returns `Ending.INCOMPLETE`. This deterministic validation ensures no soft-locks and cleanly maps state to game outcome."

* **Project Management Impact:**
  "Applying these engineering patterns early in **Phase 1 (Core Shell)** dramatically reduced our integration risks. By defining strict API contracts for our state singleton, our dialogue designer, Girish, could write interrogation timelines in **Phase 2** knowing that the underlying inventory flags would consistently gate narrative choices."

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
