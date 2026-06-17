tool
extends BattleEnemyBullet


"SCRIPT ONREADY VARIABLES"
onready var blast_sprite_center: AnimatedSprite = \
		get_node_or_null("BlastSprites/Center")
onready var blast_sprite_horizontal_left: TextureRect = \
		get_node_or_null("BlastSprites/HorizontalLeft")
onready var blast_sprite_horizontal_right: TextureRect = \
		get_node_or_null("BlastSprites/HorizontalRight")
onready var blast_sprite_vertical_top: TextureRect = \
		get_node_or_null("BlastSprites/VerticalTop")
onready var blast_sprite_vertical_bottom: TextureRect = \
		get_node_or_null("BlastSprites/VerticalBottom")

onready var blast_hitbox_horizontal: CollisionShape2D = \
		get_node_or_null("BlastHitboxHorizontal")
onready var blast_hitbox_vertical: CollisionShape2D = \
		get_node_or_null("BlastHitboxVertical")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("MettaPlusBombBlasts", true)
	
	if is_instance_valid(blast_sprite_center):
		blast_sprite_center.connect("frame_changed", self, "_update_sprite_textures")
		blast_sprite_center.connect("animation_finished", self, "_handle_cleanup")
		
		if not Engine.editor_hint:
			blast_sprite_center.play("blast_center")


func _physics_process(delta: float) -> void:
	_update_hitboxes_disabled()


"SCRIPT PRIVATE METHODS"
func _update_sprite_textures() -> void:
	if is_instance_valid(blast_sprite_center):
		var texture: StreamTexture = load(str(
				"res://battle/assets/enemy_bullets/metta_plus_bomb_blast/",
				"spr_metta_plus_bomb_blast_%s.png" % blast_sprite_center.frame))
		
		if is_instance_valid(blast_sprite_horizontal_left):
			blast_sprite_horizontal_left.texture = texture
		
		if is_instance_valid(blast_sprite_horizontal_right):
			blast_sprite_horizontal_right.texture = texture
		
		if is_instance_valid(blast_sprite_vertical_top):
			blast_sprite_vertical_top.texture = texture
		
		if is_instance_valid(blast_sprite_vertical_bottom):
			blast_sprite_vertical_bottom.texture = texture


func _update_hitboxes_disabled() -> void:
	if is_instance_valid(blast_sprite_center):
		var disabled: bool = blast_sprite_center.frame != 2
		
		if is_instance_valid(blast_hitbox_horizontal):
			blast_hitbox_horizontal.disabled = disabled
		
		if is_instance_valid(blast_hitbox_vertical):
			blast_hitbox_vertical.disabled = disabled


func _handle_cleanup() -> void:
	if not Engine.editor_hint:
		queue_free()
