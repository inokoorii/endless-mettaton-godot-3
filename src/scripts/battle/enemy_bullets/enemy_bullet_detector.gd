tool
class_name BattleEnemyBulletDetector
extends Area2D


# GODOT OVERRIDEN BUILT-IN VIRTUAL FUNCTIONS
func _ready() -> void:
	add_to_group("BattleEnemyBulletDetectors", true)


# CLASS PROPERTY LIST FUNCTIONS
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array(
		[
			{
				"name": "BattleEnemyBulletDetector",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_CATEGORY,
			},
		]
	)
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list: Dictionary = {
	}
	
	return property_list


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
