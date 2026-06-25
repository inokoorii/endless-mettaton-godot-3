tool
class_name BattleHeartBullet
extends Area2D


"CLASS EXPORTED VARIABLES"
var movement_speed: float = 480.0 \
	setget set_movement_speed
var movement_acceleration: float = 6.0 \
	setget set_movement_acceleration
var movement_direction: Vector2 = Vector2(0.0, -1.0)

var scale_growth: Vector2 = Vector2(0.0, 6.0)


"CLASS REGULAR VARIABLES"
var velocity: Vector2


"CLASS ONREADY VARIABLES"
onready var heart_bullet_sprite: AnimatedSprite = \
	get_node_or_null("HeartBulletSprite")
onready var heart_bullet_hitbox: CollisionShape2D = \
	get_node_or_null("HeartBulletHitbox")
onready var visibility_notifier_2d: VisibilityNotifier2D = \
	get_node_or_null("VisibilityNotifier2D")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("BattleHeartBullets", true)
	
	if is_instance_valid(visibility_notifier_2d):
		visibility_notifier_2d.connect("screen_exited", self, "_handle_node_cleanup")


func _physics_process(delta: float) -> void:
	_handle_bullet_movement(delta)
	_handle_bullet_animation(delta)


"CLASS PRIVATE METHODS"
func _handle_bullet_movement(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	movement_speed += movement_acceleration * delta
	velocity = (movement_direction * movement_speed) * delta
	position += velocity


func _handle_bullet_animation(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	scale += scale_growth * delta


func _handle_node_cleanup() -> void:
	queue_free()


"CLASS PUBLIC METHODS (PROPERTY SETTERS)"
func set_movement_speed(value: float) -> void:
	movement_speed = clamp(value, 0.0, INF)


func set_movement_acceleration(value: float) -> void:
	movement_acceleration = clamp(value, 0.0, INF)


"CLASS PRIVATE METHODS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array([
		{
			"name": "BattleHeartBullet",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY,
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
			"name": "movement_acceleration",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "movement_direction",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	])
	
	property_list.append_array([
		{
			"name": "Animation",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP,
		},
		{
			"name": "scale_growth",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	])
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list_reverts: Dictionary = {
		"movement_speed": 480.0,
		"movement_acceleration": 6.0,
		"movement_direction": Vector2(0.0, -1.0),
		"scale_growth": Vector2(0.0, 6.0),
	}
	
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
