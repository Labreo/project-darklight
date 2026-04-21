extends CanvasLayer

# ===========================================================================
# ClueCard.gd
# ---------------------------------------------------------------------------
# A fullscreen (or centred) overlay that presents a collected clue to the
# player as a "static clue card".  Supports two display modes:
#
#   Standard mode  – A title and a description paragraph.  Used for C1, C3–C6.
#   Phone mode     – Used exclusively for C2 (Felix's phone).  Renders the
#                    texts as a simple chat-bubble list without any puzzle.
#                    This satisfies the Project Plan v3 decision: Phone unlock
#                    minigame is DROPPED → tap phone → texts appear instantly.
#
# Node structure assumed in ClueCard.tscn:
#   ClueCard (CanvasLayer, layer = 10)
#   └── Panel (PanelContainer, anchored to centre)
#       ├── VBoxContainer
#       │   ├── LblClueId     (Label  – shows "CLUE C4" etc.)
#       │   ├── LblTitle      (Label  – clue_title)
#       │   ├── Divider       (HSeparator)
#       │   ├── PhoneContainer (VBoxContainer – visible only in phone_mode)
#       │   │   ├── PhoneBubble1 (Label)
#       │   │   ├── PhoneBubble2 (Label)
#       │   │   └── PhoneBubble3 (Label)
#       │   ├── LblDescription (Label  – visible only in standard mode)
#       │   └── BtnClose       (Button – "Got it ✓")
# ===========================================================================

# ── Node references (filled in _ready via @onready) ─────────────────────────
@onready var panel           : PanelContainer = $Panel
@onready var lbl_clue_id     : Label          = $Panel/VBoxContainer/LblClueId
@onready var lbl_status      : Label          = $Panel/VBoxContainer/LblStatus
@onready var lbl_title       : Label          = $Panel/VBoxContainer/LblTitle
@onready var lbl_description : Label          = $Panel/VBoxContainer/LblDescription
@onready var phone_container : VBoxContainer  = $Panel/VBoxContainer/PhoneContainer
@onready var btn_close       : Button         = $Panel/VBoxContainer/BtnClose

# Pre-built phone text lines for C2 — set here rather than in GameState so
# all UI copy lives in one place.
const PHONE_TEXTS : Array[String] = [
	"Felix → Felicia  [7:00 PM]\n\"You OWE me. This ends NOW.\"",
	"Felicia → Felix  [7:03 PM]\n\"Please don't do this tonight.\"",
	"Felix → Felicia  [7:05 PM]\n\"If you go through with it I'll make sure\neveryone knows what you did.\""
]

# ---------------------------------------------------------------------------
func _ready() -> void:
	# Start hidden; show() is called by Hotspot.gd.
	visible = false

	# Wire the close button.
	btn_close.pressed.connect(_on_close_pressed)

	# Also allow pressing Escape or UI-Cancel to dismiss.
	set_process_unhandled_input(true)

# ---------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_dismiss()
		get_viewport().set_input_as_handled()

# ---------------------------------------------------------------------------
# Public API — called by Hotspot.gd
# ---------------------------------------------------------------------------

## show_clue
## Populates and reveals the clue card.
##
## Parameters:
##   id          – The clue identifier, e.g. "C4"
##   title       – Short display name shown as the card headline
##   description – Full reveal text shown to the player
##   is_phone    – When true, renders the phone-texts layout (C2 only)
##   is_new      – True if newly discovered, false if already logged
func show_clue(id: String, title: String, description: String, is_phone: bool = false, is_new: bool = true) -> void:
	# ── Populate shared fields ───────────────────────────────────────────────
	lbl_clue_id.text = "CLUE  %s" % id.to_upper()
	lbl_title.text   = title
	
	if is_new:
		lbl_status.text = "★ NEW FIND LOGGED"
		lbl_status.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	else:
		lbl_status.text = "✓ ALREADY LOGGED"
		lbl_status.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))

	if is_phone:
		# ── Phone mode (C2 — Felix's phone) ─────────────────────────────────
		# Project Plan v3: "tap phone → texts appear as static clue card
		# (no puzzle — simplified)".
		# Hide plain description; show the chat-bubble container instead.
		lbl_description.visible  = false
		phone_container.visible  = true

		# Clear any children from a previous activation.
		for child in phone_container.get_children():
			child.queue_free()

		# Build each text bubble as a simple Label.
		for text in PHONE_TEXTS:
			var bubble := Label.new()
			bubble.text              = text
			bubble.autowrap_mode     = TextServer.AUTOWRAP_WORD_SMART
			bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			# Give a subtle background feel via theme override (adjust in-editor).
			bubble.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
			phone_container.add_child(bubble)
	else:
		# ── Standard mode (C1, C3–C6) ────────────────────────────────────────
		lbl_description.text     = description
		lbl_description.visible  = true
		phone_container.visible  = false

	# ── Animate in ──────────────────────────────────────────────────────────
	visible = true
	panel.modulate.a = 0.0
	panel.scale      = Vector2(0.85, 0.85)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0,           0.22)
	tween.tween_property(panel, "scale",      Vector2.ONE,   0.22) \
		 .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	print("[ClueCard] Displaying clue: %s (%s) | phone_mode=%s" % [id, title, is_phone])

# ---------------------------------------------------------------------------
# Close / dismiss
# ---------------------------------------------------------------------------
func _on_close_pressed() -> void:
	_dismiss()

func _dismiss() -> void:
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.16)
	tween.tween_callback(func(): visible = false)
