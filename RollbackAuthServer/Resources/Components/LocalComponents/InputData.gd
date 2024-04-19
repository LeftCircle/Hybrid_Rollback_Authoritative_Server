extends Resource
class_name InputData

var action_bitmap : int
var input_vector = Vector2.ZERO
var looking_vector = Vector2.ZERO
var frame : int = 0
var is_from_client : bool = false

func set_data_with_obj(other_obj : InputData) -> void:
	action_bitmap = other_obj.action_bitmap
	input_vector = other_obj.input_vector
	looking_vector = other_obj.looking_vector
	is_from_client = other_obj.is_from_client
	frame = other_obj.frame

func matches(other_input : InputData) -> bool:
	return action_bitmap == other_input.action_bitmap and input_vector == other_input.input_vector and looking_vector == other_input.looking_vector
