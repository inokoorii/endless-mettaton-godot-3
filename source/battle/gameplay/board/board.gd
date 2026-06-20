tool
class_name BattleBoard
extends Node2D


"CLASS SIGNALS"
signal resize_mode_changed
signal resize_began
signal resize_finished


"CLASS ENUMERATION"
enum ResizeModes {
	WIDTH_BEFORE_HEIGHT,
	WIDTH_AFTER_HEIGHT,
	WIDTH_AND_HEIGHT,
	INSTANT,
}


"CLASS EXPORTED VARIABLES"
var resize_mode: int = ResizeModes.WIDTH_BEFORE_HEIGHT \
		setget set_resize_mode
var resize_speed: float = 0.0 \
		setget set_resize_speed

var margin_left: int = -20
var margin_top: int = -20
var margin_right: int = 20
var margin_bottom: int = 20


"CLASS ONREADY VARIABLES"
onready var board_panel: Panel = \
		get_node_or_null("BoardPanel")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("BattleBoards", true)


"CLASS PUBLIC METHODS"
func is_resizing() -> bool:
	return (
			is_instance_valid(board_panel)
			and board_panel.margin_left == margin_left
			and board_panel.margin_top == margin_top
			and board_panel.margin_right == margin_right
			and board_panel.margin_bottom == margin_bottom)


"CLASS PUBLIC METHODS (SETTERS)"
func set_resize_mode(value: int) -> void:
	resize_mode = value
	resize_mode = clamp(resize_mode, 0, ResizeModes.size() - 1) as int
	emit_signal("resize_mode_changed")


func set_resize_speed(value: float) -> void:
	resize_speed = value
	resize_speed = clamp(resize_speed, 0.0, INF)


"CLASS PRIVATE METHODS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array(
		[
			{
				"name": "BattleArena",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_CATEGORY,
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "resize_mode",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Width Before Height,Width After Height,Width And Height,Instant",
			},
			{
				"name": "resize_speed",
				"type": TYPE_REAL,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "Margin",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
				"hint_string": "margin",
			},
			{
				"name": "margin_left",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "-4096,4096",
			},
			{
				"name": "margin_top",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "-4096,4096",
			},
			{
				"name": "margin_bottom",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "-4096,4096",
			},
			{
				"name": "margin_right",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "-4096,4096",
			},
		]
	)
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list: Dictionary = {
		"resize_mode": ResizeModes.WIDTH_BEFORE_HEIGHT,
		"resize_speed": 0.0,
		"margin_left": -20,
		"margin_top": -20,
		"margin_bottom": 20,
		"margin_right": 20,
	}
	
	return property_list


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
