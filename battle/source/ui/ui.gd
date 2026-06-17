extends Node2D


"SCRIPT ONREADY VARIABLES"
onready var hud_name: Label = \
		get_node_or_null("HUD/Name")
onready var hud_health_bar: ProgressBar = \
		get_node_or_null("HUD/Health/HBoxContainer/HealthBar")
onready var hud_health_text: Label = \
		get_node_or_null("HUD/Health/HBoxContainer/HealthText")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	_update_hud_name()
	_update_hud_health()
	
	if is_instance_valid(SaveFileManager.file):
		SaveFileManager.file.connect("player_name_changed", self, "_update_hud_name")
	
	BattleGlobals.connect("health_max_changed", self, "_update_hud_health")
	BattleGlobals.connect("health_changed", self, "_update_hud_health")


"SCRIPT PRIVATE METHODS"
func _update_hud_name() -> void:
	if is_instance_valid(hud_name) and is_instance_valid(SaveFileManager.file):
		hud_name.text = "%s   LV 1" % SaveFileManager.file.player_name


func _update_hud_health() -> void:
	if is_instance_valid(hud_health_bar):
		hud_health_bar.max_value = BattleGlobals.health_max
		hud_health_bar.value = BattleGlobals.health
	
	if is_instance_valid(hud_health_text):
		hud_health_text.text = "%02d / %02d" % [BattleGlobals.health, BattleGlobals.health_max]
