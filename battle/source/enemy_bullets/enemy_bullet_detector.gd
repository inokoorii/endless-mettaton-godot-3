tool
class_name BattleEnemyBulletDetector
extends Area2D


"CLASS SIGNALS"
signal action_changed
signal bullet_entered(bullet, bullet_type) # Emitted regardless of `action`.
signal entering_bullet_ignored(bullet, bullet_type)
signal entering_bullet_processed(bullet, bullet_type)


"CLASS ENUMERATIONS"
enum Actions {
	ACTION_IGNORE,
	ACTION_PROCESS_BULLET,
}


"CLASS EXPORTED VARIABLES"
var action: int = Actions.ACTION_IGNORE \
		setget set_action


"CLASS REGULAR VARIABLES"
var on_hit_invincibility_time_left: float \
		setget set_on_hit_invincibility_time_left # In seconds!

# Some bullets may have an instance of this class added as a child.
# To prevent `_handle_collisions()` from detecting its parent, they can append
# themselves to this array.
var ignored_areas: Array


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("BattleEnemyBulletDetectors", true)
	connect("area_entered", self, "_handle_collisions")


func _physics_process(delta: float) -> void:
	if not Engine.editor_hint:
		set_on_hit_invincibility_time_left(on_hit_invincibility_time_left - delta)
		
		if monitoring:
			for area in get_overlapping_areas():
				_handle_collisions(area)


"CLASS PUBLIC METHODS"
func is_moving() -> bool:
#	TODO: Switch to UNDERTALE's velocity-based movement detection.
	return (
			Input.is_action_pressed("move_left")
			or Input.is_action_pressed("move_right")
			or Input.is_action_pressed("move_up")
			or Input.is_action_pressed("move_down"))


"CLASS PRIVATE METHODS"
func _handle_collisions(area: Area2D) -> void:
	if not ignored_areas.has(area) and area is BattleEnemyBullet:
		match action:
			Actions.ACTION_IGNORE:
				emit_signal("entering_bullet_ignored", area, area.bullet_type)
			
			Actions.ACTION_PROCESS_BULLET:
#				Still unsure if the player damage/heal logic should be handled here
#				or other scripts should handle it themselves...
				
				if on_hit_invincibility_time_left <= 0.0:
					match area.bullet_type:
						BattleEnemyBullet.BulletTypes.BULLET_TYPE_DAMAGE:
							on_hit_invincibility_time_left = area.on_hit_invincibility_time
							emit_signal("entering_bullet_processed", area, area.bullet_type)
						
						BattleEnemyBullet.BulletTypes.BULLET_TYPE_DAMAGE_ON_IDLE:
							if is_moving():
								on_hit_invincibility_time_left = area.on_hit_invincibility_time
								emit_signal("entering_bullet_processed", area, area.bullet_type)
						
						BattleEnemyBullet.BulletTypes.BULLET_TYPE_DAMAGE_ON_MOVE:
							if not is_moving():
								on_hit_invincibility_time_left = area.on_hit_invincibility_time
								emit_signal("entering_bullet_processed", area, area.bullet_type)
		
		emit_signal("bullet_entered", area, area.bullet_type)


"CLASS PUBLIC METHODS (SETTERS)"
func set_action(value: int) -> void:
	action = value
	action = clamp(action, 0, Actions.size() - 1) as int
	emit_signal("action_changed")


func set_on_hit_invincibility_time_left(value: float) -> void:
	on_hit_invincibility_time_left = value
	on_hit_invincibility_time_left = clamp(on_hit_invincibility_time_left, 0.0, INF)


"CLASS PRIVATE METHODS (PROPERTY LIST)"
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
	
	property_list.append_array(
		[
			{
				"name": "action",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Ignore,Process Bullet",
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
