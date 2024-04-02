extends Resource
class_name NetcodeData

@export var class_id : StringName : set = set_class_id
var instance_id : int
var owner_class_id : int
var owner_instance_id : int
var class_id_int : int

func set_class_id(new_id : StringName) -> void:
	class_id = new_id.substr(0, 3)
