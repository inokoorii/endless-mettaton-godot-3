tool
extends Node


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
#	Temporary code!
	if Engine.editor_hint:
		return
	
	var index: Dictionary = DirectoryIndexer.index_directory(
			"res://assets",
			true,
			["import"])
	
	print(JSON.print(index, "\t"))


"SCRIPT PUBLIC METHODS"
