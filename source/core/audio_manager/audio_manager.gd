tool
extends Node


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
#	Temporary code!
	if Engine.editor_hint:
		return
	
	var index_options: DirectoryIndexerOptions = DirectoryIndexerOptions.new()
	index_options.excluded_file_extensions = ["import"]
	
	var index: DirectoryIndexer = DirectoryIndexer.new()
	print(JSON.print(index.index_directory("res://", index_options), "\t"))


"SCRIPT PUBLIC METHODS"
