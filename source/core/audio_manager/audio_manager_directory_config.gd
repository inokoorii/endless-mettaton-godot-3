tool
class_name AudioManagerDirectoryConfig
extends Resource


"CLASS CONSTANTS"
const BUS_INDEX_MASTER: int = 0


"CLASS EXPORTED VARIABLES"
var directory_path: String = ""

var bus: int = BUS_INDEX_MASTER \
	setget set_bus


"OVERRIDEN GODOT BUILT-IN CALLBACKS"
func _init() -> void:
	if AudioServer.is_connected("bus_layout_changed", self, "property_list_changed_notify"):
		return
	
	AudioServer.connect("bus_layout_changed", self, "property_list_changed_notify")


"CLASS PUBLIC METHODS"
func get_bus_name() -> String:
	return AudioServer.get_bus_name(bus)


"CLASS PRIVATE METHODS"
func _get_bus_names_as_enum_hint() -> String:
	var bus_names: PoolStringArray = []
	
	for index in AudioServer.bus_count:
		bus_names.append(AudioServer.get_bus_name(index))
	
	return ",".join(bus_names)


"CLASS PUBLIC METHODS (PROPERTY SETTERS)"
func set_bus(value: int) -> void:
	bus = clamp(value, 0, AudioServer.bus_count) as int


"CLASS PRIVATE METHODS (PROPERTY LIST)"
func _get_property_list() -> Array:
	var property_list: Array = []
	
	property_list.append_array([
		{
			"name": "AudioManagerDirectoryEntry",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY,
		},
	])
	
	property_list.append_array([
		{
			"name": "directory_path",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_DIR,
		},
		{
			"name": "bus",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": _get_bus_names_as_enum_hint(),
		},
	])
	
	return property_list


func _get_property_list_reverts() -> Dictionary:
	var property_list_reverts: Dictionary = {
		"directory_path": "",
		"bus": BUS_INDEX_MASTER,
	}
	
	return property_list_reverts


func property_can_revert(property: String):
	return _get_property_list_reverts().has(property)


func property_get_revert(property: String):
	return _get_property_list_reverts().get(property)
