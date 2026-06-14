# TODO: Refactor/clean this up at some point.
tool
class_name SlicedSprite
extends Node2D


"CLASS SIGNALS"
signal texture_changed()


"CLASS EXPORTED VARIABLES"
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

var h_separation: float = 0.0 \
		setget set_h_separation
var v_separation: float = 0.0 \
		setget set_v_separation


"CLASS ONREADY VARIABLES"
onready var top_left: Sprite = \
		get_node_or_null("TopLeft")
onready var top_right: Sprite = \
		get_node_or_null("TopRight")
onready var bottom_left: Sprite = \
		get_node_or_null("BottomLeft")
onready var bottom_right: Sprite = \
		get_node_or_null("BottomRight")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	_update_sprite_textures()
	_update_sprite_normal_maps()
	_update_sprite_offsets()
	_update_sprite_region_rects()
	_update_sprite_positions()


"CLASS PRIVATE METHODS"
func _update_sprite_textures() -> void:
	for sprite in [top_left, top_right, bottom_left, bottom_right]:
		if is_instance_valid(sprite):
			sprite.texture = texture


func _update_sprite_normal_maps() -> void:
	for sprite in [top_left, top_right, bottom_left, bottom_right]:
		if is_instance_valid(sprite):
			sprite.normal_map = normal_map


func _update_sprite_offsets() -> void:
	for sprite in [top_left, top_right, bottom_left, bottom_right]:
		if is_instance_valid(sprite):
			sprite.offset = offset
			sprite.flip_h = flip_h
			sprite.flip_v = flip_v


func _update_sprite_region_rects() -> void:
	if not texture:
		for sprite in [top_left, top_right, bottom_left, bottom_right]:
			if is_instance_valid(sprite):
				sprite.region_rect.size = Vector2.ZERO
				sprite.region_rect.position = Vector2.ZERO
		
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
				top_right.region_rect.position.x = 0.0
			if flip_v:
				top_right.region_rect.position.y = texture_height
		
		if is_instance_valid(bottom_left):
			bottom_left.region_rect.size = Vector2(texture_width, texture_height)
			bottom_left.region_rect.position = Vector2(0.0, texture_height)
			
			if flip_h:
				bottom_left.region_rect.position.x = texture_width
			if flip_v:
				bottom_left.region_rect.position.y = 0.0
		
		if is_instance_valid(bottom_right):
			bottom_right.region_rect.size = Vector2(texture_width, texture_height)
			bottom_right.region_rect.position = Vector2(texture_width, texture_height)
			
			if flip_h:
				bottom_right.region_rect.position.x = 0.0
			if flip_v:
				bottom_right.region_rect.position.y = 0.0


func _update_sprite_positions() -> void:
	if not texture:
		for sprite in [top_left, top_right, bottom_left, bottom_right]:
			if is_instance_valid(sprite):
				sprite.position = Vector2.ZERO
		
	else:
		var texture_width: float = texture.get_width() / 4.0
		var texture_height: float = texture.get_height() / 4.0
		
		if is_instance_valid(top_left):
			top_left.position = Vector2(
					ceil(-texture_width) - h_separation,
					ceil(-texture_height) - v_separation)
		
		if is_instance_valid(top_right):
			top_right.position = Vector2(
					ceil(texture_width) + h_separation,
					ceil(-texture_height) - v_separation)
		
		if is_instance_valid(bottom_left):
			bottom_left.position = Vector2(
					ceil(-texture_width) - h_separation,
					ceil(texture_height) + v_separation)
		
		if is_instance_valid(bottom_right):
			bottom_right.position = Vector2(
					ceil(texture_width) + h_separation,
					ceil(texture_height) + v_separation)


"CLASS PUBLIC METHODS (SETTERS)"
func set_texture(value: Texture) -> void:
	texture = value
	emit_signal("texture_changed")
	_update_sprite_textures()
	_update_sprite_region_rects()
	_update_sprite_positions()


func set_normal_map(value: Texture) -> void:
	normal_map = value
	_update_sprite_normal_maps()


func set_offset(value: Vector2) -> void:
	offset = value
	_update_sprite_offsets()


func set_flip_h(value: bool) -> void:
	flip_h = value
	_update_sprite_offsets()
	_update_sprite_region_rects()


func set_flip_v(value: bool) -> void:
	flip_v = value
	_update_sprite_offsets()
	_update_sprite_region_rects()


func set_h_separation(value: float) -> void:
	h_separation = value
	_update_sprite_positions()


func set_v_separation(value: float) -> void:
	v_separation = value
	_update_sprite_positions()


"CLASS PRIVATE METHODS (PROPERTY LIST)"
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
				"name": "Separation",
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
			},
			{
				"name": "h_separation",
				"type": TYPE_REAL,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			{
				"name": "v_separation",
				"type": TYPE_REAL,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
		]
	)
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list: Dictionary = {
		"texture": null,
		"normal_map": null,
		"offset": Vector2.ZERO,
		"flip_h": false,
		"flip_v": false,
		"h_separation": 0.0,
		"v_separation": 0.0,
	}
	
	return property_list


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
