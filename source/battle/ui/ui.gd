tool
extends Node2D


"SCRIPT SIGNALS"
signal health_text_padding_mode_changed


"SCRIPT ENUMERATIONS"
enum HealthTextPaddingModes {
	PADDING_MODE_TO_TWO_DIGITS,
	PADDING_MODE_TO_MAX_HEALTH_DIGITS,
	PADDING_MODE_TO_CUSTOM_LENGTH,
	PADDING_MODE_NONE, 
}


"SCRIPT EXPORTED VARIABLES"
var health_text_padding_mode: int = HealthTextPaddingModes.PADDING_MODE_TO_TWO_DIGITS \
		setget set_health_text_padding_mode
var health_text_padding_custom_length: int = 0 \
		setget set_health_text_padding_custom_length


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
	_update_hud_health_bar()
	_update_hud_health_text()
	
	if Engine.editor_hint:
		return
	
	if is_instance_valid(SaveFileManager.file):
		SaveFileManager.file.connect("player_name_changed", self, "_update_hud_name")
	
	BattleGlobals.connect("max_health_changed", self, "_update_hud_health_bar")
	BattleGlobals.connect("health_changed", self, "_update_hud_health_bar")
	BattleGlobals.connect("max_health_changed", self, "_update_hud_health_text")
	BattleGlobals.connect("health_changed", self, "_update_hud_health_text")


"SCRIPT PRIVATE METHODS"
func _update_hud_name() -> void:
	if Engine.editor_hint:
		return
	if not is_instance_valid(hud_name) or not is_instance_valid(SaveFileManager.file):
		return
	
	hud_name.text = "%s   LV 1" % SaveFileManager.file.player_name


func _update_hud_health_bar() -> void:
	if Engine.editor_hint:
		return
	if not is_instance_valid(hud_health_bar):
		return
	
	hud_health_bar.max_value = BattleGlobals.max_health
	hud_health_bar.value = BattleGlobals.health


func _update_hud_health_text() -> void:
	if Engine.editor_hint:
		return
	if not is_instance_valid(hud_health_text):
		return
	
	match health_text_padding_mode:
		HealthTextPaddingModes.PADDING_MODE_TO_TWO_DIGITS:
			hud_health_text.text = "%02d / %02d" % [
				BattleGlobals.health,
				BattleGlobals.max_health,
			]
		
		HealthTextPaddingModes.PADDING_MODE_TO_MAX_HEALTH_DIGITS:
			hud_health_text.text = "%0*d / %02d" % [
				max(2, str(BattleGlobals.max_health).length()) as int,
				BattleGlobals.health,
				BattleGlobals.max_health
			]
		
		HealthTextPaddingModes.PADDING_MODE_TO_CUSTOM_LENGTH:
			hud_health_text.text = "%s / %s" % [
				str(BattleGlobals.health).pad_zeros(health_text_padding_custom_length),
				str(BattleGlobals.max_health).pad_zeros(health_text_padding_custom_length),
			]
		
		HealthTextPaddingModes.PADDING_MODE_NONE:
			hud_health_text.text = "%d / %d" % [
				BattleGlobals.health,
				BattleGlobals.max_health,
			]


"SCRIPT PUBLIC METHODS (SETTERS)"
func set_health_text_padding_mode(value: int) -> void:
	health_text_padding_mode = value
	health_text_padding_mode = clamp(
			health_text_padding_mode, 0, HealthTextPaddingModes.size() - 1) as int
	
	emit_signal("health_text_padding_mode_changed")
	_update_hud_health_text()
	property_list_changed_notify()


func set_health_text_padding_custom_length(value: int) -> void:
	health_text_padding_custom_length = value
	health_text_padding_custom_length = clamp(health_text_padding_custom_length, 0, INF) as int
	_update_hud_health_text()


"SCRIPT PRIVATE METHODS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array([
		{
			"name": "BattleUI",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY,
		},
	])
	
	property_list.append_array([
		{
			"name": "Health Text",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP,
			"hint_string": "health_text",
		},
		{
			"name": "health_text_padding_mode",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "To Two Digits,To Max Health Digits,To Custom Length,None",
		},
	])
	
	if health_text_padding_mode == HealthTextPaddingModes.PADDING_MODE_TO_CUSTOM_LENGTH:
		property_list.append_array([
			{
				"name": "health_text_padding_custom_length",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
			}
		])
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list_reverts: Dictionary = {
		"health_text_padding_mode": HealthTextPaddingModes.PADDING_MODE_TO_TWO_DIGITS,
		"health_text_padding_custom_length": 0,
	}
	
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
