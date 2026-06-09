extends Node2D


func _physics_process(delta: float) -> void:
	$SlicedSprite.h_separation += 7.5 * delta
	$SlicedSprite.v_separation += 7.5 * delta
