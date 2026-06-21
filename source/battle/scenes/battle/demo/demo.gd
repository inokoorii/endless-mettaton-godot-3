extends Battle

# NOTE: Temporary code to test out the `BattleBoard`!

"SCRIPT REGULAR VARIABLES"
var board_size_preset: int = 1


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_cancel"):
		board_size_preset += 1
		board_size_preset = wrapi(board_size_preset, 0, 2)
		
		match board_size_preset:
			0:
				board.ideal_size_left = 50
				board.ideal_size_top = 200
				board.ideal_size_right = 50
			1:
				board.ideal_size_left = 287
				board.ideal_size_top = 70
				board.ideal_size_right = 287
		
		board.resize_mode += 1
		board.resize_mode = wrapi(board.resize_mode, 0, board.ResizeModes.size() - 1)
