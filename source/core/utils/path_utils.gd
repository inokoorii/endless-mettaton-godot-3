class_name PathUtils
extends Object


"CLASS PUBLIC STATIC METHODS"
static func normalize_directory_path(directory_path: String) -> String:
	directory_path = directory_path.replace("\\", "/")
	directory_path = directory_path.simplify_path()
	
	if not directory_path.ends_with("/"):
		directory_path += "/"
	
	return directory_path


static func normalize_file_path(file_path: String) -> String:
	file_path = file_path.replace("\\", "/")
	file_path = file_path.simplify_path()
	
	return file_path
