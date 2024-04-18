extends Resource
class_name InputData

var action_bitmap : int
var input_vector = Vector2.ZERO
var looking_vector = Vector2.ZERO

func set_data_with_obj(other_obj : InputData) -> void:
	action_bitmap = other_obj.action_bitmap
	input_vector = other_obj.input_vector
	looking_vector = other_obj.looking_vector
