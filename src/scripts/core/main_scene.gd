tool
class_name MainScene
extends Control


# CLASS PRIVATE VARIABLES
var _last_window_position: Vector2


# CLASS ONREADY VARIABLES
onready var clear_color: ColorRect = \
		get_node_or_null("ClearColor")
onready var game_viewport_container: ViewportContainer = \
		get_node_or_null("Viewports/Game")
onready var game_viewport: Viewport = \
		get_node_or_null("Viewports/Game/GameViewport")


# GODOT OVERRIDEN BUILT-IN VIRTUAL FUNCTIONS
func _ready() -> void:
	add_to_group("MainScenes", true)


func _input(event: InputEvent) -> void:
#	Keybind: [F4]
	if event.is_action_pressed("window_toggle_fullscreen"):
		if not OS.window_fullscreen:
#			Saving the window's position before entering fullscreen mode.
#			It will be used for later.
			_last_window_position = OS.window_position
			
			yield(get_tree(), "idle_frame")
			OS.window_fullscreen = true
			
		else:
			OS.window_fullscreen = false
			
#			Hacky workaround/fix for a bug I've encountered on Linux where
#			the game's main viewport width and height may get set to the
#			monitor's resolution when exiting fullscreen mode.
			yield(get_tree(), "idle_frame")
			OS.window_size = Vector2(
					ProjectSettings.get_setting("display/window/size/width"),
					ProjectSettings.get_setting("display/window/size/height"))
			
			yield(get_tree(), "idle_frame")
			OS.window_position = _last_window_position
