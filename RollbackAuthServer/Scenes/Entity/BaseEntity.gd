extends Node
class_name BaseEntity

var components : Dictionary
@export var netcode : NetcodeData

func add_component(component) -> void:
	components[component.class_id] = component
