tool
extends Node2D


"SCRIPT EXPORTED VARIABLES"
var movement_speed: float = 540.0 \
		setget set_movement_speed


"SCRIPT REGULAR VARIABLES"
var movement_direction: Vector2
var movement_rotation: float

var velocity: Vector2


"SCRIPT ONREADY VARIABLES"
onready var heart_bullet_sprite: AnimatedSprite = \
		get_node_or_null("HeartBulletSprite")
onready var visibility_notifier_2d: VisibilityNotifier2D = \
		get_node_or_null("VisibilityNotifier2D")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("BattleHeartBulletDeflecteds", true)
	_set_movement_direction()
	_set_movement_rotation()
	
	if is_instance_valid(visibility_notifier_2d):
		visibility_notifier_2d.connect("screen_exited", self, "_handle_node_cleanup")
	
	if not Engine.editor_hint and is_instance_valid(heart_bullet_sprite):
		heart_bullet_sprite.play("default")


func _physics_process(delta: float) -> void:
	_handle_bullet_movement(delta)


"SCRIPT PRIVATE METHODS"
func _set_movement_direction() -> void:
	if Engine.editor_hint:
		return
	
	var angle_left: float = -30.0 - rand_range(0.0, 40.0)
	var angle_right: float = 30.0 + rand_range(0.0, 40.0)
	var angle_chosen: float = deg2rad([angle_left, angle_right].pick_random())
	
	movement_direction = Vector2.DOWN.rotated(angle_chosen)


func _set_movement_rotation() -> void:
	if Engine.editor_hint:
		return
	
	var angle_base: float = 90.0
	var angle_offset: float = rand_range(0.0, 180.0)
	var rotation_direction: int = [1, -1].pick_random()
	
	movement_rotation = angle_base + (angle_offset * rotation_direction)


func _handle_bullet_movement(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	velocity = (movement_direction * movement_speed) * delta
	position += velocity
	rotation_degrees += movement_rotation * delta


func _handle_node_cleanup() -> void:
	queue_free()


"SCRIPT PUBLIC METHODS (SETTERS)"
func set_movement_speed(value: float) -> void:
	movement_speed = value
	movement_speed = clamp(movement_speed, 0.0, INF)


"SCRIPT PRIVATE METHODS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array([
		{
			"name": "BattleHeartBulletDeflected",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY,
		},
	])
	
	property_list.append_array([
		{
			"name": "movement_speed",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	])
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list_reverts: Dictionary = {
		"movement_speed": 540.0,
	}
	
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
