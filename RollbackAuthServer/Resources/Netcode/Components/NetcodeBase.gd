extends Resource
class_name NetcodeBase
# For the object creation registry to function, the NetcodeBase must be added
# in the ready funciton of whatever class it is connected to

# The class_id is a UNIQUE 3 letter string, such as SWD for Sword
@export var class_id : StringName : set = set_class_id
@export var state_data : Resource # BaseStateData

var owner_class_id : int
var owner_instance_id : int

func set_class_id(new_id : StringName) -> void:
	class_id = new_id.substr(0, 3)

