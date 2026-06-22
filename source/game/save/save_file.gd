class_name SaveFile
extends Resource


"RESOURCE SIGNALS"
signal player_name_changed


"RESOURCE VARIABLES"
var player_name: String = "Chara" \
		setget set_player_name


"RESOURCE PUBLIC METHODS (PROPERTY SETTERS)"
func set_player_name(value: String) -> void:
	player_name = value
	emit_signal("player_name_changed")
