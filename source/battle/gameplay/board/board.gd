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
var resize_speed: float = 480.0 \
		setget set_resize_speed

var ideal_size_left: int = -287
var ideal_size_top: int = -70
var ideal_size_right: int = 287
var ideal_size_bottom: int = 70


"CLASS REGULAR VARIABLES"
var _resize_progress_time: float # In seconds!


"CLASS ONREADY VARIABLES"
onready var board_panel: Panel = \
		get_node_or_null("BoardPanel")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("BattleBoards", true)


func _physics_process(delta: float) -> void:
	_handle_resize(delta)
	_track_resize_progress(delta)


"CLASS PUBLIC METHODS"
func is_resized() -> bool:
	return (
			is_instance_valid(board_panel)
			and is_width_resized()
			and is_height_resized())


func is_width_resized() -> bool:
	return (
			is_instance_valid(board_panel)
			and board_panel.margin_left == ideal_size_left
			and board_panel.margin_right == ideal_size_right)


func is_height_resized() -> bool:
	return (
			is_instance_valid(board_panel)
			and board_panel.margin_top == ideal_size_top
			and board_panel.margin_bottom == ideal_size_bottom)


"CLASS PRIVATE METHODS"
func _handle_resize(delta: float) -> void:
	match resize_mode:
		ResizeModes.WIDTH_BEFORE_HEIGHT:
			if is_width_resized():
				_update_panel_height(delta)
			else:
				_update_panel_width(delta)
		
		ResizeModes.WIDTH_AFTER_HEIGHT:
			if is_height_resized():
				_update_panel_width(delta)
			else:
				_update_panel_height(delta)
		
		ResizeModes.WIDTH_AND_HEIGHT:
			_update_panel_width(delta)
			_update_panel_height(delta)
		
		ResizeModes.INSTANT:
			_update_panel_width_instant()
			_update_panel_height_instant()


func _track_resize_progress(delta: float) -> void:
	if not Engine.editor_hint:
		var resizing: bool = not is_resized()
		
		if resizing:
			if _resize_progress_time <= 0.0:
				emit_signal("resize_began")
			
			_resize_progress_time += delta
		else:
			if _resize_progress_time > 0.0:
				emit_signal("resize_finished")
			
			_resize_progress_time = 0.0


func _update_panel_width(delta: float) -> void:
	if not Engine.editor_hint and is_instance_valid(board_panel):
		var speed: float = resize_speed * delta
		
		board_panel.margin_left = move_toward(board_panel.margin_left, ideal_size_left, speed)
		board_panel.margin_right = move_toward(board_panel.margin_right, ideal_size_right, speed)


func _update_panel_height(delta: float) -> void:
	if not Engine.editor_hint and is_instance_valid(board_panel):
		var speed: float = resize_speed * delta
		
		board_panel.margin_top = move_toward(board_panel.margin_top, ideal_size_top, speed)
		board_panel.margin_bottom = move_toward(board_panel.margin_bottom, ideal_size_bottom, speed)


func _update_panel_width_instant() -> void:
	if not Engine.editor_hint and is_instance_valid(board_panel):
		board_panel.margin_left = ideal_size_left
		board_panel.margin_right = ideal_size_right


func _update_panel_height_instant() -> void:
	if not Engine.editor_hint and is_instance_valid(board_panel):
		board_panel.margin_top = ideal_size_top
		board_panel.margin_bottom = ideal_size_bottom


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
				"name": "Ideal Size",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
				"hint_string": "ideal_size",
			},
			{
				"name": "ideal_size_left",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "-4096,4096",
			},
			{
				"name": "ideal_size_top",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "-4096,4096",
			},
			{
				"name": "ideal_size_right",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "-4096,4096",
			},
			{
				"name": "ideal_size_bottom",
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
		"resize_speed": 480.0,
		"ideal_size_left": -287,
		"ideal_size_top": -70,
		"ideal_size_right": 287,
		"ideal_size_bottom": 70,
	}
	
	return property_list


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
