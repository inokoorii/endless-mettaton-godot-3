# TODO: Refactor/clean this up at some point.
class_name DirectoryIndexer
extends Object


"CLASS CONSTANTS"
const INDEX_KEY_ROOT: String = "root"
const INDEX_KEY_DIRECTORIES: String = "directories"
const INDEX_KEY_FILES: String = "files"

const ENTRY_KEY_BASENAME: String = "basename"
const ENTRY_KEY_NAME: String = "name"
const ENTRY_KEY_PARENT: String = "parent"
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
	directory_path = PathUtils.normalize_directory_path(directory_path)
	
#	Check if we can open the directory.
	var _directory_open_result: int = directory.open(directory_path)
	if not _directory_open_result == OK:
		print_debug(
				"Failed to open directory at path: '%s' (error: %s)."
				% [directory_path, ErrorUtils.get_error_string(_directory_open_result)])
		return directory_index
	
#	Check if we can list the directory's contents.
	var _directory_list_result: int = directory.list_dir_begin(true, true)
	if not _directory_list_result == OK:
		print_debug(
				"Failed to list directory contents at path: '%s' (error: %s)."
				% [directory_path, ErrorUtils.get_error_string(_directory_list_result)])
		return directory_index
	
#	Iterate through every item in the directory and populate `directory_index`.
	directory_index[INDEX_KEY_ROOT] = directory_path
	var entry_name: String = directory.get_next()
	
	while not entry_name.empty():
		if not directory.current_is_dir():
			_add_file_entry_to_index(
					directory_index, directory_path, entry_name, ignored_file_extensions)
		else:
			_add_directory_entry_to_index(
					directory_index, directory_path, entry_name)
			
			if not recursive:
				continue
			_index_sub_directory(
				directory_index, directory_path, entry_name, ignored_file_extensions)
		
		entry_name = directory.get_next()
	
	_populate_directory_entry_children(directory_index)
	
	directory.list_dir_end()
	return directory_index


"CLASS PRIVTATE STATIC METHODS"
static func _create_empty_index() -> Dictionary:
	return {
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


static func _index_sub_directory(
	directory_index: Dictionary,
	directory_path: String,
	entry_name: String,
	ignored_file_extensions: Array
) -> void:
	if not _is_index_valid(directory_index):
		return
	
	directory_path = PathUtils.normalize_directory_path(directory_path)
	entry_name = PathUtils.normalize_file_path(entry_name)
	
	var entry_full_path: String = str(directory_path, entry_name)
	
	var sub_directory_index: Dictionary = index_directory(
			entry_full_path, true, ignored_file_extensions)
	
	directory_index[INDEX_KEY_DIRECTORIES].merge(sub_directory_index[INDEX_KEY_DIRECTORIES])
	directory_index[INDEX_KEY_FILES].merge(sub_directory_index[INDEX_KEY_FILES])


static func _add_directory_entry_to_index(
	directory_index: Dictionary,
	directory_path: String,
	entry_name: String
) -> void:
	if not _is_index_valid(directory_index):
		return
	
	directory_path = PathUtils.normalize_directory_path(directory_path)
	entry_name = PathUtils.normalize_file_path(entry_name)
	
	var entry: Dictionary = _create_empty_directory_entry()
	var entry_full_path: String = PathUtils.normalize_directory_path(str(directory_path, entry_name))
	
	entry[ENTRY_KEY_BASENAME] = entry_name.get_basename()
	entry[ENTRY_KEY_NAME] = entry_name
	entry[ENTRY_KEY_PARENT] = directory_path
	directory_index[INDEX_KEY_DIRECTORIES][entry_full_path] = entry


static func _add_file_entry_to_index(
	directory_index: Dictionary,
	directory_path: String,
	entry_name: String,
	ignored_file_extensions: Array
) -> void:
	if not _is_index_valid(directory_index):
		return
	
	directory_path = PathUtils.normalize_directory_path(directory_path)
	entry_name = PathUtils.normalize_file_path(entry_name)
	
	var file_extension: String = entry_name.get_extension()
	if ignored_file_extensions.has(file_extension):
		return
	
	var entry: Dictionary = _create_empty_file_entry()
	var entry_full_path: String = str(directory_path, entry_name)
	
	entry[ENTRY_KEY_BASENAME] = entry_name.get_basename()
	entry[ENTRY_KEY_NAME] = entry_name
	entry[ENTRY_KEY_PARENT] = directory_path
	entry[ENTRY_KEY_EXTENSION] = file_extension
	directory_index[INDEX_KEY_FILES][entry_full_path] = entry


static func _populate_directory_entry_children(directory_index: Dictionary) -> void:
	if not _is_index_valid(directory_index):
		return
	
	for directory_path in directory_index[INDEX_KEY_DIRECTORIES]:
		var directory: Dictionary = directory_index[INDEX_KEY_DIRECTORIES][directory_path]
		if not _is_directory_entry_valid(directory):
			continue
		
		var directory_parent_path: String = directory[ENTRY_KEY_PARENT]
		if not directory_index[INDEX_KEY_DIRECTORIES].has(directory_parent_path):
			continue
		
		var directory_parent: Dictionary = directory_index[INDEX_KEY_DIRECTORIES][directory_parent_path]
		if not _is_directory_entry_valid(directory_parent):
			continue
		if directory_parent[ENTRY_KEY_CHILDREN].has(directory_path):
			continue
		
		directory_parent[ENTRY_KEY_CHILDREN].append(directory_path)
	
	for file_path in directory_index[INDEX_KEY_FILES]:
		var file: Dictionary = directory_index[INDEX_KEY_FILES][file_path]
		if not _is_file_entry_valid(file):
			continue
		
		var file_parent_path: String = file[ENTRY_KEY_PARENT]
		if not directory_index[INDEX_KEY_DIRECTORIES].has(file_parent_path):
			continue
		
		var file_parent: Dictionary = directory_index[INDEX_KEY_DIRECTORIES][file_parent_path]
		if not _is_directory_entry_valid(file_parent):
			continue
		if file_parent[ENTRY_KEY_CHILDREN].has(file_path):
			continue
		
		file_parent[ENTRY_KEY_CHILDREN].append(file_path)


static func _is_index_valid(directory_index: Dictionary) -> bool:
	if not directory_index.has(INDEX_KEY_ROOT):
		print_debug(
				"Failed to validate 'directory_index': '%s' not found."
				% INDEX_KEY_ROOT)
		return false
	
	if not directory_index.has(INDEX_KEY_DIRECTORIES):
		print_debug(
				"Failed to validate 'directory_index': '%s' not found."
				% INDEX_KEY_DIRECTORIES)
		return false
	
	if not directory_index.has(INDEX_KEY_FILES):
		print_debug(
				"Failed to validate 'directory_index': '%s' not found."
				% INDEX_KEY_FILES)
		return false
	
	if not directory_index[INDEX_KEY_ROOT] is String:
		print_debug(
				"Failed to validate 'directory_index': '%s' is not of type 'String'."
				% INDEX_KEY_ROOT)
		return false
	
	if not directory_index[INDEX_KEY_DIRECTORIES] is Dictionary:
		print_debug(
				"Failed to validate 'directory_index': '%s' is not of type 'Dictionary'."
				% INDEX_KEY_DIRECTORIES)
		return false
	
	if not directory_index[INDEX_KEY_FILES] is Dictionary:
		print_debug(
				"Failed to validate 'directory_index': '%s' is not of type 'Dictionary'."
				% INDEX_KEY_FILES)
		return false
	
	return true


static func _is_directory_entry_valid(directory_entry: Dictionary) -> bool:
	if not directory_entry.has(ENTRY_KEY_BASENAME):
		print_debug(
				"Failed to validate 'directory_entry': '%s' not found."
				% ENTRY_KEY_BASENAME)
		return false
	
	if not directory_entry.has(ENTRY_KEY_NAME):
		print_debug(
				"Failed to validate 'directory_entry': '%s' not found."
				% ENTRY_KEY_NAME)
		return false
	
	if not directory_entry.has(ENTRY_KEY_PARENT):
		print_debug(
				"Failed to validate 'directory_entry': '%s' not found."
				% ENTRY_KEY_PARENT)
		return false
	
	if not directory_entry.has(ENTRY_KEY_CHILDREN):
		print_debug(
				"Failed to validate 'directory_entry': '%s' not found."
				% ENTRY_KEY_CHILDREN)
		return false
	
	if not directory_entry[ENTRY_KEY_BASENAME] is String:
		print_debug(
				"Failed to validate 'directory_entry': '%s' is not of type 'String'."
				% ENTRY_KEY_BASENAME)
		return false
	
	if not directory_entry[ENTRY_KEY_NAME] is String:
		print_debug(
				"Failed to validate 'directory_entry': '%s' is not of type 'String'."
				% ENTRY_KEY_NAME)
		return false
	
	if not directory_entry[ENTRY_KEY_PARENT] is String:
		print_debug(
				"Failed to validate 'directory_entry': '%s' is not of type 'String'."
				% ENTRY_KEY_PARENT)
		return false
	
	if not directory_entry[ENTRY_KEY_CHILDREN] is Array:
		print_debug(
				"Failed to validate 'directory_entry': '%s' is not of type 'Array'."
				% ENTRY_KEY_CHILDREN)
		return false
	
	return true


static func _is_file_entry_valid(file_entry: Dictionary) -> bool:
	if not file_entry.has(ENTRY_KEY_BASENAME):
		print_debug(
				"Failed to validate 'file_entry': '%s' not found."
				% ENTRY_KEY_BASENAME)
		return false
	
	if not file_entry.has(ENTRY_KEY_NAME):
		print_debug(
				"Failed to validate 'file_entry': '%s' not found."
				% ENTRY_KEY_NAME)
		return false
	
	if not file_entry.has(ENTRY_KEY_PARENT):
		print_debug(
				"Failed to validate 'file_entry': '%s' not found."
				% ENTRY_KEY_PARENT)
		return false
	
	if not file_entry.has(ENTRY_KEY_EXTENSION):
		print_debug(
				"Failed to validate 'file_entry': '%s' not found."
				% ENTRY_KEY_EXTENSION)
		return false
	
	if not file_entry[ENTRY_KEY_BASENAME] is String:
		print_debug(
				"Failed to validate 'file_entry': '%s' is not of type 'String'."
				% ENTRY_KEY_BASENAME)
		return false
	
	if not file_entry[ENTRY_KEY_NAME] is String:
		print_debug(
				"Failed to validate 'file_entry': '%s' is not of type 'String'."
				% ENTRY_KEY_NAME)
		return false
	
	if not file_entry[ENTRY_KEY_PARENT] is String:
		print_debug(
				"Failed to validate 'file_entry': '%s' is not of type 'String'."
				% ENTRY_KEY_PARENT)
		return false
	
	if not file_entry[ENTRY_KEY_EXTENSION] is String:
		print_debug(
				"Failed to validate 'file_entry': '%s' is not of type 'String'."
				% ENTRY_KEY_EXTENSION)
		return false
	
	return true
