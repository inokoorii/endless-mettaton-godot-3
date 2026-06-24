tool
extends Node


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
#	Temporary code!
	if Engine.editor_hint:
		return
	
	print(JSON.print(DirectoryIndexer.index_directory("res://assets/battle/sound_effects", true, ["import"]), "\t"))


"SCRIPT PUBLIC METHODS"


