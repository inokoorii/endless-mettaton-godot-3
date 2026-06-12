tool
extends BattleEnemyBullet


"SCRIPT SIGNALS"
signal box_type_changed


"SCRIPT ENUMERATIONS"
enum BoxTypes {
	BOX_TYPE_HOLLOW,
	BOX_TYPE_SOLID,
}


"SCRIPT EXPORTED VARIABLES"
var box_type: int = BoxTypes.BOX_TYPE_HOLLOW \
		setget set_box_type

var sway_anim_speed: float = 0.0 \
		setget set_sway_anim_speed
var sway_anim_intensity: float = 0.0 \
		setget set_sway_anim_intensity


"SCRIPT ONREADY VARIABLES"
onready var box_sprite: SlicedSprite = \
		get_node_or_null("BoxSprite")
onready var box_hitbox: CollisionShape2D = \
		get_node_or_null("BoxHitbox")
onready var enemy_bullet_detector: BattleEnemyBulletDetector = \
		get_node_or_null("EnemyBulletDetector")
onready var heart_bullet_detector: BattlePlayerHeartBulletDetector = \
		get_node_or_null("HeartBulletDetector")
onready var visibility_notifier_2d: VisibilityNotifier2D = \
		get_node_or_null("VisibilityNotifier2D")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("MettaBoxes", true)
	_update_sprite_texture()
	
	if is_instance_valid(enemy_bullet_detector):
		enemy_bullet_detector.ignored_areas.append(self)


"SCRIPT PRIVATE METHODS"
func _update_sprite_texture() -> void:
	if is_instance_valid(box_sprite):
		match box_type:
			BoxTypes.BOX_TYPE_HOLLOW:
				box_sprite.texture = preload(
						"res://assets/sprites/battle/enemy_bullets/metta_box/metta_box_hollow.png")
			
			BoxTypes.BOX_TYPE_SOLID:
				box_sprite.texture = preload(
						"res://assets/sprites/battle/enemy_bullets/metta_box/metta_box_solid.png")


"SCRIPT PUBLIC METHODS (SETTERS)"
func set_box_type(value: int) -> void:
	box_type = value
	box_type = clamp(box_type, 0, BoxTypes.size() - 1) as int
	emit_signal("box_type_changed")
	_update_sprite_texture()


func set_sway_anim_speed(value: float) -> void:
	sway_anim_speed = value
	sway_anim_speed = clamp(sway_anim_speed, 0.0, INF)


func set_sway_anim_intensity(value: float) -> void:
	sway_anim_intensity = value
	sway_anim_intensity = clamp(sway_anim_intensity, 0.0, INF)


"SCRIPT PRIVATE FUNCTIONS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array(
		[
			{
				"name": "MettaBox",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_CATEGORY,
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "box_type",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Hollow,Solid",
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "Sway Animation",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
				"hint_string": "sway_anim",
			},
			{
				"name": "sway_anim_speed",
				"type": TYPE_REAL,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			{
				"name": "sway_anim_intensity",
				"type": TYPE_REAL,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
		]
	)
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list: Dictionary = {
		"box_type": BoxTypes.BOX_TYPE_HOLLOW,
		"sway_anim_speed": 0.0,
		"sway_anim_intensity": 0.0,
	}
	
	property_list.merge(._get_property_list_reverts())
	return property_list


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
