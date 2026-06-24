class_name DirectoryIndexer
extends Object


"CLASS CONSTANTS"
const INDEX_KEY_SUCCESS: String = "success"
const INDEX_KEY_ROOT: String = "root"
const INDEX_KEY_DIRECTORIES: String = "directories"
const INDEX_KEY_FILES: String = "files"

const ENTRY_KEY_BASENAME: String = "basename"
const ENTRY_KEY_NAME: String = "name"
const ENTRY_KEY_PARENT: String = "parent_path"
const ENTRY_KEY_EXTENSION: String = "extension"
const ENTRY_KEY_CHILDREN: String = "children"


"CLASS PUBLIC STATIC METHODS"
static func index_directory(
	directory_path: String,
	recursive: bool,
	ignored_file_extensions: Array = []
) -> Dictionary:
	var directory: Directory = Directory.new()
	var directory_index: Dictionary = _create_empty_index()
	
	directory_path = PathUtils.normalize_path(directory_path)
	directory_index[INDEX_KEY_ROOT] = directory_path
	
	var open_result: int = directory.open(directory_path)
	if not open_result == OK:
		push_error(
				"Failed to open directory at path: '%s' (error: %s)."
				% [directory_path, ErrorUtils.get_error_string(open_result)])
		return directory_index
	
	var list_result: int = directory.list_dir_begin(true, true)
	if not list_result == OK:
		push_error(
				"Failed to list directory contents at path: '%s' (error: %s)."
				% [directory_path, ErrorUtils.get_error_string(list_result)])
		return directory_index
	
	var entry_name: String = directory.get_next()
	while not entry_name.empty():
		if directory.current_is_dir():
			_append_directory_entry_to_index(
					directory_index,
					directory_path,
					entry_name)
			
			if recursive:
				_append_subdirectory_to_index(
						directory_index,
						directory_path,
						entry_name,
						ignored_file_extensions)
		else:
			_append_file_entry_to_index(
					directory_index,
					directory_path,
					entry_name,
					ignored_file_extensions)
		
		entry_name = directory.get_next()
	directory.list_dir_end()
	
	_populate_directory_entry_children(directory_index)
	directory_index[INDEX_KEY_SUCCESS] = true
	return directory_index


static func is_index_valid(directory_index: Dictionary) -> bool:
	var required_keys: Dictionary = {
		INDEX_KEY_SUCCESS: TYPE_BOOL,
		INDEX_KEY_ROOT: TYPE_STRING,
		INDEX_KEY_DIRECTORIES: TYPE_DICTIONARY,
		INDEX_KEY_FILES: TYPE_DICTIONARY,
	}
	
	for key in required_keys:
		if not directory_index.has(key):
			push_error(
					"Failed to validate 'directory_index': "
					+ "key '%s' not found." % key)
			return false
		
		if not typeof(directory_index[key]) == required_keys[key]:
			push_error(
					"Failed to validate 'directory_index': "
					+ "invalid value type for key '%s'." % key)
			return false
	
	return true


static func is_directory_entry_valid(directory_entry: Dictionary) -> bool:
	var required_keys: Dictionary = {
		ENTRY_KEY_BASENAME: TYPE_STRING,
		ENTRY_KEY_NAME: TYPE_STRING,
		ENTRY_KEY_PARENT: TYPE_STRING,
		ENTRY_KEY_CHILDREN: TYPE_ARRAY,
	}
	
	for key in required_keys:
		if not directory_entry.has(key):
			push_error(
					"Failed to validate 'directory_entry': "
					+ "key '%s' not found." % key)
			return false
		
		if not typeof(directory_entry[key]) == required_keys[key]:
			push_error(
					"Failed to validate 'directory_entry': "
					+ "invalid value type for key '%s'." % key)
			return false
	
	return true


static func is_file_entry_valid(file_entry: Dictionary) -> bool:
	var required_keys: Dictionary = {
		ENTRY_KEY_BASENAME: TYPE_STRING,
		ENTRY_KEY_NAME: TYPE_STRING,
		ENTRY_KEY_PARENT: TYPE_STRING,
		ENTRY_KEY_EXTENSION: TYPE_STRING,
	}
	
	for key in required_keys:
		if not file_entry.has(key):
			push_error(
					"Failed to validate 'file_entry': "
					+ "key '%s' not found." % key)
			return false
		
		if not typeof(file_entry[key]) == required_keys[key]:
			push_error(
					"Failed to validate 'file_entry': "
					+ "invalid value type for key '%s'." % key)
			return false
	
	return true


"CLASS PRIVTATE STATIC METHODS"
static func _create_empty_index() -> Dictionary:
	return {
		INDEX_KEY_SUCCESS: false,
		INDEX_KEY_ROOT: "",
		INDEX_KEY_DIRECTORIES: {},
		INDEX_KEY_FILES: {},
	}


static func _create_empty_directory_entry() -> Dictionary:
	return {
		ENTRY_KEY_BASENAME: "",
		ENTRY_KEY_NAME: "",
		ENTRY_KEY_PARENT: "",
		ENTRY_KEY_CHILDREN: [],
	}


static func _create_empty_file_entry() -> Dictionary:
	return {
		ENTRY_KEY_BASENAME: "",
		ENTRY_KEY_NAME: "",
		ENTRY_KEY_PARENT: "",
		ENTRY_KEY_EXTENSION: "",
	}


static func _append_subdirectory_to_index(
	directory_index: Dictionary,
	directory_path: String,
	subdirectory_name: String,
	ignored_file_extensions: Array
) -> void:
	if not is_index_valid(directory_index):
		return
	
	var subdirectory_index: Dictionary = index_directory(
			PathUtils.join_paths([directory_path, subdirectory_name]),
			true,
			ignored_file_extensions)
	
	directory_index[INDEX_KEY_DIRECTORIES].merge(subdirectory_index[INDEX_KEY_DIRECTORIES])
	directory_index[INDEX_KEY_FILES].merge(subdirectory_index[INDEX_KEY_FILES])


static func _append_directory_entry_to_index(
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


static func _append_file_entry_to_index(
	directory_index: Dictionary,
	directory_path: String,
	entry_name: String,
	ignored_file_extensions: Array
) -> void:
	if not is_index_valid(directory_index):
		return
	
	directory_path = PathUtils.normalize_path(directory_path)
	entry_name = PathUtils.normalize_path(entry_name)
	
	var file_extension: String = entry_name.get_extension()
	if ignored_file_extensions.has(file_extension):
		return
	
	var entry: Dictionary = _create_empty_file_entry()
	var entry_full_path: String = PathUtils.join_paths([directory_path, entry_name])
	
	entry[ENTRY_KEY_BASENAME] = entry_name.get_basename()
	entry[ENTRY_KEY_NAME] = entry_name
	entry[ENTRY_KEY_PARENT] = directory_path
	entry[ENTRY_KEY_EXTENSION] = file_extension
	directory_index[INDEX_KEY_FILES][entry_full_path] = entry


static func _populate_directory_entry_children(directory_index: Dictionary) -> void:
	if not is_index_valid(directory_index):
		return
	
	var directories: Dictionary = directory_index[INDEX_KEY_DIRECTORIES]
	var files: Dictionary = directory_index[INDEX_KEY_FILES]
	
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
		if directory_parent[ENTRY_KEY_CHILDREN].has(directory_path):
			continue
		
		directory_parent[ENTRY_KEY_CHILDREN].append(directory_path)
	
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
		if file_parent[ENTRY_KEY_CHILDREN].has(file_path):
			continue
		
		file_parent[ENTRY_KEY_CHILDREN].append(file_path)
