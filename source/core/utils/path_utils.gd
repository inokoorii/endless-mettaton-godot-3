class_name PathUtils
extends Object


"CLASS PUBLIC STATIC METHODS"
static func normalize_path(path: String) -> String:
	return path.replace("\\", "/").simplify_path()


static func join_paths(parts: PoolStringArray) -> String:
	return "/".join(parts).replace("\\", "/").simplify_path()
