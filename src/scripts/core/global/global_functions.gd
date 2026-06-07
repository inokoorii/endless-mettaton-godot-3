extends Node


func scale_to_physics_fps(value: float) -> float:
	var base_fps: float = 30.0
	var physics_fps: float = Engine.iterations_per_second
	var scale_factor: float = 900.0
	
	return (value * scale_factor) * (physics_fps / base_fps)
