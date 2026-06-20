tool
extends BattleEnemyBullet


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	add_to_group("MettaLegs", true)
