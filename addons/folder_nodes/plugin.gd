tool
extends EditorPlugin


"PLUGIN CONSTANTS"
const PLUGIN_PATH: String = "res://addons/folder_nodes/"

const FOLDER_SCRIPT_PATH: String = PLUGIN_PATH + "source/folder.gd"
const FOLDER_ICON_PATH: String = PLUGIN_PATH + "assets/icons/icon_folder.svg"

const FOLDER_2D_SCRIPT_PATH: String = PLUGIN_PATH + "source/folder_2d.gd"
const FOLDER_2D_ICON_PATH: String = PLUGIN_PATH + "assets/icons/icon_folder_2d.svg"

const FOLDER_3D_SCRIPT_PATH: String = PLUGIN_PATH + "source/folder_3d.gd"
const FOLDER_3D_ICON_PATH: String = PLUGIN_PATH + "assets/icons/icon_folder_3d.svg"


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _enter_tree() -> void:
	add_custom_type("Folder", "Node", load(FOLDER_SCRIPT_PATH), load(FOLDER_ICON_PATH))
	add_custom_type("Folder2D", "Node2D", load(FOLDER_2D_SCRIPT_PATH), load(FOLDER_2D_ICON_PATH))
	add_custom_type("Folder3D", "Spatial", load(FOLDER_3D_SCRIPT_PATH), load(FOLDER_3D_ICON_PATH))


func _exit_tree() -> void:
	remove_custom_type("Folder")
	remove_custom_type("Folder2D")
	remove_custom_type("Folder3D")
