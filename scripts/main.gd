extends Node

# ---------------------------------------------------------------------------
# Main.gd
# Drives the bottom navigation bar in Main.tscn.
# Each button toggles its corresponding overlay panel.
# If the same button is pressed while its panel is open, the panel closes.
# ---------------------------------------------------------------------------

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

# ── Clue Log UI helpers ─────────────────────────────────────────────────────
@onready var clue_list         : VBoxContainer = $Overlays/ClueLogPanel/ScrollContainer/ClueList
@onready var revisit_list      : VBoxContainer = $Overlays/RevisitPanel/ScrollContainer/RevisitList

# ── State ───────────────────────────────────────────────────────────────────
var _active_panel : Control = null
var _game_state   : Node = null

# ---------------------------------------------------------------------------
func _ready() -> void:
	# GameState is registered as an autoload — always available at /root/GameState
	_game_state = get_node("/root/GameState")

	# Connect GameState signals so panels stay up to date
	_game_state.clue_added.connect(_on_clue_added)
	_game_state.scene_visited.connect(_on_scene_visited)

	# Wire buttons
	btn_investigate.pressed.connect(func(): _toggle_panel(panel_investigate))
	btn_talk.pressed.connect(func():        _toggle_panel(panel_talk))
	btn_map.pressed.connect(func():         _toggle_panel(panel_map))
	btn_clue_log.pressed.connect(func():    _toggle_panel(panel_clue_log))
	btn_revisit.pressed.connect(func():     _toggle_panel(panel_revisit))

	# Hide all panels at start
	_hide_all_panels()

	# Seed the Clue Log & Revisit list with any data that already exists
	_refresh_clue_log()
	_refresh_revisit_list()

# ---------------------------------------------------------------------------
# Panel toggling
# ---------------------------------------------------------------------------
func _toggle_panel(panel: Control) -> void:
	if _active_panel == panel:
		# Same button pressed again → close
		_hide_panel(panel)
		_active_panel = null
		_update_button_states(null)
	else:
		# Switch to new panel
		_hide_all_panels()
		_show_panel(panel)
		_active_panel = panel
		_update_button_states(panel)

func _show_panel(panel: Control) -> void:
	panel.visible = true
	# Animate in
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

# ---------------------------------------------------------------------------
# Clue Log refresh
# ---------------------------------------------------------------------------
func _refresh_clue_log() -> void:
	if clue_list == null or _game_state == null:
		return
	# Clear old entries
	for child in clue_list.get_children():
		child.queue_free()
	# Rebuild
	if _game_state.clues.is_empty():
		var lbl := Label.new()
		lbl.text = "No clues collected yet."
		lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		clue_list.add_child(lbl)
	else:
		for clue in _game_state.clues:
			clue_list.add_child(_make_clue_card(clue))

func _make_clue_card(clue: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var vbox := VBoxContainer.new()
	card.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = clue.get("title", "Unknown")
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	var scene_lbl := Label.new()
	scene_lbl.text = clue.get("scene", "Unknown location")
	scene_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(scene_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = clue.get("description", "")
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)

	return card

func _on_clue_added(_clue: Dictionary) -> void:
	_refresh_clue_log()

# ---------------------------------------------------------------------------
# Revisit list refresh
# ---------------------------------------------------------------------------
func _refresh_revisit_list() -> void:
	if revisit_list == null or _game_state == null:
		return
	for child in revisit_list.get_children():
		child.queue_free()
	if _game_state.visited_scenes.is_empty():
		var lbl := Label.new()
		lbl.text = "No scenes visited yet."
		lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		revisit_list.add_child(lbl)
	else:
		for scene_id in _game_state.visited_scenes:
			var btn := Button.new()
			btn.text = scene_id.replace("_", " ").capitalize()
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.pressed.connect(func(): _travel_to_scene(scene_id))
			revisit_list.add_child(btn)

func _on_scene_visited(_scene_id: String) -> void:
	_refresh_revisit_list()

func _travel_to_scene(scene_id: String) -> void:
	print("[Main] Revisiting scene: ", scene_id)
	# Implement actual scene loading here, e.g.:
	# get_tree().change_scene_to_file("res://scenes/locations/" + scene_id + ".tscn")
