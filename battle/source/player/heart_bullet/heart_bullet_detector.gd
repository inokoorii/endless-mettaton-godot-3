tool
class_name BattlePlayerHeartBulletDetector
extends Area2D


"CLASS SIGNALS"
signal action_changed
signal bullet_entered  # Emitted regardless of `action`.
signal entering_bullet_ignored(bullet)
signal entering_bullet_destroyed
signal entering_bullet_deflected


"CLASS ENUMERATIONS"
enum Actions {
	ACTION_IGNORE,
	ACTION_DESTROY_BULLET,
	ACTION_DEFLECT_BULLET,
}


"CLASS EXPORTED VARIABLES"
var action: int = Actions.ACTION_IGNORE \
		setget set_action


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("BattlePlayerHeartBulletDetectors", true)
	connect("area_entered", self, "_handle_collisions")


"CLASS PRIVATE METHODS"
func _handle_collisions(area: Area2D) -> void:
	if area is BattlePlayerHeartBullet:
		match action:
			Actions.ACTION_IGNORE:
				emit_signal("entering_bullet_ignored", area)
			
			Actions.ACTION_DESTROY_BULLET:
				area.monitoring = false
				area.queue_free()
				emit_signal("entering_bullet_destroyed")
				
			Actions.ACTION_DEFLECT_BULLET:
				var bullet_deflected: Node2D = preload(str(
						"res://battle/source/player/heart_bullet/",
						"heart_bullet_deflected.tscn")).instance()
				
				area.monitoring = false
				area.get_parent().add_child(bullet_deflected)
				bullet_deflected.position = area.position
				bullet_deflected.scale = area.scale
				
				area.queue_free()
				emit_signal("entering_bullet_deflected")
		
		emit_signal("bullet_entered")


"CLASS PUBLIC METHODS (SETTERS)"
func set_action(value: int) -> void:
	action = value
	action = clamp(action, 0, Actions.size() - 1) as int
	emit_signal("action_changed")


"CLASS PRIVATE METHODS (PROPERTY LIST)"
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
				"hint_string": "Ignore,Destroy Bullet,Deflect Bullet",
			},
		]
	)
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list: Dictionary = {
		"action": Actions.ACTION_IGNORE,
	}
	
	return property_list


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
