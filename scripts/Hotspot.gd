extends Control

# ===========================================================================
# Hotspot.gd  (Control-based using native Godot GUI input)
# ---------------------------------------------------------------------------
# Attach to any transparent Control node that covers a clickable prop in the
# apartment scene.
# ===========================================================================

@export var clue_id          : String   = ""
@export var clue_title       : String   = ""
@export var clue_description : String   = ""
@export var scene_name       : String   = "The Apartment"
@export var is_key_clue      : bool     = false
@export var phone_mode       : bool     = false
## Filesystem path to the clue's sprite image. Stored in GameState.
@export var clue_image_path  : String   = ""
@export var clue_card_path   : NodePath = NodePath("../../UI/ClueCard")

signal hotspot_activated(clue_id: String)

var _clue_card : Node = null

# ---------------------------------------------------------------------------
func _ready() -> void:
	# Must be STOP so this Control receives _gui_input events natively!
	mouse_filter = Control.MOUSE_FILTER_STOP

	_clue_card = get_node_or_null(clue_card_path)
	if _clue_card == null:
		push_warning("[Hotspot:%s] ClueCard not found at '%s'." % [clue_id, clue_card_path])

	# Cursor signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	if is_key_clue:
		_start_pulse_animation()

# ---------------------------------------------------------------------------
# Cursor
# ---------------------------------------------------------------------------
func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

# ---------------------------------------------------------------------------
# Click handler — Godot handles hit-testing automatically under all scales
# ---------------------------------------------------------------------------
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_activate()
			accept_event()  # Stop propagation

# ---------------------------------------------------------------------------
# Activation
# ---------------------------------------------------------------------------
func _activate() -> void:
	if clue_id.is_empty():
		push_error("[Hotspot] clue_id is empty — set it in the Inspector.")
		return

	GameState.add_clue(clue_id, clue_title, clue_description, scene_name, clue_image_path)
	_show_clue_card()
	emit_signal("hotspot_activated", clue_id)
	print("[Hotspot] '%s' activated." % clue_id)

func _show_clue_card() -> void:
	# Lazy re-resolve in case _ready ran too early
	if _clue_card == null:
		_clue_card = get_node_or_null(clue_card_path)
	if _clue_card == null or not _clue_card.has_method("show_clue"):
		push_warning("[Hotspot:%s] ClueCard missing or has no show_clue()." % clue_id)
		return
	_clue_card.show_clue(clue_id, clue_title, clue_description, phone_mode)

# ---------------------------------------------------------------------------
# Key-clue pulse (scale bounce on the transparent Control itself)
# ---------------------------------------------------------------------------
func _start_pulse_animation() -> void:
	pivot_offset = size / 2.0  # Ensure it scales from the center
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.9)
	tween.tween_property(self, "scale", Vector2(1.0,  1.0),  0.9)
