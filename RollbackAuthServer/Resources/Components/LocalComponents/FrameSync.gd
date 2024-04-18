extends LocalData
class_name FrameSync

const VALUES_TO_AVERAGE : int = 20

enum ITERATION_SPEEDS{FAST, SLOW, NORMAL}
var NORMAL_ITERATIONS = int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))
var FAST_ITERATIONS = NORMAL_ITERATIONS + 5
var SLOW_ITERATIONS = NORMAL_ITERATIONS - 5

var iteration_speed : ITERATION_SPEEDS = ITERATION_SPEEDS.NORMAL
var average_buffer : float = 0
var _head : int = 0
var _sum : float = 0
var _values : Array[int] = []

func _init() -> void:
	_values.resize(VALUES_TO_AVERAGE)
	for i in range(VALUES_TO_AVERAGE):
		_values[i] = 0

func add_frame_difference(frame_difference : int) -> void:
	_sum -= _values[_head]
	_values[_head] = frame_difference
	_sum += frame_difference
	average_buffer = _sum / VALUES_TO_AVERAGE
	_head = (_head + 1) % VALUES_TO_AVERAGE
