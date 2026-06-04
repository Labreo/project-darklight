# Project Darklight: 10-Minute Presentation PowerPoint Outline
This document provides a slide-by-slide structure, visual ideas, core bullet points, and speaker allocations for a 10-minute presentation.

---

### Slide 1: Title & Project Introduction
* **Speaker:** Malcolm (Mallu)
* **Estimated Time:** 1:00 min
* **Visuals:** Sleek dark background with the game title in glowing yellow/white text. Screenshots of the game's title screen and main gameplay interface.
* **Slide Contents (Bullet Points):**
  * **Project Darklight:** An Interactive Mystery Detective Game.
  * **Engine:** Built using Godot Engine 4.6 (GL Compatibility).
  * **The Development Team & Roles:**
    * **Malcolm (Mallu):** Presentation Lead, UI Artist, and Background Illustrator.
    * **Kanak Waradkar:** Lead Logic Developer, Game State Architect, and Live Demo Lead.
    * **Girish:** Dialogue Designer and Sound Engineer.
    * **Harsh Raikar:** UI Layout Developer and Documentation Lead.
* **Speaker Script Summary:** 
  "Welcome, everyone. Today we are presenting Project Darklight, a point-and-click noir detective game. We developed this in Godot 4, utilizing a customized GUI layout, branching dialogs, and a global game state manager. I acted as the lead artist and coordinator, Kanak programmed our core logic and clue database, Girish handled the branching dialogs and audio, and Harsh built our UI layout and managed the technical documentation. We will walk you through our concept, the process model we followed, and the architecture that makes this game tick."

---

### Slide 2: Game Concept & Suspect Dynamics
* **Speaker:** Malcolm (Mallu)
* **Estimated Time:** 1:00 min
* **Visuals:** Portraits of Felix Gonzalez, Mallory Perez, and the Chief. A flowchart mapping out the three endings (True, Bad, Incomplete).
* **Slide Contents (Bullet Points):**
  * **The Incident:** Disappearance of film actress Felicia Gonzalez.
  * **The Suspects:**
    * *Felix Gonzalez (Husband):* Financially stressed, argues about money, holds a strong alibi.
    * *Mallory Perez (Sister):* Estranged, jealous of Felicia's fame, suspicious behavior.
  * **The Investigation Loop:** Search scenes -> Gather clues -> Interrogate suspects -> Accuse the culprit.
  * **Branching Ending Paths:**
    * *True Ending (Accuse Mallory + 4 Key Clues):* Felicia is found safe; Mallory is detained.
    * *Bad Ending (Accuse Felix):* Felix's alibi breaks the case; culprit flees.
    * *Incomplete Ending (Accuse Mallory, missing clues):* Police arrive too late; case remains cold.
* **Speaker Script Summary:**
  "The player's goal is to find out what happened to Felicia. By navigating through different crime scenes, the player gathers evidence to build a case against one of two suspects: her husband Felix or her sister Mallory. The game rewards thorough investigation; accusing Mallory without finding all key clues leads to an incomplete investigation, while accusing Felix falls apart due to his alibi. Only a perfect investigation reveals the True Ending."

---

### Slide 3: Software Development Process Model
* **Speaker:** Malcolm (Mallu)
* **Estimated Time:** 1:00 min
* **Visuals:** An SDLC diagram illustrating the Iterative and Incremental Development cycle (Planning -> Design -> Build -> Test -> Review).
* **Slide Contents (Bullet Points):**
  * **Process Model:** Iterative & Incremental Development.
  * **Why it fits Game Development:** Continual integration of art, code, dialogues, and sound requires active feedback loops.
  * **Development Phases:**
    * *Phase 1 (Core Shell):* Main navigation, scene loader (`travel_to()`), global singleton (`GameState.gd`).
    * *Phase 2 (Narrative & Dialogue):* Dialogic 2 integration, interrogation timelines, branching choices.
    * *Phase 3 (Audio & Polish):* Custom `AudioManager`, clue gating, sound effects, ending screens, and bug fixing.
* **Speaker Script Summary:**
  "We followed an Iterative and Incremental process. Instead of waiting until the end to see if the systems worked together, we developed in three iterations. First, we built the navigation shell and state registry. Second, we integrated Dialogic and wrote the interrogation scripts. Third, we added the audio assets and clue gating logic. This allowed us to debug early and continuously test our gameplay flow."

---

### Slide 4: Tech Stack & Godot Engine Architecture
* **Speaker:** Malcolm (Mallu)
* **Estimated Time:** 1:00 min
* **Visuals:** Node Tree Diagram of `Main.tscn` showing `GameView` slot and `BottomBar`. A code snippet demonstrating the dynamic loading of location scenes.
* **Slide Contents (Bullet Points):**
  * **Engine choice:** Godot Engine 4.6 (GL Compatibility rendering).
  * **UI-Driven Control Node Architecture:** The entire game utilizes Control-based nodes (GUI) rather than 2D physics or coordinates, ensuring instant rendering.
  * **Persistent Shell Pattern (`Main.tscn`):**
    * Holds the persistent navigation `BottomBar` and HUD overlays.
    * Uses a dynamic scene-slot control: `GameView`.
    * Unloads and instantiates rooms programmatically.
  * **Layout anchoring:** Uses `set_anchors_and_offsets_preset` to guarantee responsive design across different screens.
* **Speaker Script Summary:**
  "Technically, Project Darklight is built on a persistent shell architecture in Godot. Rather than reloading the entire application window when traveling, `Main.tscn` stays loaded in memory. When you select a new location on the map, the game unloads the current child of the `GameView` container, loads the new scene, instantiates it, and stretches it to fill the viewport. This makes navigation instant and prevents UI flickering."

---

### Slide 5: Game State, Clue Inventory & Key Clue Gating
* **Speaker:** Kanak Waradkar
* **Estimated Time:** 1:30 mins
* **Visuals:** Code snippet from `GameState.gd` showing `clues` array, `add_clue()`, and ending condition algorithms.
* **Slide Contents (Bullet Points):**
  * **Global State Singleton (`GameState.gd`):** Auto-loaded global script acting as the Single Source of Truth.
  * **Clue Dictionary Structure:**
    * Fields: `id`, `title`, `description`, `scene`, `image_path`, `timestamp`.
  * **Event-Driven UI (Signals):**
    * `clue_added` and `scene_visited` signals update overlay panels automatically without direct scripts dependencies.
  * **Logical Clue Gating:**
    * Clue `C15` (Property Records) is physically hidden in Police Station unless Clue `C4` (Mallory's Address) is in the inventory.
  * **Assembling Clues:** `film_set.gd` monitors `C11` and `C12b` to automatically combine them into `C_TORN_NOTE`.
* **Speaker Script Summary:**
  "I will explain how the game state is managed under the hood. We created a global singleton class, `GameState.gd`. Since it is an autoload, it survives when we swap rooms in `GameView`. It stores the player's clue inventory. To make the game feel like a real detective case, we implemented logical clue gating. For example, in the Police Station, you cannot inspect the property records for clue `C15` unless you have already found the torn envelope `C4` in the Apartment. Furthermore, when you find both pieces of the torn note (`C11` and `C12b`), the Film Set controller automatically triggers a combiner script that outputs the assembled note. This decoupled architecture uses signals to tell the UI panels to update in real-time."

---

### Slide 6: Interrogation Mode: Dialogic 2 & Dialogue Trees
* **Speaker:** Girish
* **Estimated Time:** 1:30 mins
* **Visuals:** Dialogic editor node-graph screenshot, text snippet from `interrogation_felix.dtl` showing dialogue loops (`label Questions` and `jump Questions`).
* **Slide Contents (Bullet Points):**
  * **Dialogue System:** Powered by the open-source **Dialogic 2** Godot plugin.
  * **Timeline Files (`.dtl`):** Native dialogue scripts (`interrogation_felix.dtl`, `interrogation_mallory.dtl`).
  * **Character Sheets (`.dch`):** Configured characters for Detective, Felix, and Mallory.
  * **Branching Node Dialogues:**
    * Interactive questionnaire using selection loops.
    * Custom labels and jumps to return players to the interrogation list.
  * **Dynamic UI Gating:** Interrogation menu panel hides when Dialogic starts and automatically restores via the `timeline_ended` signal.
* **Speaker Script Summary:**
  "To handle the suspect interrogations, we integrated the Dialogic 2 plugin. The dialogue is structured using timeline files. When you click 'Interrogate', the game stops normal interaction and hands control over to Dialogic. I designed the dialogues to be non-linear: players can ask questions in any order. The system uses labels and jump statements to return the player to the main questioning menu after each suspect response. When the timeline ends, a signal is emitted that shows our custom UI button container again."

---

### Slide 7: UI Controls, Layout & Navigation
* **Speaker:** Harsh Raikar
* **Estimated Time:** 1:00 min
* **Visuals:** Screenshot highlighting the `BottomBar` buttons, the custom `ClueLogPanel` showing collected cards, and the `RevisitPanel`.
* **Slide Contents (Bullet Points):**
  * **UI Buttons & Modes:** Investigate, Talk, Map, Clue Log, Revisit.
  * **Overlay Panels:** Control nodes layered on top of the `GameView` that toggle visibility.
  * **Clue Log Panel:** Instantiates `PanelContainer` cards for each clue, displaying thumbnails dynamically.
  * **Revisit Panel:**
    * Calculates completion counts using `LOCATION_TOTALS`.
    * Dynamically generates buttons only for rooms with missing clues, assisting player direction.
* **Speaker Script Summary:**
  "I was responsible for laying out the UI controls and menus. The player controls the game through the bottom navigation bar. We have separate overlay panels for the Clue Log, Suspect List, and the Revisit board. In the Clue Log, the game loops through the `GameState` array and instantiates a visual Polaroid card for each entry. The Revisit panel is particularly helpful: it checks how many clues are left in each room using `get_clues_remaining(scene_id)`. It only shows buttons for rooms that are incomplete, helping the player know where to double-back."

---

### Slide 8: Sound Design & Audio Architecture
* **Speaker:** Malcolm (Mallu)
* **Estimated Time:** 1:00 min
* **Visuals:** Diagram of the three-channel Audio Bus Mixer (Music, Ambience, SFX) in Godot. Code snippet of `AudioManager.gd` showing the dynamic instancing of SFX players.
* **Slide Contents (Bullet Points):**
  * **Audio Mixer Bus Routing:** Separate buses for fine-tuned volume control (Music, Ambience, SFX).
  * **Preloading Assets:** Avoids runtime disk delays, eliminating visual lag during sound playback.
  * **Dynamic SFX Instancing:**
    * Spawns an independent `AudioStreamPlayer` for each sound effect.
    * Hooks the `finished` signal to `queue_free()`.
    * Allows multiple overlapping sounds (e.g., fast button clicks, clues).
* **Speaker Script Summary:**
  "I will now talk about the sound design. In a mystery game, audio sets the mood. We built `AudioManager.gd` as an autoload script. It directs audio streams to three separate buses: Music, Ambience, and SFX. One key technical decision we made was dynamic SFX instancing. Instead of having a single player that cuts off when a new sound plays, our code creates a temporary player for every single click. When the sound effect finishes playing, the node automatically deletes itself from memory using `queue_free`. This keeps memory usage low while allowing sounds to overlap naturally."

---

### Slide 9: Live Demo Walkthrough
* **Speaker:** Kanak Waradkar (conducting the demo) / Malcolm (narrating highlights)
* **Estimated Time:** 2:00 mins
* **Visuals:** Live gameplay screen captured on Girish's laptop or projected directly.
* **Demo Sequence:**
  1. **Start Screen:** Show title menu, press play (explain transition to Map).
  2. **Apartment Scene:** Click on hotspots (show Clue Card popup, show key clue `C4`).
  3. **Map Navigation:** Travel to Film Set, find note pieces. Show the assembled note popup.
  4. **Police Records:** Show Felix/Mallory Interrogation. Show Clue Log with Polaroid thumbnails.
  5. **Confrontation:** Go to Chief's Office, choose an accusation, show the Star Award screen.
* **Speaker Script Summary:**
  "Now, we will show you a live run of the game. Kanak is operating the game. We start in the main menu and enter the game. We are brought to the map, and we travel to the Apartment first. Notice how when Kanak hovers over the desk drawer, it has a pointing hand cursor. Clicking it yields Clue C4—Mallory's Address. Let's travel to the Film Set now. Here we find two torn pieces of a note. Once both are found, watch how they automatically combine to form the assembled letter. Now we travel to the Police records. Notice that because we have C4, the property records drawer is now visible. We interrogate Mallory using our Dialogic tree. In the Clue Log, we can see all the evidence. Finally, we travel to the Chief's Office. We accuse Mallory with all clues in hand, yielding the True Ending and a Star Detective rating."

---

### Slide 10: Conclusion & Q&A
* **Speaker:** All
* **Estimated Time:** 0:30 min
* **Visuals:** 'Thank You!' slide with team emails, GitHub repository link, and Q&A prompt.
* **Slide Contents (Bullet Points):**
  * **Project Repository:** `github.com/Labreo/project-darklight`
  * **Lessons Learned:** Decoupling logic from visuals, managing branching state, optimizing audio garbage collection.
  * **Future Scope:** Adding more investigation locations, complex minigames (lockpicking, forensics), and fuller animations.
  * **Questions?** Open floor for the reviewers.
* **Speaker Script Summary:**
  "In conclusion, building Project Darklight taught us a lot about decoupling UI design from game logic, managing persistent state, and organizing assets in Godot. In the future, we hope to expand the game with more interactive minigames and custom animations. Thank you for your time, and we'd love to take any questions."
