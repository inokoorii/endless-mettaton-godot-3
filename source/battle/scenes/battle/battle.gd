tool
class_name Battle
extends Node2D


"CLASS ONREADY VARIABLES"
onready var board: BattleBoard = \
	get_node_or_null("Board")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _enter_tree() -> void:
	if Engine.editor_hint:
		return
	if BattleGlobals.battle and not BattleGlobals.battle == self:
		push_error(str(
			"Failed to assign self to member 'BattleGlobals.battle': ",
			"another 'Battle' is already assigned (%s)." % BattleGlobals.battle
		))
		return
	
	BattleGlobals.battle = self


func _exit_tree() -> void:
	if Engine.editor_hint:
		return
	if BattleGlobals.battle and not BattleGlobals.battle == self:
		push_error(str(
			"Failed to remove self from member 'BattleGlobals.battle': ",
			"it is assigned to another 'Battle' (%s)." % BattleGlobals.battle
		))
		return
	
	BattleGlobals.battle = null

