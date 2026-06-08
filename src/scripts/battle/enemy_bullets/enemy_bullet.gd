tool
class_name BattleEnemyBullet
extends Area2D


# CLASS SIGNALS
signal bullet_type_changed
signal bullet_color_changed


# CLASS ENUMERATIONS
enum BulletTypes {
	BULLET_TYPE_DAMAGE,
	BULLET_TYPE_DAMAGE_ON_IDLE,
	BULLET_TYPE_DAMAGE_ON_MOVE,
	BULLET_TYPE_HEAL,
}
enum BulletColors {
	BULLET_COLOR_WHITE,
	BULLET_COLOR_BLUE,
	BULLET_COLOR_ORANGE,
	BULLET_COLOR_GREEN,
}


# CLASS EXPORT VARIABLES
var bullet_type: int = BulletTypes.BULLET_TYPE_DAMAGE \
		setget set_bullet_type
var bullet_color: int = BulletColors.BULLET_COLOR_WHITE \
		setget set_bullet_color

var on_hit_damage: int = 0 \
		setget set_on_hit_damage
var on_hit_heal: int = 0 \
		setget set_on_hit_heal
var on_hit_invincibility_frames: = 0 \
		setget set_on_hit_invincibility_frames

var movement_speed: float = 0.0 \
		setget set_movement_speed


# GODOT OVERRIDEN BUILT-IN VIRTUAL FUNCTIONS
func _ready() -> void:
	add_to_group("BattleEnemyBullets", true)


# CLASS SETTER FUNCIONS
func set_bullet_type(value: int) -> void:
	bullet_type = value
	bullet_type = clamp(bullet_type, 0, BulletTypes.size() - 1) as int
	
	property_list_changed_notify()
	emit_signal("bullet_type_changed")


func set_bullet_color(value: int) -> void:
	bullet_color = value
	bullet_color = clamp(bullet_color, 0, BulletColors.size() - 1) as int
	emit_signal("bullet_color_changed")


func set_on_hit_damage(value: int) -> void:
	on_hit_damage = value
	on_hit_damage = clamp(on_hit_damage, 0, INF) as int


func set_on_hit_heal(value: int) -> void:
	on_hit_heal = value
	on_hit_heal = clamp(on_hit_heal, 0, INF) as int


func set_on_hit_invincibility_frames(value: int) -> void:
	on_hit_invincibility_frames = value
	on_hit_invincibility_frames = clamp(on_hit_invincibility_frames, 0, INF) as int


func set_movement_speed(value: float) -> void:
	movement_speed = value
	movement_speed = clamp(movement_speed, 0.0, INF)


# CLASS PROPERTY LIST FUNCTIONS
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array(
		[
			{
				"name": "BattleEnemyBullet",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_CATEGORY,
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "Bullet",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "bullet",
			},
			{
				"name": "bullet_type",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Damage,Damage On Idle,Damage On Move,Heal"
			},
			{
				"name": "bullet_color",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "White,Blue,Orange,Green"
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "On Hit Overrides",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "on_hit",
			},
		]
	)
	match bullet_type:
		BulletTypes.BULLET_TYPE_DAMAGE, \
		BulletTypes.BULLET_TYPE_DAMAGE_ON_IDLE, \
		BulletTypes.BULLET_TYPE_DAMAGE_ON_MOVE:
			property_list.append_array(
				[
					{
						"name": "on_hit_damage",
						"type": TYPE_INT,
						"usage": PROPERTY_USAGE_DEFAULT,
					},
				]
			)
		BulletTypes.BULLET_TYPE_HEAL:
			property_list.append_array(
				[
					{
						"name": "on_hit_heal",
						"type": TYPE_INT,
						"usage": PROPERTY_USAGE_DEFAULT,
					},
				]
			)
	property_list.append_array(
		[
			{
				"name": "on_hit_invincibility_frames",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "Movement",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "movement",
			},
			{
				"name": "movement_speed",
				"type": TYPE_REAL,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
		]
	)
	
	return property_list


func property_can_revert(property: String):
	var property_list: Dictionary = {
		"bullet_type": true,
		"bullet_color": true,
		"on_hit_damage": true,
		"on_hit_heal": true,
		"on_hit_invincibility_frames": true,
		"movement_speed": true,
	}
	
	if property_list.keys().has(property):
		return property_list.get(property)


func property_get_revert(property: String):
	var property_list: Dictionary = {
		"bullet_type": BulletTypes.BULLET_TYPE_DAMAGE,
		"bullet_color": BulletColors.BULLET_COLOR_WHITE,
		"on_hit_damage": 0,
		"on_hit_heal": 0,
		"on_hit_invincibility_frames": 0,
		"movement_speed": 0.0,
	}
	
	if property_list.keys().has(property):
		return property_list.get(property)
