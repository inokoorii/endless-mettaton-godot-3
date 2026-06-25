tool
extends Node


"SCRIPT EXPORTED VARIABLES"
var audio_extensions: PoolStringArray = ["mp3", "ogg", "wav"]
var directory_configs: Array = []


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
#	TEMPORARY CODE!
	if Engine.editor_hint:
		pass
	
	var indexer_options: DirectoryIndexerOptions = DirectoryIndexerOptions.new()
	indexer_options.allowed_file_extensions = audio_extensions
	
	var indexer: DirectoryIndexer = DirectoryIndexer.new()
	for config in directory_configs:
		if config is AudioManagerDirectoryConfig:
			print(JSON.print(indexer.index_directory(config.directory_path, indexer_options), "\t"))


"SCRIPT PRIVATE METHODS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array([
		{
			"name": "AudioManager",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY,
		},
	])
	
	property_list.append_array([
		{
			"name": "audio_extensions",
			"type": TYPE_STRING_ARRAY,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	])
	property_list.append_array([
		{
			"name": "directory_configs",
			"type": TYPE_ARRAY,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": PropertyHintUtils.create_array_hint(
				TYPE_OBJECT,
				PROPERTY_HINT_RESOURCE_TYPE,
				"Resource"
			)
		},
	])
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list_reverts: Dictionary = {	
		"audio_extensions": PoolStringArray(["mp3", "ogg", "wav"]),
		"directory_configs": [],
	}
	
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
