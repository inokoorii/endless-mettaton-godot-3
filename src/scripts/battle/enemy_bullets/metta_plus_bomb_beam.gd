tool
extends BattleEnemyBullet


"SCRIPT ONREADY VARIABLES"
onready var beam_sprite_center: AnimatedSprite = \
		get_node_or_null("BeamSprites/Center")
onready var beam_sprite_horizontal_left: TextureRect = \
		get_node_or_null("BeamSprites/HorizontalLeft")
onready var beam_sprite_horizontal_right: TextureRect = \
		get_node_or_null("BeamSprites/HorizontalRight")
onready var beam_sprite_vertical_top: TextureRect = \
		get_node_or_null("BeamSprites/VerticalTop")
onready var beam_sprite_vertical_bottom: TextureRect = \
		get_node_or_null("BeamSprites/VerticalBottom")
onready var beam_hitbox_horizontal: CollisionShape2D = \
		get_node_or_null("BeamHitboxHorizontal")
onready var beam_hitbox_vertical: CollisionShape2D = \
		get_node_or_null("BeamHitboxVertical")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("MettaPlusBombBeams", true)
	
	if is_instance_valid(beam_sprite_center):
		beam_sprite_center.connect("animation_finished", self, "_handle_cleanup")
		
		if not Engine.editor_hint:
			beam_sprite_center.play("beam_center")


func _physics_process(delta: float) -> void:
	_update_sprite_textures()
	_update_hitboxes_disabled()


"SCRIPT PRIVATE METHODS"
func _update_sprite_textures() -> void:
	if is_instance_valid(beam_sprite_center):
		var beam_texture: StreamTexture = load(
				"res://assets/sprites/battle/enemy_bullets/metta_plus_bomb_beam/"
				+ "metta_plus_bomb_beam_%s.png" % beam_sprite_center.frame)
		
		if is_instance_valid(beam_sprite_horizontal_left):
			beam_sprite_horizontal_left.texture = beam_texture
		
		if is_instance_valid(beam_sprite_horizontal_right):
			beam_sprite_horizontal_right.texture = beam_texture
		
		if is_instance_valid(beam_sprite_vertical_top):
			beam_sprite_vertical_top.texture = beam_texture
		
		if is_instance_valid(beam_sprite_vertical_bottom):
			beam_sprite_vertical_bottom.texture = beam_texture


func _update_hitboxes_disabled() -> void:
	if is_instance_valid(beam_sprite_center):
		var disabled: bool = beam_sprite_center.frame != 2
		
		if is_instance_valid(beam_hitbox_horizontal):
			beam_hitbox_horizontal.disabled = disabled
		
		if is_instance_valid(beam_hitbox_vertical):
			beam_hitbox_vertical.disabled = disabled


func _handle_cleanup() -> void:
	if not Engine.editor_hint:
		queue_free()
