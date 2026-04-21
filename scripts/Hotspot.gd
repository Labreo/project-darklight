extends Control

# ===========================================================================
# Hotspot.gd  (Control-based, viewport-stretch-safe)
# ---------------------------------------------------------------------------
# Uses _unhandled_input() + get_viewport().get_mouse_position() instead of
# _gui_input(), because _gui_input() hit-testing breaks when the window uses
# "Keep Aspect Ratio" or "Stretch to Fit" — the Control rect is in viewport
# space but the engine's hit test converts the mouse from screen space without
# accounting for the aspect-correct letterbox offset.
#
# get_global_rect()               → rect in viewport / canvas space
# get_viewport().get_mouse_position() → position in viewport space
# These two are always in the same space regardless of window stretch mode.
# ===========================================================================

@export var clue_id          : String   = ""
@export var clue_title       : String   = ""
@export var clue_description : String   = ""
@export var scene_name       : String   = "The Apartment"
@export var is_key_clue      : bool     = false
@export var phone_mode       : bool     = false
## res:// path to the clue sprite image.  Stored in GameState for the Clue Log.
@export var clue_image_path  : String   = ""
@export var clue_card_path   : NodePath = NodePath("../../UI/ClueCard")

signal hotspot_activated(clue_id: String)

var _clue_card   : Node = null
var _prev_inside : bool = false

# Shared cursor ownership across all Hotspot instances (static = class-level).
# Prevents multiple _process() calls from fighting over the cursor shape.
static var _cursor_owner : WeakRef = null

# ---------------------------------------------------------------------------
func _ready() -> void:
	# IGNORE means the Control doesn't participate in the engine's GUI hit
	# system at all.  We do our own hit testing in _unhandled_input() below.
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_clue_card = get_node_or_null(clue_card_path)
	if _clue_card == null:
		push_warning("[Hotspot:%s] ClueCard not found at '%s'." % [clue_id, clue_card_path])

	if is_key_clue:
		_start_pulse_animation()

# ---------------------------------------------------------------------------
# Input — viewport-stretch-safe click detection
# ---------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			# get_viewport().get_mouse_position() is always in viewport space.
			# get_global_rect()                 is always in viewport space.
			# Both agree regardless of window stretch / letterbox offset.
			if get_global_rect().has_point(get_viewport().get_mouse_position()):
				_activate()
				get_viewport().set_input_as_handled()

# ---------------------------------------------------------------------------
# Cursor — checked every frame, viewport-stretch-safe
# ---------------------------------------------------------------------------
func _process(_delta: float) -> void:
	var m      := get_viewport().get_mouse_position()
	var inside := get_global_rect().has_point(m)
	var i_own  := _cursor_owner != null and _cursor_owner.get_ref() == self

	if inside and not i_own:
		_cursor_owner = weakref(self)
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	elif not inside and i_own:
		_cursor_owner = null
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

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
	# Lazy re-resolve in case _ready() ran before the ClueCard entered the tree.
	if _clue_card == null:
		_clue_card = get_node_or_null(clue_card_path)
	if _clue_card == null or not _clue_card.has_method("show_clue"):
		push_warning("[Hotspot:%s] ClueCard missing or has no show_clue()." % clue_id)
		return
	_clue_card.show_clue(clue_id, clue_title, clue_description, phone_mode)

# ---------------------------------------------------------------------------
# Key-clue pulse (scale bounce on this transparent Control)
# ---------------------------------------------------------------------------
func _start_pulse_animation() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.9)
	tween.tween_property(self, "scale", Vector2(1.0,  1.0),  0.9)
