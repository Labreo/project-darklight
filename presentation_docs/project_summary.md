# Project Darklight: Executive Summary

> **Project Name:** Project Darklight  
> **Type:** Interactive Point-and-Click Noir Detective Game  
> **Engine:** Godot Engine 4.6 (GL Compatibility)  
> **Team:** Malcolm (Presentation & Art), Kanak Waradkar (Lead Logic & State Architect), Girish (Dialogue & Audio), Harsh Raikar (UI Layout & Docs)

---

## 1. Problem Statement
Traditional narrative detective games often suffer from **clunky room navigation**, **fragile state management**, and **rigid dialogue systems**. Specifically:
* **State Fragmentation:** Tracking collected clues and room progression across multiple scene changes frequently leads to bugs or out-of-sync UI.
* **UI & Performance Latency:** Reloading entire scene trees during room transitions causes visual flickering and loading delays.
* **Narrative Linearity:** Implementing meaningful clue gating (where evidence relies on previous discoveries) and branching endings (True, Bad, Incomplete) without breaking game flow requires a decoupled architecture.

---

## 2. Discussion & System Architecture
To solve these challenges, *Project Darklight* was built following an **Iterative and Incremental Development** process model:

* **Persistent Shell Architecture (`Main.tscn`):** The main window remains in memory while a dynamic container (`GameView`) unloads and instantiates room scenes on demand. Navigation is instantaneous with zero screen flicker.
* **Global Game State Singleton (`GameState.gd`):** Acts as the single source of truth for clue inventories, visited locations, and suspect status. Event-driven **signals** (`clue_added`, `scene_visited`) automatically update overlay UI panels.
* **Logical Clue Gating & Combination:** Certain clues are physically hidden until required evidence is found (e.g., Police Property Record `C15` unlocks only after uncovering Address `C4`). Physical items (such as torn note pieces `C11` & `C12b`) automatically combine when collected.
* **Branching Interrogations:** Non-linear questioning timelines allow players to interrogate suspects (Felix and Mallory) in any order, dynamically hiding/restoring UI controls via timeline signals.
* **Audio Architecture (`AudioManager.gd`):** Uses a 3-bus mixer (Music, Ambience, SFX) with dynamic transient node instancing (`queue_free()`) to allow overlapping sound effects without memory leaks.

---

## 3. Tools & Technologies
| Category | Technology / Tool | Purpose & Application |
| :--- | :--- | :--- |
| **Core Game Engine** | **Godot Engine 4.6** | GL Compatibility rendering mode; 2D GUI Control node architecture. |
| **Scripting Language** | **GDScript** | Signal-driven, object-oriented logic for game flow and state tracking. |
| **Dialogue Framework** | **Dialogic 2 Plugin** | Custom `.dtl` timelines and `.dch` character sheets for branching interrogations. |
| **UI & Layout** | **Godot Control Nodes** | Responsive layouts using `set_anchors_and_offsets_preset` for all aspect ratios. |
| **Audio Pipeline** | **Godot Audio Bus Mixer** | Dedicated Music, Ambience, and SFX channels managed via `AudioManager.gd`. |
| **Version Control** | **Git & GitHub** | Collaborative development, issue tracking, and documentation management. |

---

## 4. Conclusion
*Project Darklight* demonstrates that combining a **Persistent Shell Architecture** with **Event-Driven Global State Management** creates a seamless, highly responsive mystery detective game. By decoupling UI overlays, clue gating logic, and dialogue timelines, the team successfully delivered an engaging investigation experience with three distinct narrative endings. The modular architecture provides a clean, extensible foundation for future narrative expansions.
