# This script has temporary code!
extends Battle


"SCRIPT REGULAR VARIABLES"
var trigger_shot: bool = false


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _physics_process(delta: float) -> void:
	if not trigger_shot:
		board.rotation_degrees += 15.0 * delta
		board.resize_speed = 240.0
		board.ideal_size_left = 35
		board.ideal_size_top = 35
		board.ideal_size_right = 35
		board.ideal_size_bottom = 35
		
	else:
		board.rotation_degrees = lerp(board.rotation_degrees, 0.0, delta * 7.5)
		board.resize_speed = 480.0
		board.ideal_size_left = 287
		board.ideal_size_top = 70
		board.ideal_size_right = 287
		board.ideal_size_bottom = 70


func _on_trigger_bullet_entered() -> void:
	trigger_shot = true
	
	for box in get_tree().get_nodes_in_group("MettaBoxes"):
		if box.box_type == 0: # BoxTypes.BOX_TYPE_HOLLOW
			box.destroyed = true
	
	for plus_bomb in get_tree().get_nodes_in_group("MettaPlusBombs"):
		plus_bomb.shot = true
