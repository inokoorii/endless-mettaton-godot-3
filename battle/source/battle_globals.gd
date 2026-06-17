extends Node


"AUTOLOAD SIGNALS"
signal health_max_changed
signal health_changed


"AUTOLOAD REGULAR VARIABLES"
var health_max: int = 4 \
		setget set_health_max
var health: int = 4 \
		setget set_health


"AUTOLOAD PUBLIC METHODS (SETTERS)"
func set_health_max(value: int) -> void:
	health_max = value
	health_max = clamp(health_max, 0, INF) as int
	emit_signal("health_max_changed")
	health = clamp(health, 0, health_max) as int


func set_health(value: int) -> void:
	health = value
	health = clamp(health, 0, health_max) as int
	emit_signal("health_changed")
