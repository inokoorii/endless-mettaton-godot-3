tool
extends BattleEnemyBullet


# SCRIPT SIGNALS
signal box_type_changed


# SCRIPT ENUMERATIONS
enum BoxTypes {
	BOX_TYPE_HOLLOW,
	BOX_TYPE_SOLID,
}


# SCRIPT EXPORT VARIABLES
var box_type: int = BoxTypes.BOX_TYPE_HOLLOW \
		setget set_box_type


# SCRIPT ONREADY VARIABLES
onready var box_sprite: SlicedSprite = \
		get_node_or_null("BoxSprite")
onready var heart_bullet_detector: BattlePlayerHeartBulletDetector = \
		get_node_or_null("HeartBulletDetector")
onready var visibility_notifier_2d: VisibilityNotifier2D = \
		get_node_or_null("VisibilityNotifier2D")


# GODOT OVERRIDEN BUILT-IN VIRTUAL FUNCTIONS
func _ready() -> void:
	add_to_group("MettaBoxes", true)
	_update_sprite_texture()


# SCRIPT PRIVATE FUNCTIONS
func _update_sprite_texture() -> void:
	if is_instance_valid(box_sprite):
		var texture: StreamTexture
		
		match box_type:
			BoxTypes.BOX_TYPE_HOLLOW:
				texture = preload(
						"res://assets/sprites/battle/enemy_bullets/metta_box/metta_box_hollow.png")
			
			BoxTypes.BOX_TYPE_SOLID:
				texture = preload(
						"res://assets/sprites/battle/enemy_bullets/metta_box/metta_box_solid.png")
		
		box_sprite.texture = texture


# SCRIPT SETTER FUNCTIONS
func set_box_type(value: int) -> void:
	box_type = value
	box_type = clamp(box_type, 0, BoxTypes.size() - 1) as int
	emit_signal("box_type_changed")
	_update_sprite_texture()


# SCRIPT PROPERTY LIST FUNCTIONS
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
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list: Dictionary = {
		"box_type": BoxTypes.BOX_TYPE_HOLLOW,
	}
	
	property_list.merge(._get_property_list_reverts())
	return property_list


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
