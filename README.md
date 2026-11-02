# Project Darklight 🔍🕵️‍♂️

> **An Interactive Point-and-Click Noir Detective Game**  
> Built with **Godot Engine 4.6 (GL Compatibility)** & **GDScript**  
> Developed as part of the Software Engineering & Project Management curriculum at **Goa College of Engineering** (Jan 2026 – Jul 2026).

---

## Overview

*Project Darklight* is a narrative-driven point-and-click noir detective game set in a gritty urban underworld. Players take on the role of an investigator piecing together clues across multiple crime scenes, interrogating suspects, and unravelling an intricate conspiracy.

Traditional narrative adventure games often struggle with **clunky room navigation**, **state fragmentation across scene transitions**, and **visual UI flickering**. *Project Darklight* solves these structural problems through an **Iterative and Incremental Development** process model featuring a decoupled **Persistent Shell Architecture** and an event-driven **Autoload State Singleton**.

---

## Architectural Highlights

### 1. Persistent Root Shell Architecture (`Main.tscn`)
- Rather than destroying and reloading the entire scene tree on each room change, the root shell (`Main.tscn`) remains loaded in memory throughout gameplay.
- A dynamic `GameView` slot dynamically unloads the previous room and instantiates new locations (Apartment, Film Set, Police Records, Chief's Office) on demand via `travel_to()`.
- Navigation transitions are instantaneous with **zero screen flicker**, preserving the static HUD overlay (`BottomBar`) and clue panels.

### 2. Global Game State Singleton (`GameState.gd`)
- Registered as an engine-level **Autoload Singleton** residing at `/root/GameState`, acting as the **Single Source of Truth (SSOT)** for all collected evidence, visited rooms, and suspect alibi flags.
- Clue inventory is modeled as a type-safe `Array[Dictionary]` with internal guard clauses (`add_clue()`, `has_clue()`) preventing duplicate evidence registration.
- Decoupled event emission via engine **signals** (`clue_added`, `location_unlocked`, `scene_visited`) automatically triggers reactive updates across UI panels.

### 3. Logical Clue Gating & Item Combination
- **State-Driven Gating**: Certain physical clues remain hidden until prerequisite evidence is gathered (e.g. Police Property Record `C15` unlocks only after uncovering Address `C4`).
- **Composite Clue Assembly**: Multi-part physical evidence (such as torn note fragments `C11` and `C12b`) automatically combine in the player's inventory when collected.

### 4. Branching Suspect Interrogations & Multi-Ending Resolution
- Non-linear questioning timelines built with the **Dialogic 2** framework allow players to interrogate suspects (Felix and Mallory) in any order.
- Dynamically hides and restores UI controls using timeline signal hooks.
- Evaluates the weighted validity of collected clues to trigger three distinct narrative conclusions:
  - **True Ending**: Full conspiracy uncovered with corroborated evidence.
  - **Bad Ending**: Accusing the wrong suspect without sufficient proof.
  - **Incomplete Ending**: Rushing to judgment with vital evidence missing.

### 5. 3-Bus Audio Architecture (`AudioManager.gd`)
- Features a 3-bus audio mixer separating **Music**, **Ambience**, and **SFX**.
- Transient sound effects (UI clicks, clue pickup cues) use dynamic node pooling: spawning lightweight `AudioStreamPlayer` instances connected via `finished.connect(queue_free)` to prevent audio heap fragmentation and memory leaks.

---

## Tech Stack & Engine Tools

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Game Engine** | **Godot Engine 4.6** | GL Compatibility rendering mode; 2D GUI Control node hierarchy. |
| **Scripting** | **GDScript** | Object-oriented, signal-driven gameplay logic and state management. |
| **Dialogue Engine** | **Dialogic 2** | Custom `.dtl` timelines and `.dch` character sheets for branching interrogations. |
| **UI System** | **Godot Control Nodes** | Responsive layouts using `set_anchors_and_offsets_preset` for multiple aspect ratios. |
| **Audio Pipeline** | **Godot Audio Bus Mixer** | Dedicated Music, Ambience, and SFX channels with automated disposal. |
| **Version Control** | **Git / GitHub** | Team SDLC, milestone tracking, and feature branch integration. |

---

## Engineering Team & Roles

Developed across a 6-month SDLC by a team of 4 engineers:
- **Kanak Waradkar** ([@Labreo](https://github.com/Labreo)) — *Lead Logic & State Architect* (Game State Singleton, Clue Gating, Scene Shell Architecture, Audio Manager, Demo Script)
- **Malcolm** — *Presentation & Visual Art* (Character Sprites, Location Backgrounds, Theme Consistency)
- **Girish** — *Dialogue & Audio Engineering* (Dialogic 2 Timelines, SFX & BGM Production)
- **Harsh Raikar** — *UI Layout & Documentation* (Control Node Anchoring, SRS Documentation, Slide Decks)

---

## Repository Structure

```
project-darklight/
├── project.godot            # Godot 4.6 project configuration & Autoload mappings
├── scenes/
│   ├── Main.tscn            # Persistent root shell (BottomBar + GameView slot)
│   ├── Decision.tscn        # Accusation & finale decision sequence
│   ├── locations/           # Location scenes (Apartment, FilmSet, PoliceRecord, ChiefOffice)
│   └── ui/                  # Map panel, clue overlay, suspect cards
├── scripts/
│   ├── GameState.gd         # Global Autoload Singleton (SSOT for clues & progression)
│   ├── AudioManager.gd      # 3-bus audio mixer & dynamic player pool
│   ├── main.gd              # Shell scene loading & viewport management
│   ├── ClueCard.gd          # Dynamic Polaroid clue card rendering
│   └── ...                  # Room scripts & hotspot interaction triggers
├── dialogues/               # Dialogic 2 character sheets (.dch) & branching timelines (.dtl)
├── audio/                   # BGM streams, ambient loops, and UI navigation SFX
├── art/                     # Backgrounds, sprites, and clue card illustrations
└── presentation_docs/       # SRS, speech notes, architecture breakdown, and Q&A prep
```

---

## Running the Project

1. Install **Godot Engine 4.x** (Standard version with GL Compatibility support).
2. Clone this repository:
   ```bash
   git clone https://github.com/Labreo/project-darklight.git
   ```
3. Open Godot, click **Import**, select `project-darklight/project.godot`, and click **Import & Edit**.
4. Press `F5` (or click **Play**) to launch from `scenes/Main.tscn`.
