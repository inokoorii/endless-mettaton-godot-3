tool
class_name MainScene
extends Control


"CLASS REGULAR VARIABLES"
var _pre_fullscreen_window_size: Vector2
var _pre_fullscreen_window_position: Vector2


"CLASS ONREADY VARIABLES"
onready var clear_color: ColorRect = \
		get_node_or_null("ClearColor")

onready var game_viewport_container: ViewportContainer = \
		get_node_or_null("GameViewportContainer")
onready var game_viewport: Viewport = \
		get_node_or_null("GameViewportContainer/GameViewport")


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _input(event: InputEvent) -> void:
#	Keybind: [F4]
	if event.is_action_pressed("window_toggle_fullscreen"):
		if not OS.window_fullscreen:
#			Saving the window's position and size before entering fullscreen mode.
#			It will be used for later.
			_pre_fullscreen_window_size = OS.window_size
			_pre_fullscreen_window_position = OS.window_position
			
			yield(get_tree(), "idle_frame")
			OS.window_fullscreen = true
			
		else:
			OS.window_fullscreen = false
			
#			Hacky workaround/fix for a bug I've encountered on Linux where
#			the game's main viewport width and height may get set to the
#			monitor's resolution when exiting fullscreen mode.
			yield(get_tree(), "idle_frame")
			OS.window_size = _pre_fullscreen_window_size
			yield(get_tree(), "idle_frame")
			OS.window_position = _pre_fullscreen_window_position
