extends Node

# ===========================================================================
# Main.gd
# ---------------------------------------------------------------------------
# Persistent shell for Project Darklight.
# Owns the BottomBar (always visible) and a GameView slot where location
# scenes (Apartment, Film Set, …) are loaded and unloaded dynamically.
#
# Flow:
#   TitleScreen  →  map_screen.tscn  (GameState.pending_scene_path is set)
#                                  →  Main.tscn  (_ready loads the scene)
#
# The Map panel in the BottomBar also calls travel_to() directly so the
# player can switch locations mid-investigation without leaving Main.
# ===========================================================================

# ── Bottom-bar buttons ──────────────────────────────────────────────────────
@onready var btn_investigate : Button = $BottomBar/HBoxContainer/BtnInvestigate
@onready var btn_talk        : Button = $BottomBar/HBoxContainer/BtnTalk
@onready var btn_map         : Button = $BottomBar/HBoxContainer/BtnMap
@onready var btn_clue_log    : Button = $BottomBar/HBoxContainer/BtnClueLog
@onready var btn_revisit     : Button = $BottomBar/HBoxContainer/BtnRevisit

# ── Overlay panels ──────────────────────────────────────────────────────────
@onready var panel_investigate : Control = $Overlays/InvestigatePanel
@onready var panel_talk        : Control = $Overlays/TalkPanel
@onready var panel_map         : Control = $Overlays/MapPanel
@onready var panel_clue_log    : Control = $Overlays/ClueLogPanel
@onready var panel_revisit     : Control = $Overlays/RevisitPanel

# ── Clue / Revisit list helpers ─────────────────────────────────────────────
@onready var clue_list    : VBoxContainer = $Overlays/ClueLogPanel/VBox/ScrollContainer/ClueList
@onready var revisit_list : VBoxContainer = $Overlays/RevisitPanel/VBox/ScrollContainer/RevisitList

# ── GameView — swappable content slot ───────────────────────────────────────
# Full-rect Control that holds the current location scene.
@onready var game_view : Control = $GameView

# ── State ───────────────────────────────────────────────────────────────────
var _active_panel  : Control = null
var _current_scene : Node    = null  # currently loaded location scene

# ---------------------------------------------------------------------------
func _ready() -> void:
	# Connect GameState signals so panels stay up to date.
	GameState.clue_added.connect(_on_clue_added)
	GameState.scene_visited.connect(_on_scene_visited)

	# Wire bottom-bar buttons.
	btn_investigate.pressed.connect(func(): _toggle_panel(panel_investigate))
	btn_talk.pressed.connect(func():        _toggle_panel(panel_talk))
	btn_map.pressed.connect(func():         _toggle_panel(panel_map))
	btn_clue_log.pressed.connect(func():    _toggle_panel(panel_clue_log))
	btn_revisit.pressed.connect(func():     _toggle_panel(panel_revisit))

	# Hide all panels at startup.
	_hide_all_panels()

	# Seed lists with pre-existing data (e.g., after a scene reload).
	_refresh_clue_log()
	_refresh_revisit_list()

	# ── Handle incoming scene from the Map screen ────────────────────────────
	# map_screen.gd writes GameState.pending_scene_path before changing to
	# Main.tscn.  We pick it up here and clear it immediately.
	if GameState.pending_scene_path != "":
		var path := GameState.pending_scene_path
		GameState.pending_scene_path = ""  # consume
		travel_to(path)

# ===========================================================================
# Public API — used by map panel and map_screen.gd
# ===========================================================================

## travel_to
## Unloads the current location scene and loads a new one into GameView.
## Also marks the scene as visited in GameState.
func travel_to(scene_path: String) -> void:
	# Unload previous scene if one exists.
	if _current_scene != null:
		_current_scene.queue_free()
		_current_scene = null

	# Load and instantiate the new scene.
	var packed : PackedScene = load(scene_path)
	if packed == null:
		push_error("[Main] Failed to load scene: " + scene_path)
		return

	_current_scene = packed.instantiate()

	# Add to the tree FIRST — the parent rect must be known before
	# set_anchors_and_offsets_preset() can calculate correct layout.
	game_view.add_child(_current_scene)

	# Now that the node is in the tree, apply full-rect anchors.
	if _current_scene is Control:
		(_current_scene as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Derive a scene_id from the file name (e.g. "Apartment").
	var scene_id := scene_path.get_file().get_basename().to_lower()
	GameState.visit_scene(scene_id)

	# Close any open overlay so the player can see the new scene.
	_hide_all_panels()
	_active_panel = null
	_update_button_states(null)

	print("[Main] Travelled to: ", scene_path)

# ===========================================================================
# Panel toggling
# ===========================================================================
func _toggle_panel(panel: Control) -> void:
	if _active_panel == panel:
		_hide_panel(panel)
		_active_panel = null
		_update_button_states(null)
	else:
		_hide_all_panels()
		_show_panel(panel)
		_active_panel = panel
		_update_button_states(panel)

func _show_panel(panel: Control) -> void:
	panel.visible = true
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.18)

func _hide_panel(panel: Control) -> void:
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.14)
	tween.tween_callback(func(): panel.visible = false)

func _hide_all_panels() -> void:
	for p in [panel_investigate, panel_talk, panel_map, panel_clue_log, panel_revisit]:
		p.visible = false
		p.modulate.a = 1.0

func _update_button_states(active: Control) -> void:
	var pairs := {
		btn_investigate: panel_investigate,
		btn_talk:        panel_talk,
		btn_map:         panel_map,
		btn_clue_log:    panel_clue_log,
		btn_revisit:     panel_revisit,
	}
	for btn in pairs:
		btn.button_pressed = (pairs[btn] == active)

# ===========================================================================
# Clue Log
# ===========================================================================
func _refresh_clue_log() -> void:
	if clue_list == null:
		return
	for child in clue_list.get_children():
		child.queue_free()
	if GameState.clues.is_empty():
		var lbl := Label.new()
		lbl.text = "No clues collected yet."
		lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		clue_list.add_child(lbl)
	else:
		for clue in GameState.clues:
			clue_list.add_child(_make_clue_card(clue))

func _make_clue_card(clue: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	# ── Thumbnail image ────────────────────────────────────────────────────
	# Each clue stores its sprite path in "image_path". Load it and display
	# it as a small preview at the top of the card, styled like a polaroid.
	var img_path : String = clue.get("image_path", "")
	if img_path != "":
		var tex = ResourceLoader.load(img_path, "Texture2D")
		if tex:
			# Outer container gives a subtle dark background behind the image.
			var img_bg := PanelContainer.new()
			img_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			img_bg.custom_minimum_size   = Vector2(0, 90)
			vbox.add_child(img_bg)

			var img_rect := TextureRect.new()
			img_rect.texture     = tex
			img_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			img_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			img_rect.size_flags_vertical   = Control.SIZE_EXPAND_FILL
			img_bg.add_child(img_rect)

	# ── Clue title ─────────────────────────────────────────────────────────
	var title_lbl := Label.new()
	title_lbl.text = clue.get("title", "Unknown")
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	# ── Location sub-label ─────────────────────────────────────────────────
	var scene_lbl := Label.new()
	scene_lbl.text = clue.get("scene", "Unknown location")
	scene_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	scene_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(scene_lbl)

	# ── Description ────────────────────────────────────────────────────────
	var desc_lbl := Label.new()
	desc_lbl.text = clue.get("description", "")
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)

	return card

func _on_clue_added(_clue: Dictionary) -> void:
	_refresh_clue_log()

# ===========================================================================
# Revisit list
# ===========================================================================
func _refresh_revisit_list() -> void:
	if revisit_list == null:
		return
	for child in revisit_list.get_children():
		child.queue_free()
	if GameState.visited_scenes.is_empty():
		var lbl := Label.new()
		lbl.text = "No scenes visited yet."
		lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		revisit_list.add_child(lbl)
	else:
		for scene_id in GameState.visited_scenes:
			var btn := Button.new()
			btn.text = scene_id.replace("_", " ").capitalize()
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			# Map scene_id back to the full path.
			var path := "res://scenes/locations/%s.tscn" % scene_id.capitalize()
			btn.pressed.connect(func(): travel_to(path))
			revisit_list.add_child(btn)

func _on_scene_visited(_scene_id: String) -> void:
	_refresh_revisit_list()
