extends NetcodeData
class_name InputHistory

const HISTORY_SIZE : int = 60

var input_array : Array[InputData] = []
var frame_array : Array[int]

func _init() -> void:
	input_array.resize(HISTORY_SIZE)
	frame_array.resize(HISTORY_SIZE)
	for i in range(HISTORY_SIZE):
		input_array[i] = InputData.new()
		frame_array[i] = 0
