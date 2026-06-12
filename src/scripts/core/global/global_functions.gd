extends Node


# Helper method to quickly convert framerate-dependent values from UNDERTALE's
# source code to values that scale with Godot's physics FPS.
#
# Commonly used on movement speeds and timers.
func scale_to_physics_fps(value: float, delta: float, calculation_mode: String = "assign") -> float:
	var scale_factor: float = 900.0
	var base_fps: float = 30.0
	var physics_fps: float = Engine.iterations_per_second
	
	var output: float
#	Multiple calculation methods are available because I haven't found a
#	single scaling formula that behaves correctly in all use cases.
	match calculation_mode.to_lower():
		"assign":
#			Mode `assign`: Best used for direct assignment.
#			Example: `foo = GlobalFunctions.scale_to_physics_process(4.0, delta)`
			output = (value * scale_factor) * (physics_fps / base_fps)
		"increment":
#			Mode `increment`: Best used for incremental changes.
#			Example: `foo += GlobalFunctions.scale_to_physics_process(4.0, delta)`
			output = (value * scale_factor) * (physics_fps / base_fps) * (base_fps / physics_fps)
		_:
			print_debug()
			print("Invalid calculation mode \"%s\"!" % calculation_mode)
	
	return output * delta
