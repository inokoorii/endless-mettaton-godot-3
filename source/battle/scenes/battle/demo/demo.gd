# TEMPORARY CODE!!! This'll be gone eventually...
extends Battle


"SCRIPT REGULAR VARIABLES"
var counter: int = 0


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_confirm"):
		if (
				not board.ideal_size_left == -50
				and not board.ideal_size_top == -200
				and not board.ideal_size_right == 50
		):
			board.ideal_size_left = -50
			board.ideal_size_top = -200
			board.ideal_size_right = 50
		else:
			board.ideal_size_left = -287
			board.ideal_size_top = -70
			board.ideal_size_right = 287
		
		counter += 1
		counter = wrapi(counter, 0, board.ResizeModes.size() - 1)
		board.resize_mode = counter
