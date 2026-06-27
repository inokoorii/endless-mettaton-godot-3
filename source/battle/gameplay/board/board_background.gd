tool
extends Node2D


"SCRIPT EXPORTED VARIABLES"
var board: NodePath = NodePath("")\
	setget set_board


"SCRIPT ONREADY VARIABLES"
onready var background: Panel =\
	get_node_or_null("Background")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _process(delta: float) -> void:
	_update_background_rect()


"SCRIPT PRIVATE METHODS"
func _update_background_rect() -> void:
	var board_node: BattleBoard = get_node_or_null(board)
	
	if not is_instance_valid(background):
		return
	if not is_instance_valid(board_node) or is_instance_valid(board_node.board_panel):
		return
	
	position = board_node.position
	rotation_degrees = board_node.rotation_degrees
	scale = board_node.scale
	
	background.rect_position = board_node.board_panel.rect_position
	background.rect_size = board_node.board_panel.rect_size
	background.rect_rotation = board_node.board_panel.rect_rotation
	background.rect_scale = board_node.board_panel.rect_scale
	background.rect_pivot_offset = board_node.board_panel.rect_pivot_offset


"SCRIPT PUBLIC METHODS"
func set_board(value: NodePath) -> void:
	var node: Node = get_node_or_null(value)
	
	if not value.is_empty():
		if is_instance_valid(node) and (not node is BattleBoard):
			push_error(str(
				"BattleBoardBackground: Cannot assign '%s' to member 'board'; " % node.name,
				"node is not of type 'BattleBoard' (%s)." % node
			))
			return
	board = value


"SCRIPT PRIVATE METHODS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array([
		{
			"name": "BattleBoardBackground",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY,
		},
	])
	
	property_list.append_array([
		{
			"name": "board",
			"type": TYPE_NODE_PATH,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_NODE_PATH_VALID_TYPES,
			"hint_string": "Node2D",
		},
	])
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list_reverts: Dictionary = {
		"board": NodePath(""),
	}
	
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
