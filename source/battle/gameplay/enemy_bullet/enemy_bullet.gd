tool
class_name BattleEnemyBullet
extends Area2D


"CLASS SIGNALS"
signal bullet_type_changed
signal bullet_color_changed


"CLASS ENUMERATIONS"
enum BulletTypes {
	BULLET_TYPE_DAMAGE,
	BULLET_TYPE_DAMAGE_ON_IDLE,
	BULLET_TYPE_DAMAGE_ON_MOVE,
	BULLET_TYPE_HEAL,
	BULLET_TYPE_NO_DAMAGE,
}
enum BulletColors {
	BULLET_COLOR_WHITE,
	BULLET_COLOR_BLUE,
	BULLET_COLOR_ORANGE,
	BULLET_COLOR_GREEN,
	BULLET_COLOR_GRAY,
}


"CLASS EXPORTED VARIABLES"
var bullet_type: int = BulletTypes.BULLET_TYPE_DAMAGE \
		setget set_bullet_type
var bullet_color: int = BulletColors.BULLET_COLOR_WHITE \
		setget set_bullet_color

var on_hit_damage: int = 0 \
		setget set_on_hit_damage
var on_hit_heal: int = 0 \
		setget set_on_hit_heal
var on_hit_invincibility_time: float = 1.0 \
		setget set_on_hit_invincibility_time # In seconds!

var movement_speed: float = 0.0 \
		setget set_movement_speed
var movement_direction: Vector2 = Vector2.ZERO \
		setget set_movement_direction
var movement_rotation_degrees: float = 0.0 \
		setget set_movement_rotation_degrees
var movement_rotate_velocity: bool = false


"CLASS REGULAR VARIABLES"
var velocity: Vector2


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("BattleEnemyBullets", true)


func _physics_process(delta: float) -> void:
	_handle_bullet_movement(delta)


"CLASS PRIVATE METHODS"
func _update_modulate() -> void:
	match bullet_color:
		BulletColors.BULLET_COLOR_WHITE:
			modulate = Color("FFFFFF")
		
		BulletColors.BULLET_COLOR_BLUE:
			modulate = Color("00A2E8")
		
		BulletColors.BULLET_COLOR_ORANGE:
			modulate = Color("FFA914")
		
		BulletColors.BULLET_COLOR_GREEN:
			modulate = Color("00FF00")
		
		BulletColors.BULLET_COLOR_GRAY:
			modulate = Color("7F7F7F")


func _handle_bullet_movement(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	velocity = (movement_direction * movement_speed) * delta
	
	if movement_rotate_velocity:
		velocity = velocity.rotated(rotation)
	
	position += velocity
	rotation_degrees += movement_rotation_degrees * delta


"CLASS PUBLIC METHODS (SETTERS)"
func set_bullet_type(value: int) -> void:
	bullet_type = value
	bullet_type = clamp(bullet_type, 0, BulletTypes.size() - 1) as int
	emit_signal("bullet_type_changed")


func set_bullet_color(value: int) -> void:
	bullet_color = value
	bullet_color = clamp(bullet_color, 0, BulletColors.size() - 1) as int
	emit_signal("bullet_color_changed")
	_update_modulate()


func set_on_hit_damage(value: int) -> void:
	on_hit_damage = value
	on_hit_damage = clamp(on_hit_damage, 0, INF) as int


func set_on_hit_heal(value: int) -> void:
	on_hit_heal = value
	on_hit_heal = clamp(on_hit_heal, 0, INF) as int


func set_on_hit_invincibility_time(value: float) -> void:
	on_hit_invincibility_time = value
	on_hit_invincibility_time = clamp(on_hit_invincibility_time, 0.0, INF)


func set_movement_speed(value: float) -> void:
	movement_speed = value
	movement_speed = clamp(movement_speed, 0.0, INF)


func set_movement_direction(value: Vector2) -> void:
	movement_direction = value


func set_movement_rotation_degrees(value: float) -> void:
	movement_rotation_degrees = value


"CLASS PRIVATE METHODS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array([
		{
			"name": "BattleEnemyBullet",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY,
		},
	])
	
	property_list.append_array([
		{
			"name": "bullet_type",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Damage,Damage On Idle,Damage On Move,Heal,No Damage",
		},
		{
			"name": "bullet_color",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "White,Blue,Orange,Green,Gray",
		},
	])
	
	property_list.append_array([
		{
			"name": "On Hit",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "on_hit",
		},
		{
			"name": "on_hit_damage",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "on_hit_heal",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "on_hit_invincibility_time",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_EXP_RANGE,
			"hint_string": "0.0,4096.0,0.001,or_greater",
		},
	])
	
	property_list.append_array([
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
		{
			"name": "movement_direction",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "movement_rotation_degrees",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "-360.0,360.0,0.1,or_lesser,or_greater",
		},
		{
			"name": "movement_rotate_velocity",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	])
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list_reverts: Dictionary = {
		"bullet_type": BulletTypes.BULLET_TYPE_DAMAGE,
		"bullet_color": BulletColors.BULLET_COLOR_WHITE,
		"on_hit_damage": 0,
		"on_hit_heal": 0,
		"on_hit_invincibility_time": 1.0,
		"movement_speed": 0.0,
		"movement_direction": Vector2.ZERO,
		"movement_rotation_degrees": 0.0,
		"movement_rotate_velocity": false,
	}
	
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
