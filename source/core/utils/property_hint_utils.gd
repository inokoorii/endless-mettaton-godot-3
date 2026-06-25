class_name PropertyHintUtils
extends Object


"CLASS STATIC METHODS"
# NOTE: Godot may print the following error message when creating array hints
# with custom classes: "Cannot get class '<class_name>'"
#
# DO NOT BE ALARMED!
# This appears to be an editor limitation of Godot 3.6.x when displaying
# typed arrays created through `_get_property_list()`. The array type
# restriction still works correctly in the inspector.
static func create_array_hint(
	type: int,
	property_hint: int = PROPERTY_HINT_NONE,
	property_hint_string: String = ""
) -> String:
	return "%d/%d:%s" % [type, property_hint, property_hint_string]
