extends Resource
class_name LocalData

@export var class_id : StringName : set = set_class_id
var instance_id : int

func set_class_id(new_id : StringName) -> void:
	class_id = new_id.substr(0, 3)
