class_name DirectoryIndexer
extends Reference


"CLASS CONSTANTS"
const INDEX_KEY_SUCCESS: String = "success"
const INDEX_KEY_ROOT: String = "root"
const INDEX_KEY_DIRECTORIES: String = "directories"
const INDEX_KEY_FILES: String = "files"

const ENTRY_KEY_BASENAME: String = "basename"
const ENTRY_KEY_NAME: String = "name"
const ENTRY_KEY_PARENT: String = "parent"
const ENTRY_KEY_EXTENSION: String = "extension"
const ENTRY_KEY_CHILD_DIRECTORIES: String = "child_directories"
const ENTRY_KEY_CHILD_FILES: String = "child_files"


"CLASS PUBLIC METHODS"
func index_directory(
	directory_path: String,
	options: DirectoryIndexerOptions = DirectoryIndexerOptions.new()
) -> Dictionary:
	var directory: Directory = Directory.new()
	var directory_index: Dictionary = _create_empty_index()
	
	directory_path = PathUtils.normalize_path(directory_path)
	directory_index[INDEX_KEY_ROOT] = directory_path
	
	var open_result: int = directory.open(directory_path)
	if not open_result == OK:
		push_error(
			"Failed to open directory at path: '%s' (error: %s)."
			% [directory_path, ErrorUtils.get_error_string(open_result)]
		)
		return directory_index
	
	var list_result: int = directory.list_dir_begin(
		options.skip_navigational,
		options.skip_hidden
	)
	if not list_result == OK:
		push_error(
			"Failed to list directory contents at path: '%s' (error: %s)."
			% [directory_path, ErrorUtils.get_error_string(list_result)]
		)
		return directory_index
	
	var entry_name: String = directory.get_next()
	while not entry_name.empty():
		if directory.current_is_dir():
			_append_directory_entry_to_index(
				directory_index,
				directory_path,
				entry_name
			)
			
			if options.index_subdirectories:
				_append_subdirectory_to_index(
					directory_index,
					directory_path,
					entry_name,
					options
				)
		else:
			_append_file_entry_to_index(
				directory_index,
				directory_path,
				entry_name,
				options
			)
		
		entry_name = directory.get_next()
	directory.list_dir_end()
	
	_populate_directory_entry_children(directory_index)
	directory_index[INDEX_KEY_SUCCESS] = true
	return directory_index


"CLASS PRIVATE METHODS"
func _create_empty_index() -> Dictionary:
	return {
		INDEX_KEY_SUCCESS: false,
		INDEX_KEY_ROOT: "",
		INDEX_KEY_DIRECTORIES: {},
		INDEX_KEY_FILES: {},
	}


func _create_empty_directory_entry() -> Dictionary:
	return {
		ENTRY_KEY_BASENAME: "",
		ENTRY_KEY_NAME: "",
		ENTRY_KEY_PARENT: "",
		ENTRY_KEY_CHILD_DIRECTORIES: [],
		ENTRY_KEY_CHILD_FILES: [],
	}


func _create_empty_file_entry() -> Dictionary:
	return {
		ENTRY_KEY_BASENAME: "",
		ENTRY_KEY_NAME: "",
		ENTRY_KEY_PARENT: "",
		ENTRY_KEY_EXTENSION: "",
	}


func _append_directory_entry_to_index(
	directory_index: Dictionary,
	directory_path: String,
	entry_name: String
	
) -> void:
	if not is_index_valid(directory_index):
		return
	
	directory_path = PathUtils.normalize_path(directory_path)
	entry_name = PathUtils.normalize_path(entry_name)
	
	var entry: Dictionary = _create_empty_directory_entry()
	var entry_full_path: String = PathUtils.join_paths([directory_path, entry_name])
	
	entry[ENTRY_KEY_BASENAME] = entry_name.get_basename()
	entry[ENTRY_KEY_NAME] = entry_name
	entry[ENTRY_KEY_PARENT] = directory_path
	directory_index[INDEX_KEY_DIRECTORIES][entry_full_path] = entry


func _append_file_entry_to_index(
	directory_index: Dictionary,
	directory_path: String,
	entry_name: String,
	options: DirectoryIndexerOptions
) -> void:
	if not is_index_valid(directory_index):
		return
	
	directory_path = PathUtils.normalize_path(directory_path)
	entry_name = PathUtils.normalize_path(entry_name)
	
	var file_extension: String = entry_name.get_extension()
	if not options.is_file_allowed(entry_name):
		return
	
	var entry: Dictionary = _create_empty_file_entry()
	var entry_full_path: String = PathUtils.join_paths([directory_path, entry_name])
	
	entry[ENTRY_KEY_BASENAME] = entry_name.get_basename()
	entry[ENTRY_KEY_NAME] = entry_name
	entry[ENTRY_KEY_PARENT] = directory_path
	entry[ENTRY_KEY_EXTENSION] = file_extension
	directory_index[INDEX_KEY_FILES][entry_full_path] = entry


func _append_subdirectory_to_index(
	directory_index: Dictionary,
	directory_path: String,
	subdirectory_name: String,
	options: DirectoryIndexerOptions
) -> void:
	if not is_index_valid(directory_index):
		return
	
	var subdirectory_index: Dictionary = index_directory(
		PathUtils.join_paths([directory_path, subdirectory_name]),
		options
	)
	directory_index[INDEX_KEY_DIRECTORIES].merge(subdirectory_index[INDEX_KEY_DIRECTORIES])
	directory_index[INDEX_KEY_FILES].merge(subdirectory_index[INDEX_KEY_FILES])


func _populate_directory_entry_children(directory_index: Dictionary) -> void:
	if not is_index_valid(directory_index):
		return
	
	var directories: Dictionary = directory_index[INDEX_KEY_DIRECTORIES]
	var files: Dictionary = directory_index[INDEX_KEY_FILES]
	
#	I could refactor further, but I'm pretty happy with what I've got.
#	Leaving a "TODO:" note here nonetheless.
	
#	TODO: Refactor/clean this up at some point.
	for directory_path in directories:
		var directory: Dictionary = directory_index[INDEX_KEY_DIRECTORIES][directory_path]
		if not is_directory_entry_valid(directory):
			continue
		
		var directory_parent_path: String = directory[ENTRY_KEY_PARENT]
		if not directory_index[INDEX_KEY_DIRECTORIES].has(directory_parent_path):
			continue
		
		var directory_parent: Dictionary = directory_index[INDEX_KEY_DIRECTORIES][directory_parent_path]
		if not is_directory_entry_valid(directory_parent):
			continue
		if directory_parent[ENTRY_KEY_CHILD_DIRECTORIES].has(directory_path):
			continue
		directory_parent[ENTRY_KEY_CHILD_DIRECTORIES].append(directory_path)
	
	for file_path in files:
		var file: Dictionary = directory_index[INDEX_KEY_FILES][file_path]
		if not is_file_entry_valid(file):
			continue
		
		var file_parent_path: String = file[ENTRY_KEY_PARENT]
		if not directory_index[INDEX_KEY_DIRECTORIES].has(file_parent_path):
			continue
		
		var file_parent: Dictionary = directory_index[INDEX_KEY_DIRECTORIES][file_parent_path]
		if not is_directory_entry_valid(file_parent):
			continue
		if file_parent[ENTRY_KEY_CHILD_FILES].has(file_path):
			continue
		file_parent[ENTRY_KEY_CHILD_FILES].append(file_path)


"CLASS STATIC METHODS"
static func is_index_valid(directory_index: Dictionary) -> bool:
	var required_keys: Dictionary = {
		INDEX_KEY_SUCCESS: TYPE_BOOL,
		INDEX_KEY_ROOT: TYPE_STRING,
		INDEX_KEY_DIRECTORIES: TYPE_DICTIONARY,
		INDEX_KEY_FILES: TYPE_DICTIONARY,
	}
	var is_valid: bool = true
	
	for key in required_keys:
		if not directory_index.has(key):
			push_error(str(
				"Failed to validate 'directory_index': ",
				"key '%s' not found." % key
			))
			is_valid = false
		
		if directory_index.has(key) and not typeof(directory_index[key]) == required_keys[key]:
			var expected_type: String = TypeUtils.get_type_string(required_keys[key])
			var recieved_type: String = TypeUtils.get_type_string(directory_index[key])
			
			push_error(str(
				"Failed to validate 'directory_index': ",
				"value of key '%s' must be of type '%s', got: %s."
				% [key, expected_type, recieved_type]
			))
			is_valid = false
	
	return is_valid


static func is_directory_entry_valid(directory_entry: Dictionary) -> bool:
	var required_keys: Dictionary = {
		ENTRY_KEY_BASENAME: TYPE_STRING,
		ENTRY_KEY_NAME: TYPE_STRING,
		ENTRY_KEY_PARENT: TYPE_STRING,
		ENTRY_KEY_CHILD_DIRECTORIES: TYPE_ARRAY,
		ENTRY_KEY_CHILD_FILES: TYPE_ARRAY,
	}
	var is_valid: bool = true
	
	for key in required_keys:
		if not directory_entry.has(key):
			push_error(str(
				"Failed to validate 'directory_entry': ",
				"key '%s' not found." % key
			))
			is_valid = false
		
		if directory_entry.has(key) and not typeof(directory_entry[key]) == required_keys[key]:
			var expected_type: String = TypeUtils.get_type_string(typeof(required_keys[key]))
			var recieved_type: String = TypeUtils.get_type_string(typeof(directory_entry[key]))
			
			push_error(str(
				"Failed to validate 'directory_entry': ",
				"value of key '%s' must be of type '%s', got: %s."
				% [key, expected_type, recieved_type]
			))
			is_valid = false
	
	return is_valid


static func is_file_entry_valid(file_entry: Dictionary) -> bool:
	var required_keys: Dictionary = {
		ENTRY_KEY_BASENAME: TYPE_STRING,
		ENTRY_KEY_NAME: TYPE_STRING,
		ENTRY_KEY_PARENT: TYPE_STRING,
		ENTRY_KEY_EXTENSION: TYPE_STRING,
	}
	var is_valid: bool = true
	
	for key in required_keys:
		if not file_entry.has(key):
			push_error(str(
				"Failed to validate 'file_entry': ",
				"key '%s' not found." % key
			))
			is_valid = false
		
		if file_entry.has(key) and not typeof(file_entry[key]) == required_keys[key]:
			var expected_type: String = TypeUtils.get_type_string(typeof(required_keys[key]))
			var recieved_type: String = TypeUtils.get_type_string(typeof(file_entry[key]))
			
			push_error(str(
				"Failed to validate 'file_entry': ",
				"value of key '%s' must be of type '%s', got: %s."
				% [key, expected_type, recieved_type]
			))
			is_valid = false
	
	return is_valid
