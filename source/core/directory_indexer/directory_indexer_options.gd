class_name DirectoryIndexerOptions
extends Reference


"CLASS REGULAR VARIABLES"
var index_subdirectories: bool = true

# Files matching these extensions will be indexed. "*" allows all extensions.
var allowed_file_extensions: PoolStringArray = ["*"]

# Files matching these extensions will be ignored. "*" excludes all extensions.
var excluded_file_extensions: PoolStringArray = []

var skip_navigational: bool = true
var skip_hidden: bool = true


"CLASS PUBLIC METHODS"
func are_all_files_allowed() -> bool:
	return allowed_file_extensions.has("*")


func are_all_files_excluded() -> bool:
	return excluded_file_extensions.has("*")


func is_file_allowed(file_name: String) -> bool:
	var file_extension: String = file_name.get_extension()
	
	if are_all_files_excluded():
		return false
	if excluded_file_extensions.has(file_extension):
		return false
	
	return(
			are_all_files_allowed()
			or allowed_file_extensions.has(file_extension))
