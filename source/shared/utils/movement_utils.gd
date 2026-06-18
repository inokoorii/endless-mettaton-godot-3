class_name MovementUtils
extends Reference


# Helper method to quickly convert framerate-dependent values from UNDERTALE's
# source code to values that scale with Godot's physics FPS.
#
# Commonly used on movement speeds.
static func scale_to_physics_fps(value: float, delta: float) -> float:
	var scale_factor: float = 900.0
	var base_fps: float = 30.0
	var physics_fps: float = Engine.iterations_per_second
	
	return (value * scale_factor) * (physics_fps / base_fps)
