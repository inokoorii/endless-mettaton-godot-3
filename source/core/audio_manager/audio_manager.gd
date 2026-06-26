tool
extends Node


"SCRIPT CONSTANTS"
const RESOURCE_PATH_PREFIX: String = "res://"


"SCRIPT EXPORTED VARIABLES"
var audio_extensions: PoolStringArray = ["mp3", "ogg", "wav"]
var audio_directories: Array = []


"SCRIPT REGULAR VARIABLES"
var _audio_entries: Dictionary = {}
# TODO: Store references of active audio players.
var _audio_playing: Dictionary = {}


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _ready() -> void:
	if Engine.editor_hint:
		return
	
	load_audio_from_directories(audio_directories)


"SCRIPT PUBLIC METHODS"
func play_single(audio_id: String) -> AudioManagerAudioPlayback:
#	TODO: Clear all active instances of the audio before playing another.
	return _play(audio_id)


func play_overlapping(audio_id: String) -> AudioManagerAudioPlayback:
	return _play(audio_id)


func load_audio_from_directories(directories: Array) -> void:
	for directory in directories:
		if not directory is AudioManagerDirectoryConfig:
			continue
		
		load_audio_from_directory(directory)


func load_audio_from_directory(directory: AudioManagerDirectoryConfig) -> void:
	var indexer_options: DirectoryIndexerOptions = DirectoryIndexerOptions.new()
	indexer_options.allowed_file_extensions = audio_extensions
	
	var indexer: DirectoryIndexer = DirectoryIndexer.new()
	var index: Dictionary = indexer.index_directory(directory.directory_path, indexer_options)
	
	for path in index[DirectoryIndexer.INDEX_KEY_FILES]:
		var audio_entry: AudioManagerAudioEntry = AudioManagerAudioEntry.new()
		audio_entry.audio_stream = load(path)
		audio_entry.bus = directory.bus
		_audio_entries[path.lstrip(RESOURCE_PATH_PREFIX)] = audio_entry


"SCRIPT PRIVATE METHODS"
func _play(audio_id: String) -> AudioManagerAudioPlayback:
	if not audio_id in _audio_entries:
		push_error(str(
			"AudioManager: Cannot play audio with ID '%s'; " % audio_id,
			"no audio entry exists with that ID."
		))
		return null
	
	audio_id = PathUtils.normalize_path(audio_id)
	
	var entry: AudioManagerAudioEntry = _audio_entries[audio_id]
	var audio_stream_player: AudioStreamPlayer = _create_audio_stream_player(entry)
	var audio_playback: AudioManagerAudioPlayback = AudioManagerAudioPlayback.new(audio_stream_player)
	
	audio_stream_player.play()
	return audio_playback


func _create_audio_stream_player(audio_entry: AudioManagerAudioEntry) -> AudioStreamPlayer:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	
	audio_stream_player.stream = audio_entry.audio_stream
	audio_stream_player.bus = audio_entry.bus
	audio_stream_player.connect("finished", audio_stream_player, "queue_free")
	
	add_child(audio_stream_player)
	return audio_stream_player


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
			"name": "audio_directories",
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
		"audio_directories": [],
	}
	
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
