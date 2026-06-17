class_name SaveFile
extends Resource


"RESOURCE SIGNALS"
signal player_name_changed


"RESOURCE CONSTANTS"
const FILE_VERSION: int = 1


"RESOURCE VARIABLES"
var player_name: String = "Chara" \
		setget set_player_name


"RESOURCE PUBLIC METHODS"
func set_player_name(value: String) -> void:
	player_name = value
	emit_signal("player_name_changed")
