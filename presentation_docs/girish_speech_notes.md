# Project Darklight: Girish's Presentation Speech Notes (EXPANDED)
**Focus Areas:** Interrogation Mode, Dialogic 2 Plugin Integration, Character Databases, and Dialogue Tree Jumps.
**Estimated speaking time for these sections:** ~2 minutes of the 10-minute presentation.

---

## 1. Dialogue System: Why Dialogic 2?
*Speaker: Girish*
*Slide Visuals: Dialogic logo, Dialogic timeline node-graph, screenshot of Felix and Mallory interrogation.*

### Key Talking Points:
* **The Choice of Dialogic 2:**
  "To handle the suspect interrogations, we integrated the open-source **Dialogic 2** plug-in. Writing a custom branching dialogue engine from scratch can lead to rigid, hard-to-maintain code. Dialogic 2 provides a visual timeline editor directly inside Godot, allowing us to build, script, and test narrative branches with ease."
* **Timeline Scripts (`.dtl`):**
  "We created two interrogation timeline scripts: `interrogation_felix.dtl` and `interrogation_mallory.dtl`. These timelines support text output, choice prompts, character entry/exit animations, and signal callbacks."
* **Dialogic Configuration in `project.godot`:**
  "To register the assets correctly, we configured the project’s autoload directory. In `project.godot`, we set up directories for characters and timelines:
  * `Detective`: `res://dialogues/Detective.dch`
  * `Felix`: `res://dialogues/Felix.dch`
  * `Mallory`: `res://dialogues/Mallory.dch`
  * `interrogation_felix`: `res://dialogues/interrogation_felix.dtl`
  * `interrogation_mallory`: `res://dialogues/interrogation_mallory.dtl`
  * Default style: `res://dialogues/main_style.tres`
  This configuration allows the Dialogic engine to load the assets instantly at runtime using their resource names."

---

## 2. Character Configurations (`.dch` Files)
*Speaker: Girish*
*Slide Visuals: Screenshot of character resource sheets for Felix, Mallory, and the Detective.*

### Key Talking Points:
* **Character Data Sheets:**
  "We configured character resources using `.dch` files for our three characters: the **Detective**, **Felix**, and **Mallory**. These files act as database entries that bind:
  * The display name of the character.
  * Custom text colors (so the player can distinguish speakers at a glance).
  * Portrait sprite textures (such as `FelixSprite1.png` and `mallory.png`) that load dynamically when a character joins the screen."
* **Screen Positioning:**
  "We programmed character entries using Dialogic's positioning system:
  `join Felix right`
  `join Detective left`
  This aligns the speaker on the right and the player's character on the left, mimicking classic visual novel layouts."

---

## 3. Branching Dialogue Trees & Question Loops
*Speaker: Girish*
*Slide Visuals: Code snippet of the question loop structure from `interrogation_felix.dtl`.*

### Key Talking Points:
* **Non-Linear Questioning:**
  "We designed the suspect questioning to be non-linear. The player can ask questions in any order they choose, rather than following a strict line of questioning. To achieve this in Dialogic 2, we utilized **labels and jumps**:"
  ```text
  label Questions
  - Where were you last night?
      Detective: Where were you last night?
      Felix: At the Meridian party...
      jump Questions
  - [Leave Interrogation]
      [end_timeline]
  ```
* **Loop Logic:**
  "When the player clicks a question, the detective speaks, the suspect replies, and the timeline executes `jump Questions` to return the player to the list of choices. Selecting the exit option ends the timeline, closing the dialogue box."
* **Specific Suspect Responses & Clues Revealed:**
  "Each interrogation timeline reveals critical clues and alibis:
  * **Felix's Timeline:**
    * *Question:* 'Where were you last night?' -> Felix alibis himself at the Meridian Party from 10:45 PM to 2 AM, inviting us to check guest lists and bar tabs.
    * *Question:* 'You were arguing about money. How bad did it get?' -> Felix explains that Felicia wanted to quit acting and that he did not want her money.
  * **Mallory's Timeline:**
    * *Question:* 'Were you jealous of her success?' -> Mallory reveals: 'Jealous? No. Not of the fame. Just of how easily she was loved for something I was never even allowed to try.'
    * *Question:* 'Did you meet her after the call?' -> Mallory hints that Felicia didn't want to go back to her apartment where letters lay around unanswered."

---

## 4. UI Transition Gating
*Speaker: Girish*
*Slide Visuals: GDScript snippet showing `Dialogic.start()` and the `timeline_ended` signal connection in `police_record.gd`.*

### Key Talking Points:
* **Hiding the Interrogation Panel:**
  "When the player triggers an interrogation, we hide our custom UI buttons in `police_record.gd` to prevent the player from clicking other menus while talking:
  `interrogation_vbox.hide()`
  `Dialogic.start(timeline_name)`"
* **Restoring Control via Signals:**
  "To restore the menu buttons once the dialogue finishes, we connect to Dialogic's global event bus:
  `Dialogic.timeline_ended.connect(_on_timeline_ended)`
  When the player selects `[Leave Interrogation]`, Dialogic emits the `timeline_ended` signal, which calls our callback `_on_timeline_ended()` and calls `interrogation_vbox.show()`. This guarantees a smooth transition back to normal investigation mode."
