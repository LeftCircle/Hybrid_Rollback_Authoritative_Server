extends NetcodeData
class_name InputHistory

const HISTORY_SIZE : int = 60

var input_array : Array[InputData] = []
var scratch_input : InputData = InputData.new()

func _init() -> void:
	input_array.resize(HISTORY_SIZE)
	for i in range(HISTORY_SIZE):
		input_array[i] = InputData.new()
