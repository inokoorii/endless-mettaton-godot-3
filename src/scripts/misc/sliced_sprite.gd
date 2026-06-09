tool
class_name SlicedSprite
extends Node2D


# CLASS SIGNALS
signal texture_changed()


# CLASS EXPORT VARIABLES
var texture: Texture = null \
		setget set_texture
var normal_map: Texture = null \
		setget set_normal_map

var offset: Vector2 = Vector2.ZERO \
		setget set_offset
var flip_h: bool = false \
		setget set_flip_h
var flip_v: bool = false \
		setget set_flip_v

var spacing: Vector2 = Vector2.ZERO \
		setget set_spacing


# CLASS ONREADY VARIABLES
onready var top_left: Sprite = \
		get_node_or_null("TopLeft")
onready var top_right: Sprite = \
		get_node_or_null("TopRight")
onready var bottom_left: Sprite = \
		get_node_or_null("BottomLeft")
onready var bottom_right: Sprite = \
		get_node_or_null("BottomRight")


# GODOT OVERRIDEN BUILT-IN VIRTUAL FUNCTIONS
func _ready() -> void:
	_update_sprite_textures()
	_update_sprite_normal_maps()
	_update_sprite_offsets()
	_update_sprite_regions()
	_update_sprite_transforms()


# CLASS PRIVATE FUNCTIONS
func _update_sprite_textures() -> void:
	if is_instance_valid(top_left):
		top_left.texture = texture
	if is_instance_valid(top_right):
		top_right.texture = texture
	if is_instance_valid(bottom_left):
		bottom_left.texture = texture
	if is_instance_valid(bottom_right):
		bottom_right.texture = texture


func _update_sprite_normal_maps() -> void:
	if is_instance_valid(top_left):
		top_left.normal_map = normal_map
	if is_instance_valid(top_right):
		top_right.normal_map = normal_map
	if is_instance_valid(bottom_left):
		bottom_left.normal_map = normal_map
	if is_instance_valid(bottom_right):
		bottom_right.normal_map = normal_map


func _update_sprite_offsets() -> void:
	if is_instance_valid(top_left):
		top_left.offset = offset
		top_left.flip_h = flip_h
		top_left.flip_v = flip_v
	
	if is_instance_valid(top_right):
		top_right.offset = offset
		top_right.flip_h = flip_h
		top_right.flip_v = flip_v
	
	if is_instance_valid(bottom_left):
		bottom_left.offset = offset
		bottom_left.flip_h = flip_h
		bottom_left.flip_v = flip_v
	
	if is_instance_valid(bottom_right):
		bottom_right.offset = offset
		bottom_right.flip_h = flip_h
		bottom_right.flip_v = flip_v


func _update_sprite_regions() -> void:
	if not texture:
		if  is_instance_valid(top_left):
			top_left.region_rect.size = Vector2.ZERO
			top_left.region_rect.position = Vector2.ZERO
		
		if is_instance_valid(top_right):
			top_right.region_rect.size = Vector2.ZERO
			top_right.region_rect.position = Vector2.ZERO
		
		if is_instance_valid(bottom_left):
			bottom_left.region_rect.size = Vector2.ZERO
			bottom_left.region_rect.position = Vector2.ZERO
		
		if is_instance_valid(bottom_right):
			bottom_right.region_rect.size = Vector2.ZERO
			bottom_right.region_rect.position = Vector2.ZERO
		
	else:
		var texture_width: int = (texture.get_width() / 2.0) as int
		var texture_height: int = (texture.get_height() / 2.0) as int
		
		if is_instance_valid(top_left):
			top_left.region_rect.size = Vector2(texture_width, texture_height)
			top_left.region_rect.position = Vector2.ZERO
			
			if flip_h:
				top_left.region_rect.position.x = texture_width
			if flip_v:
				top_left.region_rect.position.y = texture_height
		
		if is_instance_valid(top_right):
			top_right.region_rect.size = Vector2(texture_width, texture_height)
			top_right.region_rect.position = Vector2(texture_width, 0.0)
			
			if flip_h:
				top_right.region_rect.position.x = 0
			if flip_v:
				top_right.region_rect.position.y = texture_height
		
		if is_instance_valid(bottom_left):
			bottom_left.region_rect.size = Vector2(texture_width, texture_height)
			bottom_left.region_rect.position = Vector2(0.0, texture_height)
			
			if flip_h:
				bottom_left.region_rect.position.x = texture_width
			if flip_v:
				bottom_left.region_rect.position.y = 0
		
		if is_instance_valid(bottom_right):
			bottom_right.region_rect.size = Vector2(texture_width, texture_height)
			bottom_right.region_rect.position = Vector2(texture_width, texture_height)
			
			if flip_h:
				bottom_right.region_rect.position.x = 0
			if flip_v:
				bottom_right.region_rect.position.y = 0


func _update_sprite_transforms() -> void:
	if not texture:
		if is_instance_valid(top_left):
			top_left.position = Vector2.ZERO
		if is_instance_valid(top_right):
			top_right.position = Vector2.ZERO
		if is_instance_valid(bottom_left):
			bottom_left.position = Vector2.ZERO
		if is_instance_valid(bottom_right):
			bottom_right.position = Vector2.ZERO
		
	else:
		var texture_width: float = texture.get_width() / 4.0
		var texture_height: float = texture.get_height() / 4.0
		
		if is_instance_valid(top_left):
			top_left.position = Vector2(ceil(-texture_width), ceil(-texture_height))
			top_left.position += Vector2(-spacing.x, -spacing.y)
		
		if is_instance_valid(top_right):
			top_right.position = Vector2(ceil(texture_width), ceil(-texture_height))
			top_right.position += Vector2(+spacing.x, -spacing.y)
		
		if is_instance_valid(bottom_left):
			bottom_left.position = Vector2(ceil(-texture_width), ceil(texture_height))
			bottom_left.position += Vector2(-spacing.x, +spacing.y)
		
		if is_instance_valid(bottom_right):
			bottom_right.position = Vector2(ceil(texture_width), ceil(texture_height))
			bottom_right.position += Vector2(+spacing.x, +spacing.y)


# CLASS SETTER FUNCTIONS
func set_texture(value: Texture) -> void:
	texture = value
	emit_signal("texture_changed")
	
	_update_sprite_textures()
	_update_sprite_regions()
	_update_sprite_transforms()


func set_normal_map(value: Texture) -> void:
	normal_map = value
	_update_sprite_normal_maps()


func set_offset(value: Vector2) -> void:
	offset = value
	_update_sprite_offsets()


func set_flip_h(value: bool) -> void:
	flip_h = value
	_update_sprite_offsets()
	_update_sprite_regions()


func set_flip_v(value: bool) -> void:
	flip_v = value
	_update_sprite_offsets()
	_update_sprite_regions()


func set_spacing(value: Vector2) -> void:
	spacing = value
	_update_sprite_transforms()


# CLASS PROPERTY LIST FUNCTIONS
func _get_property_list() -> Array:
	var property_list: Array = []

	property_list.append_array(
		[
			{
				"name": "SlicedSprite",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_CATEGORY,
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "texture",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "Texture",
			},
			{
				"name": "normal_map",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "Texture",
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "Offset",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
			},
			{
				"name": "offset",
				"type": TYPE_VECTOR2,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			{
				"name": "flip_h",
				"type": TYPE_BOOL,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			{
				"name": "flip_v",
				"type": TYPE_BOOL,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
		]
	)
	
	property_list.append_array(
		[
			{
				"name": "Spacing",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
			},
			{
				"name": "spacing",
				"type": TYPE_VECTOR2,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
		]
	)
	
	return property_list


func property_can_revert(property: String):
	var property_list: Dictionary = {
		"texture": true,
		"normal_map": true,
		"offset": true,
		"flip_h": true,
		"flip_v": true,
		"spacing": true,
	}
	
	if property_list.keys().has(property):
		return property_list.get(property)


func property_get_revert(property: String):
	var property_list: Dictionary = {
		"texture": null,
		"normal_map": null,
		"offset": Vector2.ZERO,
		"flip_h": false,
		"flip_v": false,
		"spacing": Vector2.ZERO,
	}
	
	if property_list.keys().has(property):
		return property_list.get(property)
