tool
extends Node2D


# SCRIPT EXPORT VARIABLES
var movement_speed: float = 540.0 \
		setget set_movement_speed


# SCRIPT PUBLIC VARIABLES
var movement_direction: Vector2
var movement_rotation: float

var velocity: Vector2


# SCRIPT ONREADY VARIABLES
onready var heart_bullet_sprite: AnimatedSprite = \
		get_node_or_null("HeartBulletSprite")
onready var visibility_notifier_2d: VisibilityNotifier2D = \
		get_node_or_null("VisibilityNotifier2D")


# GODOT OVERRIDEN BUILT-IN VIRTUAL FUNCTIONS
func _ready() -> void:
	add_to_group("BattlePlayerHeartBulletDeflecteds", true)
	_setup_movement_direction()
	_setup_movement_rotation()
	
	if is_instance_valid(visibility_notifier_2d):
		visibility_notifier_2d.connect("screen_exited", self, "_handle_cleanup")
	
	if is_instance_valid(heart_bullet_sprite) and not Engine.editor_hint:
		heart_bullet_sprite.play("default")


func _physics_process(delta: float) -> void:
	_handle_movement(delta)


# SCRIPT PRIVATE FUNCTIONS
func _setup_movement_direction() -> void:
	if not Engine.editor_hint:
		var angle_left: float = -30.0 - rand_range(0.0, 40.0)
		var angle_right: float = 30.0 + rand_range(0.0, 40.0)
		
		movement_direction = Vector2.DOWN.rotated(
				deg2rad([angle_left, angle_right].pick_random()))


func _setup_movement_rotation() -> void:
	if not Engine.editor_hint:
		var angle_base: float = 90.0
		var angle_offset: float = rand_range(0.0, 180.0)
		var rotation_direction: int = [1, -1].pick_random()
		
		movement_rotation = angle_base + (angle_offset * rotation_direction)


func _handle_movement(delta: float) -> void:
	if not Engine.editor_hint:
		velocity = (movement_direction * movement_speed) * delta
		
		position += velocity
		rotation_degrees += movement_rotation * delta


func _handle_cleanup() -> void:
	queue_free()


# SCRIPT SETTER FUNCTIONS
func set_movement_speed(value: float) -> void:
	movement_speed = value
	movement_speed = clamp(movement_speed, 0.0, INF)


# SCRIPT PROPERTY LIST FUNCTIONS
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array(
		[
			{
				"name": "BattlePlayerHeartBulletDeflected",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_CATEGORY,
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "movement_speed",
				"type": TYPE_REAL,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
		]
	)
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list: Dictionary = {
		"movement_speed": 540.0,
	}
	
	return property_list


func property_can_revert(property: String):
	var property_list: Dictionary = _get_property_list_reverts()
	return property_list.has(property)


func property_get_revert(property: String):
	var property_list: Dictionary = _get_property_list_reverts()
	return property_list.get(property)
