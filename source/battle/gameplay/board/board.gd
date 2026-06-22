tool
class_name BattleBoard
extends Node2D


"CLASS SIGNALS"
signal resize_mode_changed

# FIXME: Signals not being emitted when `resize_mode` is set to
# `ResizeModes.RESIZE_MODE_INSTANT`.
signal resize_began
signal resize_finished


"CLASS ENUMERATIONS"
enum ResizeModes {
	RESIZE_MODE_WIDTH_BEFORE_HEIGHT,
	RESIZE_MODE_WIDTH_AFTER_HEIGHT,
	RESIZE_MODE_WIDTH_AND_HEIGHT,
	RESIZE_MODE_INSTANT,
}


"CLASS EXPORTED VARIABLES"
var resize_mode: int = ResizeModes.RESIZE_MODE_WIDTH_BEFORE_HEIGHT \
		setget set_resize_mode
var resize_speed: float = 480.0 \
		setget set_resize_speed

var ideal_size_left: int = 287
var ideal_size_top: int = 70
var ideal_size_right: int = 287
var ideal_size_bottom: int = 70

# The values of these offsets are generally set to match the
# `board_panel` node's border widths on each side.
var collider_offset_left: int = 5
var collider_offset_top: int = 5
var collider_offset_right: int = 5
var collider_offset_bottom: int = 5

var anchor_markers_visible: bool = false \
		setget set_anchor_markers_visible
var anchor_markers_modulate: Color = Color.white \
		setget set_anchor_markers_modulate


"CLASS REGULAR VARIABLES"
var _resize_progress_time: float # In seconds!


"CLASS ONREADY VARIABLES"
onready var board_panel: Panel = \
		get_node_or_null("BoardPanel")

onready var board_collider_left: CollisionShape2D = \
		get_node_or_null("BoardPanel/BoardColliders/Left")
onready var board_collider_top: CollisionShape2D = \
		get_node_or_null("BoardPanel/BoardColliders/Top")
onready var board_collider_right: CollisionShape2D = \
		get_node_or_null("BoardPanel/BoardColliders/Right")
onready var board_collider_bottom: CollisionShape2D = \
		get_node_or_null("BoardPanel/BoardColliders/Bottom")

onready var anchor_markers: Node2D = \
		get_node_or_null("BoardPanel/AnchorMarkers")
onready var anchor_marker_top_left: Sprite = \
		get_node_or_null("BoardPanel/AnchorMarkers/TopLeft")
onready var anchor_marker_top_right: Sprite = \
		get_node_or_null("BoardPanel/AnchorMarkers/TopRight")
onready var anchor_marker_center: Sprite = \
		get_node_or_null("BoardPanel/AnchorMarkers/Center")
onready var anchor_marker_bottom_left: Sprite = \
		get_node_or_null("BoardPanel/AnchorMarkers/BottomLeft")
onready var anchor_marker_bottom_right: Sprite = \
		get_node_or_null("BoardPanel/AnchorMarkers/BottomRight")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("BattleBoards", true)
	_update_anchor_marker_visibilities()


func _physics_process(delta: float) -> void:
	_handle_panel_resize(delta)
	_track_panel_resize_progress(delta)
	_update_collider_positions()
	_update_anchor_marker_positions()


"CLASS PUBLIC METHODS"
func is_width_resized() -> bool:
	return (
			is_instance_valid(board_panel)
			and board_panel.margin_left == -ideal_size_left
			and board_panel.margin_right == ideal_size_right)


func is_height_resized() -> bool:
	return (
			is_instance_valid(board_panel)
			and board_panel.margin_top == -ideal_size_top
			and board_panel.margin_bottom == ideal_size_bottom)


func is_resized() -> bool:
	return (
			is_instance_valid(board_panel)
			and is_width_resized()
			and is_height_resized())


func get_panel_top_left_position() -> Vector2:
	if not is_instance_valid(anchor_marker_top_left):
		push_error(
				"Cannot get panel top-left position: "
				+ "'anchor_marker_top_left' node is invalid or null.")
		return Vector2.ZERO
	
	return anchor_marker_top_left.global_position


func get_panel_top_right_position() -> Vector2:
	if not is_instance_valid(anchor_marker_top_right):
		push_error(
				"Cannot get panel top-right position: "
				+ "'anchor_marker_top_right' node is invalid or null.")
		return Vector2.ZERO
	
	return anchor_marker_top_right.global_position


func get_panel_center_position() -> Vector2:
	if not is_instance_valid(anchor_marker_center):
		push_error(
				"Cannot get panel center position: "
				+ "'anchor_marker_center' node is invalid or null.")
		return Vector2.ZERO
	
	return anchor_marker_center.global_position


func get_panel_bottom_left_position() -> Vector2:
	if not is_instance_valid(anchor_marker_bottom_left):
		push_error(
				"Cannot get panel bottom-left position: "
				+ "'anchor_marker_bottom_left' node is invalid or null.")
		return Vector2.ZERO
	
	return anchor_marker_bottom_left.global_position


func get_panel_bottom_right_position() -> Vector2:
	if not is_instance_valid(anchor_marker_bottom_right):
		push_error(
				"Cannot get panel bottom-right position: "
				+ "'anchor_marker_bottom_right' node is invalid or null.")
		return Vector2.ZERO
	
	return anchor_marker_bottom_right.global_position


"CLASS PRIVATE METHODS"
func _handle_panel_resize(delta: float) -> void:
	if not is_instance_valid(board_panel):
		return
	
	match resize_mode:
		ResizeModes.RESIZE_MODE_WIDTH_BEFORE_HEIGHT:
			if not is_width_resized():
				_move_panel_margins_width(delta)
			else:
				_move_panel_margins_height(delta)
		
		ResizeModes.RESIZE_MODE_WIDTH_AFTER_HEIGHT:
			if not is_height_resized():
				_move_panel_margins_height(delta)
			else:
				_move_panel_margins_width(delta)
		
		ResizeModes.RESIZE_MODE_WIDTH_AND_HEIGHT:
			_move_panel_margins_width(delta)
			_move_panel_margins_height(delta)
		
		ResizeModes.RESIZE_MODE_INSTANT:
			_snap_panel_margins_width()
			_snap_panel_margins_height()
	
	board_panel.rect_pivot_offset = board_panel.rect_size / 2.0


func _track_panel_resize_progress(delta: float) -> void:
	if not is_resized():
		if _resize_progress_time <= 0.0:
			emit_signal("resize_began")
		
		_resize_progress_time += delta
	else:
		if _resize_progress_time > 0.0:
			emit_signal("resize_finished")
		
		_resize_progress_time = 0.0


func _move_panel_margins_width(delta: float) -> void:
	if not is_instance_valid(board_panel):
		return
	
	var resize_delta: float = resize_speed * delta
	board_panel.margin_left = move_toward(board_panel.margin_left, -ideal_size_left, resize_delta)
	board_panel.margin_right = move_toward(board_panel.margin_right, ideal_size_right, resize_delta)


func _move_panel_margins_height(delta: float) -> void:
	if not is_instance_valid(board_panel):
		return
	
	var resize_delta: float = resize_speed * delta
	board_panel.margin_top = move_toward(board_panel.margin_top, -ideal_size_top, resize_delta)
	board_panel.margin_bottom = move_toward(board_panel.margin_bottom, ideal_size_bottom, resize_delta)


func _snap_panel_margins_width() -> void:
	if not is_instance_valid(board_panel):
		return
	
	board_panel.margin_left = -ideal_size_left
	board_panel.margin_right = ideal_size_right


func _snap_panel_margins_height() -> void:
	if not is_instance_valid(board_panel):
		return
	
	board_panel.margin_top = -ideal_size_top
	board_panel.margin_bottom = ideal_size_bottom


func _update_collider_positions() -> void:
	if not is_instance_valid(board_panel):
		return
	
	var panel_width: float = board_panel.rect_size.x
	var panel_width_center: float = panel_width / 2.0
	var panel_height: float = board_panel.rect_size.y
	var panel_height_center: float = panel_height / 2.0
	
	if is_instance_valid(board_collider_left) and is_instance_valid(board_collider_left.shape):
		board_collider_left.position = Vector2(
				-board_collider_left.shape.extents.x + collider_offset_left,
				panel_height_center)
	
	if is_instance_valid(board_collider_top) and is_instance_valid(board_collider_top.shape):
		board_collider_top.position = Vector2(
				panel_width_center,
				-board_collider_top.shape.extents.y + collider_offset_top)
	
	if is_instance_valid(board_collider_right) and is_instance_valid(board_collider_right.shape):
		board_collider_right.position = Vector2(
				panel_width + (board_collider_right.shape.extents.x - collider_offset_right),
				panel_height_center)
	
	if is_instance_valid(board_collider_bottom) and is_instance_valid(board_collider_bottom.shape):
		board_collider_bottom.position = Vector2(
				panel_width_center,
				panel_height + (board_collider_bottom.shape.extents.y - collider_offset_bottom))


func _update_anchor_marker_positions() -> void:
	if not is_instance_valid(board_panel):
		return
	
	var panel_width: float = board_panel.rect_size.x
	var panel_width_center: float = panel_width / 2.0
	var panel_height: float = board_panel.rect_size.y
	var panel_height_center: float = panel_height / 2.0
	
	if is_instance_valid(anchor_marker_top_left):
		anchor_marker_top_left.position = Vector2.ZERO
	
	if is_instance_valid(anchor_marker_top_right):
		anchor_marker_top_right.position = Vector2(panel_width, 0.0)
	
	if is_instance_valid(anchor_marker_center):
		anchor_marker_center.position = board_panel.rect_size / 2.0
	
	if is_instance_valid(anchor_marker_bottom_left):
		anchor_marker_bottom_left.position = Vector2(0.0, panel_height)
	
	if is_instance_valid(anchor_marker_top_right):
		anchor_marker_bottom_right.position = board_panel.rect_size


func _update_anchor_marker_visibilities() -> void:
	if not is_instance_valid(anchor_markers):
		return
	
	anchor_markers.visible = anchor_markers_visible
	anchor_markers.modulate = anchor_markers_modulate


"CLASS PUBLIC METHODS (PROPERTY SETTERS)"
func set_resize_mode(value: int) -> void:
	resize_mode = value
	resize_mode = clamp(resize_mode, 0, ResizeModes.size() - 1) as int
	emit_signal("resize_mode_changed")


func set_resize_speed(value: float) -> void:
	resize_speed = value
	resize_speed = clamp(resize_speed, 0.0, INF)


func set_anchor_markers_visible(value: bool) -> void:
	anchor_markers_visible = value
	_update_anchor_marker_visibilities()


func set_anchor_markers_modulate(value: Color) -> void:
	anchor_markers_modulate = value
	_update_anchor_marker_visibilities()


"CLASS PRIVATE METHODS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array([
		{
			"name": "BattleBoard",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY,
		},
	])
	
	property_list.append_array([
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
	])
	
	property_list.append_array([
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
	])
	
	property_list.append_array([
		{
			"name": "Collider Offsets",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP,
			"hint_string": "collider_offset"
		},
		{
			"name": "collider_offset_left",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "collider_offset_top",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "collider_offset_right",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "collider_offset_bottom",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	])
	
	property_list.append_array([
		{
			"name": "Anchor Markers",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP,
			"hint_string": "anchor_markers",
		},
		{
			"name": "anchor_markers_visible",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "anchor_markers_modulate",
			"type": TYPE_COLOR,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	])
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list_reverts: Dictionary = {
		"resize_mode": ResizeModes.RESIZE_MODE_WIDTH_BEFORE_HEIGHT,
		"resize_speed": 480.0,
		"ideal_size_left": 287,
		"ideal_size_top": 70,
		"ideal_size_right": 287,
		"ideal_size_bottom": 70,
		"collider_offset_left": 5,
		"collider_offset_top": 5,
		"collider_offset_right": 5,
		"collider_offset_bottom": 5,
		"anchor_markers_visible": false,
		"anchor_markers_modulate": Color.white,
	}
	
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
