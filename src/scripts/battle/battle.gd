extends Node2D


func _physics_process(delta: float) -> void:
	$SlicedSprite.spacing.x += 7.5 * delta
	$SlicedSprite.spacing.y += 7.5 * delta
