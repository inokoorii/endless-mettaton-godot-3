tool
class_name BattlePlayerHeartBulletDetector
extends Area2D


# CLASS SIGNALS
signal action_changed
signal bullet_entered(bullet)


# CLASS ENUMERATIONS
enum Actions {
	ACTION_IGNORE,
	ACTION_DESTROY,
	ACTION_DEFLECT,
}


# CLASS EXPORT VARIABLES
var action: int = Actions.ACTION_IGNORE \
		setget set_action


# GODOT OVERRIDEN BUILT-IN VIRTUAL FUNCTIONS
func _ready() -> void:
	add_to_group("BattlePlayerHeartBulletDetectors", true)
	connect("area_entered", self, "_on_area_entered")


# CLASS SIGNAL CONNECTION FUNCTIONS
func _on_area_entered(area: Area2D) -> void:
	if area is BattlePlayerHeartBullet:
		match action:
			Actions.ACTION_IGNORE:
				emit_signal("bullet_entered", area)
			
			Actions.ACTION_DESTROY:
				area.queue_free()
				emit_signal("bullet_entered", null)
			
			Actions.ACTION_DEFLECT:
				var bullet_deflected: Node2D = \
						preload("res://src/scenes/battle/player/player_heart_bullet_deflected.tscn") \
								.instance()
				
				area.get_parent().add_child(bullet_deflected)
				bullet_deflected.position = area.position
				bullet_deflected.scale = area.scale
				
				area.queue_free()
				emit_signal("bullet_entered", null)


# CLASS SETTER FUNCTIONS
func set_action(value: int) -> void:
	action = value
	action = clamp(action, 0, Actions.size() - 1) as int
	emit_signal("action_changed")


# CLASS PROPERTY LIST FUNCTIONS
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array(
		[
			{
				"name": "BattlePlayerHeartBulletDetector",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_CATEGORY,
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "action",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Ignore,Destroy,Deflect",
			},
		]
	)
	
	return property_list


func property_can_revert(property: String):
	var property_list: Dictionary = {
		"action": true,
	}
	
	if property_list.keys().has(property):
		return property_list.get(property)


func property_get_revert(property: String):
	var property_list: Dictionary = {
		"action": Actions.ACTION_IGNORE,
	}
	
	if property_list.keys().has(property):
		return property_list.get(property)
