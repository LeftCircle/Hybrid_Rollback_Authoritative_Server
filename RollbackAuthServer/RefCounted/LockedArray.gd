extends RefCounted
class_name LockedArray

var _received_data : Array = []
var _data_to_return : Array = []
var mutex = Mutex.new()

func receive_data(new_data) -> void:
	mutex.lock()
	_received_data.append(new_data)
	mutex.unlock()

func get_data_to_process() -> Array:
	mutex.lock()
	_data_to_return = _received_data.duplicate()
	_received_data.clear()
	mutex.unlock()
	return _data_to_return
	
