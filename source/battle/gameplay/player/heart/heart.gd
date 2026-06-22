tool
class_name BattleHeart
extends KinematicBody2D


"CLASS SIGNALS"
signal bullet_fired(bullet)


"CLASS EXPORTED VARIABLES"
var movement_speed: float = 120.0 \
		setget set_movement_speed

var bullet_firing_cooldown_time: float = 0.5 \
		setget set_bullet_firing_cooldown_time # In seconds!
var bullet_firing_offset: Vector2 = Vector2(0.0, -16.0)


"CLASS REGULAR VARIABLES"
var bullet_firing_cooldown_time_left: float \
		setget set_bullet_firing_cooldown_time_left # ...also in seconds!

var velocity: Vector2


"CLASS ONREADY VARIABLES"
onready var heart_sprite: AnimatedSprite = \
		get_node_or_null("HeartSprite")
onready var enemy_bullet_hurtbox: BattleEnemyBulletHurtbox = \
		get_node_or_null("EnemyBulletHurtbox")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("BattleHearts", true)
	
	if is_instance_valid(enemy_bullet_hurtbox):
		enemy_bullet_hurtbox.connect("bullet_entered_processed", self, "_handle_enemy_bullet_collisions")


func _process(delta: float) -> void:
	_update_heart_sprite_playing()


func _physics_process(delta: float) -> void:
	_handle_heart_movement(delta)
	_handle_heart_bullet_firing(delta)


"CLASS PUBLIC METHODS"
func can_fire_bullet() -> bool:
	var cooldown_finished: bool = bullet_firing_cooldown_time_left <= 0.0
	var no_active_bullets: bool = get_tree().get_nodes_in_group("BattleHeartBullets").empty()
	
	return cooldown_finished or no_active_bullets


"CLASS PRIVATE METHODS"
func _handle_heart_movement(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	velocity = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down"))
	
	if Input.is_action_pressed("action_cancel"):
		velocity /= 2.0
	
	velocity *= movement_speed
	move_and_slide(velocity, Vector2.UP)


func _handle_heart_bullet_firing(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	set_bullet_firing_cooldown_time_left(bullet_firing_cooldown_time_left - delta)
	
	if can_fire_bullet() and Input.is_action_just_pressed("action_confirm"):
		var bullet: BattleHeartBullet = preload(str(
				"res://source/battle/gameplay/player_bullet/heart_bullet/",
				"heart_bullet.tscn")).instance()
		
		get_parent().add_child(bullet)
		bullet.position = position + bullet_firing_offset
		
		bullet_firing_cooldown_time_left = bullet_firing_cooldown_time
		emit_signal("bullet_fired", bullet)


func _handle_enemy_bullet_collisions(bullet: BattleEnemyBullet, bullet_type: int) -> void:
	var BULLET_TYPE_DAMAGE: int = \
			BattleEnemyBullet.BulletTypes.BULLET_TYPE_DAMAGE
	var BULLET_TYPE_DAMAGE_ON_IDLE: int = \
			BattleEnemyBullet.BulletTypes.BULLET_TYPE_DAMAGE_ON_IDLE
	var BULLET_TYPE_DAMAGE_ON_MOVE: int = \
			BattleEnemyBullet.BulletTypes.BULLET_TYPE_DAMAGE_ON_MOVE
	var BULLET_TYPE_HEAL: int = \
			BattleEnemyBullet.BulletTypes.BULLET_TYPE_HEAL
	
	match bullet_type:
		BULLET_TYPE_DAMAGE, BULLET_TYPE_DAMAGE_ON_IDLE, BULLET_TYPE_DAMAGE_ON_MOVE:
			BattleGlobals.health -= bullet.on_hit_damage
		
		BULLET_TYPE_HEAL:
			BattleGlobals.health += bullet.on_hit_heal
			bullet.queue_free() # I'm unsure if I want to destroy the bullets here...


func _update_heart_sprite_playing() -> void:
	if Engine.editor_hint:
		return
	if not is_instance_valid(enemy_bullet_hurtbox):
		return
	if not is_instance_valid(heart_sprite):
		return
	
	heart_sprite.playing = enemy_bullet_hurtbox.is_invincible()
	
	if not enemy_bullet_hurtbox.is_invincible():
		heart_sprite.frame = 0


"CLASS PUBLIC METHODS (PROPERTY SETTERS)"
func set_movement_speed(value: float) -> void:
	movement_speed = value
	movement_speed = clamp(movement_speed, 0.0, INF)


func set_bullet_firing_cooldown_time(value: float) -> void:
	bullet_firing_cooldown_time = value
	bullet_firing_cooldown_time = clamp(bullet_firing_cooldown_time, 0.0, INF)


func set_bullet_firing_cooldown_time_left(value: float) -> void:
	bullet_firing_cooldown_time_left = value
	bullet_firing_cooldown_time_left = clamp(bullet_firing_cooldown_time_left, 0.0, INF)


"CLASS PRIVATE METHODS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array([
		{
			"name": "BattleHeart",
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
	
	property_list.append_array([
		{
			"name": "Bullet Firing",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "bullet_firing",
		},
		{
			"name": "bullet_firing_cooldown_time",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_EXP_RANGE,
			"hint_string": "0.0,4096.0,0.001,or_greater",
		},
		{
			"name": "bullet_firing_offset",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	])
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list_reverts: Dictionary = {
		"movement_speed": 120.0,
		"bullet_firing_cooldown_time": 0.5,
		"bullet_firing_offset": Vector2(0.0, -16.0),
	}
	
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
