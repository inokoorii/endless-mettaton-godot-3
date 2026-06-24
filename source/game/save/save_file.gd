class_name SaveFile
extends Resource


"CLASS SIGNALS"
signal player_name_changed


"CLASS CONSTANTS"
const CURRENT_FORMAT_VERSION: int = 1


"CLASS VARIABLES"
var player_name: String = "Chara" \
		setget set_player_name


"CLASS PUBLIC METHODS (PROPERTY SETTERS)"
func set_player_name(value: String) -> void:
	player_name = value
	emit_signal("player_name_changed")
