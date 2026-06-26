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
		blast_sprite_center.connect("frame_changed", self, "_update_blast_sprite_textures")
		
		if Engine.editor_hint:
			return
		
		blast_sprite_center.connect("animation_finished", self, "queue_free")
		blast_sprite_center.play("blast_center")
	
	AudioManager.play_overlapping("assets/battle/sfx/sfx_bomb_explosion.wav")


func _physics_process(delta: float) -> void:
	_update_blast_hitboxes_disabled()


"SCRIPT PRIVATE METHODS"
func _update_blast_sprite_textures() -> void:
	if not is_instance_valid(blast_sprite_center):
		return
	
	var blast_texture: StreamTexture = load(str(
		"res://assets/battle/sprites/enemy_bullet/metta_plus_bomb_blast/",
		"spr_metta_plus_bomb_blast_%s.png" % blast_sprite_center.frame
	))
	
	if is_instance_valid(blast_sprite_horizontal_left):
		blast_sprite_horizontal_left.texture = blast_texture
		
	if is_instance_valid(blast_sprite_horizontal_right):
		blast_sprite_horizontal_right.texture = blast_texture
	
	if is_instance_valid(blast_sprite_vertical_top):
		blast_sprite_vertical_top.texture = blast_texture
	
	if is_instance_valid(blast_sprite_vertical_bottom):
		blast_sprite_vertical_bottom.texture = blast_texture


func _update_blast_hitboxes_disabled() -> void:
	if not is_instance_valid(blast_sprite_center):
		return
	
	var is_damage_frame: bool = blast_sprite_center.frame != 2
	
	if is_instance_valid(blast_hitbox_horizontal):
		blast_hitbox_horizontal.disabled = is_damage_frame
	
	if is_instance_valid(blast_hitbox_vertical):
		blast_hitbox_vertical.disabled = is_damage_frame


func _play_explosion_sound() -> void:
	if Engine.editor_hint:
		return
