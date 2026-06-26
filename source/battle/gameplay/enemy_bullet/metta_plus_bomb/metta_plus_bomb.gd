tool
extends BattleEnemyBullet


"SCRIPT SIGNALS"
signal bomb_shot


"SCRIPT EXPORTED VARIABLES"
var explosion_time: float = 0.2 \
	setget set_explosion_time # In seconds!


"SCRIPT REGULAR VARIABLES"
var explosion_time_left: float \
	setget set_explosion_time_left # ...also in seconds!

var shot: bool = false \
	setget set_shot


"SCRIPT ONREADY VARIABLES"
onready var bomb_sprite: AnimatedSprite = \
	get_node_or_null("BombSprite")
onready var bomb_hitbox: CollisionShape2D = \
	get_node_or_null("BombHitbox")
onready var heart_bullet_hurtbox: BattleHeartBulletHurtbox = \
	get_node_or_null("HeartBulletHurtbox")
onready var visibility_notifier_2d: VisibilityNotifier2D = \
	get_node_or_null("VisibilityNotifier2D")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("MettaPlusBombs", true)
	
	if is_instance_valid(bomb_sprite):
		bomb_sprite.connect("frame_changed", self, "_play_explosion_tick_sound")
	
	if is_instance_valid(heart_bullet_hurtbox):
		heart_bullet_hurtbox.connect("bullet_entered", self, "_handle_heart_bullet_collisions")
	
	if is_instance_valid(visibility_notifier_2d):
		visibility_notifier_2d.connect("screen_exited", self, "queue_free")


func _physics_process(delta: float) -> void:
	_handle_bomb_explosion(delta)


"SCRIPT PRIVATE METHODS"
func _handle_heart_bullet_collisions() -> void:
	if shot:
		return
	if is_instance_valid(bomb_sprite):
		bomb_sprite.playing = true
	
	explosion_time_left = explosion_time
	shot = true


func _handle_bomb_explosion(delta: float) -> void:
	if Engine.editor_hint:
		return
	if not shot:
		return
	
	set_explosion_time_left(explosion_time_left - delta)
	
	if explosion_time_left <= 0.0:
		var bomb_blast: BattleEnemyBullet = preload(str(
			"res://source/battle/gameplay/enemy_bullet/metta_plus_bomb_blast/",
			"metta_plus_bomb_blast.tscn"
		)).instance()
		
		get_parent().add_child(bomb_blast)
		bomb_blast.position = position
		queue_free()


func _play_explosion_tick_sound() -> void:
#	FIXME: Explosion tick SFX plays more frequently compared to its original counterpart.
	if not is_instance_valid(bomb_sprite):
		return
	if not bomb_sprite.frame == 1:
		return
	
	AudioManager.play_overlapping("assets/battle/sfx/sfx_bomb_explosion_tick.wav")


"SCRIPT PUBLIC METHODS (PROPERTY SETTERS)"
func set_explosion_time(value: float) -> void:
	explosion_time = clamp(value, 0.0, INF)


func set_explosion_time_left(value: float) -> void:
	explosion_time_left = clamp(value, 0.0, INF)


func set_shot(value: bool) -> void:
#	Setting the value of `shot` is a ONE-WAY change!
#	Once it has been set to `true`, you CAN NO LONGER change it back to `false`!
	if shot:
		return
	
	shot = value
	emit_signal("bomb_shot")


"SCRIPT PRIVATE METHODS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array([
		{
			"name": "MettaPlusBomb",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY,
		},
	])
	
	property_list.append_array([
		{
			"name": "explosion_time",
			"type": TYPE_REAL,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_EXP_RANGE,
			"hint_string": "0.0,4096.0,0.001,or_greater",
		},
	])
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list_reverts: Dictionary = {
		"explosion_time": 0.2,
	}
	
	property_list_reverts.merge(._get_property_list_reverts())
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
