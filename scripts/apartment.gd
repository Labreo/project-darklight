extends Control

# ===========================================================================
# apartment.gd
# ---------------------------------------------------------------------------
# Lightweight controller for the Apartment scene.
# The scene is Control-based (fullscreen anchors + TextureRect background),
# matching the same architecture as map_screen.tscn and title_screen.tscn,
# so no Camera2D or zoom is needed.
# ===========================================================================

func _ready() -> void:
	# Main.gd handles adding this to the visited scenes list.
	print("[Apartment] Scene ready.")
