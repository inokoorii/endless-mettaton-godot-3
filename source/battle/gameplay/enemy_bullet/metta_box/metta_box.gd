tool
extends BattleEnemyBullet


"SCRIPT SIGNALS"
signal box_type_changed
signal box_destroyed


"SCRIPT ENUMERATIONS"
enum BoxTypes {
	BOX_TYPE_HOLLOW,
	BOX_TYPE_SOLID,
}


"SCRIPT EXPORTED VARIABLES"
var box_type: int = BoxTypes.BOX_TYPE_HOLLOW \
		setget set_box_type

var sway_speed: float = 0.0 \
		setget set_sway_speed
var sway_intensity: float = 0.0

var break_speed: float = 30.0 \
		setget set_break_speed
var break_fade_speed: float = 1.25 \
		setget set_break_fade_speed


"SCRIPT REGULAR VARIABLES"
var destroyed: bool = false \
		setget set_destroyed

var _sway_elapsed_time: float # In seconds!
var _sway_x_offset: float


"SCRIPT ONREADY VARIABLES"
onready var box_sprite: SlicedSprite = \
		get_node_or_null("BoxSprite")
onready var box_hitbox: CollisionShape2D = \
		get_node_or_null("BoxHitbox")
onready var enemy_bullet_hurtbox: BattleEnemyBulletHurtbox = \
		get_node_or_null("EnemyBulletHurtbox")
onready var heart_bullet_hurtbox: BattleHeartBulletHurtbox = \
		get_node_or_null("HeartBulletHurtbox")
onready var visibility_notifier_2d: VisibilityNotifier2D = \
		get_node_or_null("VisibilityNotifier2D")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("MettaBoxes", true)
	_update_box_sprite_texture()
	
	if is_instance_valid(enemy_bullet_hurtbox):
		enemy_bullet_hurtbox.connect("bullet_entered", self, "_handle_enemy_bullet_collisions")
		enemy_bullet_hurtbox.ignored_areas.append(self)
	
	if is_instance_valid(heart_bullet_hurtbox):
		heart_bullet_hurtbox.connect("bullet_entered", self, "_handle_heart_bullet_collisions")
	
	if is_instance_valid(visibility_notifier_2d):
		visibility_notifier_2d.connect("screen_exited", self, "_handle_node_cleanup")


func _physics_process(delta: float) -> void:
	_handle_box_sway_animation(delta)
	_handle_box_break_animation(delta)


"SCRIPT PRIVATE METHODS"
func _update_box_sprite_texture() -> void:
	if not is_instance_valid(box_sprite):
		return
	
	match box_type:
		BoxTypes.BOX_TYPE_HOLLOW:
			box_sprite.texture = preload(str(
					"res://assets/battle/sprites/enemy_bullet/metta_box/",
					"spr_metta_box_hollow.png"))
		
		BoxTypes.BOX_TYPE_SOLID:
				box_sprite.texture = preload(str(
						"res://assets/battle/sprites/enemy_bullet/metta_box/",
						"spr_metta_box_solid.png"))


func _handle_box_sway_animation(delta: float) -> void:
	if Engine.editor_hint:
		return
	if destroyed:
		return
	
	_sway_elapsed_time += delta
	_sway_x_offset = sin(_sway_elapsed_time * sway_speed) * sway_intensity
	
	if is_instance_valid(box_sprite):
		box_sprite.position.x = _sway_x_offset
	
	if is_instance_valid(box_hitbox):
		box_hitbox.position.x = _sway_x_offset
	
	if is_instance_valid(enemy_bullet_hurtbox):
		enemy_bullet_hurtbox.position.x = _sway_x_offset
	
	if is_instance_valid(heart_bullet_hurtbox):
		heart_bullet_hurtbox.position.x = _sway_x_offset
	
	if is_instance_valid(visibility_notifier_2d):
		visibility_notifier_2d.position.x = _sway_x_offset


func _handle_box_break_animation(delta: float) -> void:
	if Engine.editor_hint:
		return
	if not destroyed:
		return
	
	match box_type:
		BoxTypes.BOX_TYPE_HOLLOW:
			modulate.a -= break_fade_speed * delta
			modulate.a = clamp(modulate.a, 0.0, 0.8)
			
			if is_instance_valid(box_sprite):
				box_sprite.h_separation += break_speed * delta
				box_sprite.v_separation += break_speed * delta
			
			if modulate.a <= 0.0:
				queue_free()
	
		BoxTypes.BOX_TYPE_SOLID:
			queue_free()


func _handle_enemy_bullet_collisions(bullet: BattleEnemyBullet, bullet_type: int) -> void:
	if destroyed:
		return
	if not box_type == BoxTypes.BOX_TYPE_SOLID:
		return
	if not bullet.is_in_group("MettaPlusBombBlasts"):
		return
	
	destroyed = true


func _handle_heart_bullet_collisions() -> void:
	if destroyed:
		return
	if not box_type == BoxTypes.BOX_TYPE_HOLLOW:
		return
	
	movement_speed = 0.0
	movement_direction = Vector2.ZERO
	movement_rotation_degrees = 0.0
	movement_rotate_velocity = false
	
	if is_instance_valid(box_hitbox):
		box_hitbox.queue_free()
	
	if is_instance_valid(enemy_bullet_hurtbox):
		enemy_bullet_hurtbox.queue_free()
	
	if is_instance_valid(heart_bullet_hurtbox):
		heart_bullet_hurtbox.queue_free()
	
	destroyed = true


func _handle_node_cleanup() -> void:
	queue_free()


"SCRIPT PUBLIC METHODS (SETTERS)"
func set_box_type(value: int) -> void:
	box_type = value
	box_type = clamp(box_type, 0, BoxTypes.size() - 1) as int
	emit_signal("box_type_changed")
	_update_box_sprite_texture()


func set_destroyed(value: bool) -> void:
#	Setting the value of `destroyed` is a ONE-WAY change!
#	Once it has been set to `true`, you CAN NO LONGER change it back to `false`!
	if destroyed:
		return
	
	destroyed = value
	emit_signal("box_destroyed")


func set_sway_speed(value: float) -> void:
	sway_speed = value
	sway_speed = clamp(sway_speed, 0.0, INF)


func set_break_speed(value: float) -> void:
	break_speed = value
	break_speed = clamp(break_speed, 0.0, INF)


func set_break_fade_speed(value: float) -> void:
	break_fade_speed = value
	break_fade_speed = clamp(break_fade_speed, 0.0, INF)


"SCRIPT PRIVATE FUNCTIONS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array([
		{
			"name": "MettaBox",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY,
		},
	])
	
	property_list.append_array([
		{
			"name": "box_type",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Hollow,Solid",
		},
	])
	
	property_list.append_array([
		{
			"name": "Animation",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP,
		},
		{
			"name": "sway_speed",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "sway_intensity",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "break_speed",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "break_fade_speed",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	])
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list_reverts: Dictionary = {
		"box_type": BoxTypes.BOX_TYPE_HOLLOW,
		"sway_speed": 0.0,
		"sway_intensity": 0.0,
		"break_speed": 30.0,
		"break_fade_speed": 1.25,
	}
	
	property_list_reverts.merge(._get_property_list_reverts())
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
