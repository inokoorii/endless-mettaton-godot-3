extends Node


"AUTOLOAD SIGNALS"
signal max_health_changed
signal max_health_decreased
signal max_health_increased

signal health_changed
signal health_decreased
signal health_increased
signal health_depleted
signal health_full


"AUTOLOAD REGULAR VARIABLES"
var battle: Battle

var max_health: int = 4 \
		setget set_max_health
var health: int = 4 \
		setget set_health


"AUTOLOAD PUBLIC METHODS (PROPERTY SETTERS)"
func set_max_health(value: int) -> void:
	var previous_max_health: int = max_health
	
	max_health = value
	max_health = clamp(max_health, 0, INF) as int
	health = clamp(health, 0, max_health) as int
	emit_signal("max_health_changed")
	
	if max_health < previous_max_health:
		emit_signal("max_health_decreased")
	if max_health > previous_max_health:
		emit_signal("max_health_increased")


func set_health(value: int) -> void:
	var previous_health: int = health
	
	health = value
	health = clamp(health, 0, max_health) as int
	emit_signal("health_changed")
	
	if health < previous_health:
		emit_signal("health_decreased")
	if health > previous_health:
		emit_signal("health_increased")
	
	if health <= 0:
		emit_signal("health_depleted")
	if health >= max_health:
		emit_signal("health_full")
