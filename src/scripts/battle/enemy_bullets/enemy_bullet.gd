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
	BULLET_TYPE_NO_DAMAGE,
}
enum BulletColors {
	BULLET_COLOR_WHITE,
	BULLET_COLOR_BLUE,
	BULLET_COLOR_ORANGE,
	BULLET_COLOR_GREEN,
	BULLET_COLOR_GRAY,
}


# CLASS CONSTANTS
const BULLET_COLOR_WHITE: Color = Color("FFFFFF")
const BULLET_COLOR_BLUE: Color = Color("00A2E8")
const BULLET_COLOR_ORANGE: Color = Color("FFA914")
const BULLET_COLOR_GREEN: Color = Color("00FF00")
const BULLET_COLOR_GRAY: Color = Color("7F7F7F")


# CLASS EXPORT VARIABLES
var bullet_type: int = BulletTypes.BULLET_TYPE_DAMAGE \
		setget set_bullet_type
var bullet_color: int = BulletColors.BULLET_COLOR_WHITE \
		setget set_bullet_color

var on_hit_damage: int = 0 \
		setget set_on_hit_damage
var on_hit_heal: int = 0 \
		setget set_on_hit_heal
var on_hit_invincibility_frames: float = 900.0 \
		setget set_on_hit_invincibility_frames

var movement_speed: float = 0.0 \
		setget set_movement_speed
var movement_direction: Vector2 = Vector2.ZERO \
		setget set_movement_direction
var movement_rotation_degrees: float = 0.0 \
		setget set_movement_rotation_degrees
var movement_rotate_velocity: bool = false


# CLASS PUBLIC VARIABLES
var velocity: Vector2


# GODOT OVERRIDEN BUILT-IN VIRTUAL FUNCTIONS
func _ready() -> void:
	add_to_group("BattleEnemyBullets", true)


func _process(delta: float) -> void:
	_set_modulate()


func _physics_process(delta: float) -> void:
	_handle_movement(delta)


# CLASS PRIVATE METHODS
func _set_modulate() -> void:
	match bullet_color:
		BulletColors.BULLET_COLOR_WHITE:
			modulate = BULLET_COLOR_WHITE
		BulletColors.BULLET_COLOR_BLUE:
			modulate = BULLET_COLOR_BLUE
		BulletColors.BULLET_COLOR_ORANGE:
			modulate = BULLET_COLOR_ORANGE
		BulletColors.BULLET_COLOR_GREEN:
			modulate = BULLET_COLOR_GREEN
		BulletColors.BULLET_COLOR_GRAY:
			modulate = BULLET_COLOR_GRAY


func _handle_movement(delta: float) -> void:
	if not Engine.editor_hint:
		velocity = (movement_direction * movement_speed) * delta
		
		if movement_rotate_velocity:
			velocity = velocity.rotated(rotation)
		
		position += velocity
		rotation_degrees += movement_rotation_degrees * delta


# CLASS SETTER FUNCIONS
func set_bullet_type(value: int) -> void:
	bullet_type = value
	bullet_type = clamp(bullet_type, 0, BulletTypes.size() - 1) as int
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


func set_on_hit_invincibility_frames(value: float) -> void:
	on_hit_invincibility_frames = value
	on_hit_invincibility_frames = clamp(on_hit_invincibility_frames, 0.0, INF)


func set_movement_speed(value: float) -> void:
	movement_speed = value
	movement_speed = clamp(movement_speed, 0.0, INF)


func set_movement_direction(value: Vector2) -> void:
	movement_direction = value
	movement_direction.x = clamp(movement_direction.x, -INF, INF)
	movement_direction.y = clamp(movement_direction.y, -INF, INF)


func set_movement_rotation_degrees(value: float) -> void:
	movement_rotation_degrees = value
	movement_rotation_degrees = clamp(movement_rotation_degrees, -INF, INF)


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
				"name": "on_hit_invincibility_frames",
				"type": TYPE_REAL,
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
		"movement_direction": true,
		"movement_rotation_degrees": true,
		"movement_rotate_velocity": true,
	}
	
	if property_list.keys().has(property):
		return property_list.get(property)


func property_get_revert(property: String):
	var property_list: Dictionary = {
		"bullet_type": BulletTypes.BULLET_TYPE_DAMAGE,
		"bullet_color": BulletColors.BULLET_COLOR_WHITE,
		"on_hit_damage": 0,
		"on_hit_heal": 0,
		"on_hit_invincibility_frames": 900.0,
		"movement_speed": 0.0,
		"movement_direction": Vector2.ZERO,
		"movement_rotation_degrees": 0.0,
		"movement_rotate_velocity": false,
	}
	
	if property_list.keys().has(property):
		return property_list.get(property)
