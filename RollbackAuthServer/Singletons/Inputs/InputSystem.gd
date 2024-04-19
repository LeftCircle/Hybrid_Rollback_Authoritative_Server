## A system for tracking all player inputs and confirming if a client is ahead of
## or behind the server based on when the inputs are arriving.
extends Node

const ACTION_TO_BITSHIFT = {
	"attack_primary" : 1,
	"attack_secondary" : 1 << 1,
	"dash" : 1 << 2,
	"draw_ranged" : 1 << 3,
	"fire_ranged" : 1 << 4,
}

var BITS_FOR_BITMAP = ACTION_TO_BITSHIFT.size()
var _input_packets : LockedArray = LockedArray.new()
var _input_histories : Dictionary = {}
var _input_actions : Dictionary = {}
var _stable_buffers : Dictionary = {}
var bit_stream : BitStream = BitStream.new()
var input_buffer : int = ProjectSettings.get_setting("global/input_buffer")

func register(entity : BaseEntity) -> void:
	var enet_id : ENetID = entity.components["EID"]
	var input_history : InputHistory = entity.components["INH"]
	var input_action : InputAction = entity.components["INP"]
	var stable_buffer : StableBufferData = entity.components["SBD"]
	_input_histories[enet_id.id] = input_history
	_input_actions[enet_id.id] = input_action
	_stable_buffers[enet_id.id] = stable_buffer

func receive_input_packet(enet_id : int, packet : PackedByteArray) -> void:
	_input_packets.receive_data([enet_id, packet])

func execute(frame : int) -> void:
	_read_input_packets()
	var input_frame : int = CommandFrame.get_previous_frame(frame, input_buffer)
	_set_input_actions(input_frame)

func _read_input_packets() -> void:
	# Step through all of the received packets and update the inputs and buffers
	var input_packets = _input_packets.get_data_to_process()
	for id_and_packet in input_packets:
		var enet_id : int = id_and_packet[0]
		var packet : PackedByteArray = id_and_packet[1]
		_read_input_packet_and_update_buffers(enet_id, packet)

## Steps through all of the input actions and histories, then sets the inputs
## based on the history. If an input has not yet arrived, it duplicates the previous input.
func _set_input_actions(frame : int) -> void:
	for class_instance in _input_histories.keys():
		var input_hist : InputHistory = _input_histories[class_instance]
		var input_actions : InputAction = _input_actions[class_instance]
		var buffer : StableBufferData = _stable_buffers[class_instance]
		_set_inputs_from_history(input_hist, input_actions, frame, buffer)

func _set_inputs_from_history(input_history : InputHistory, input_actions : InputAction, frame : int, buffer : StableBufferData) -> void:
	var previous_frame : int = CommandFrame.get_previous_frame(frame)
	input_actions.previous_inputs = _get_inputs_or_duplicate_for_frame(previous_frame, input_history, buffer)
	input_actions.current_inputs = _get_inputs_or_duplicate_for_frame(frame, input_history, buffer)

func _get_inputs_or_duplicate_for_frame(frame : int, history : InputHistory, buffer : StableBufferData) -> InputData:
	var frame_inputs : InputData = _read_input(history, frame, buffer)
	if not frame_inputs.is_from_client:
		var previous_frame : int = CommandFrame.get_previous_frame(frame)
		var previous_index : int = previous_frame % history.HISTORY_SIZE
		var previous_frame_inputs : InputData = history.input_array[previous_index]
		frame_inputs.set_data_with_obj(previous_frame_inputs)
		frame_inputs.is_from_client = false
	return frame_inputs

func _read_input_packet_and_update_buffers(enet_id : int, packet : PackedByteArray) -> void:
	BitStreamReader.init_read(bit_stream, packet)
	var input_history : InputHistory = _input_histories[enet_id]
	var client_frame = BitStreamReader.decompress_frame(bit_stream)
	var scratch_input: InputData = input_history.scratch_input
	var buffer : StableBufferData = _stable_buffers[enet_id]
	_read_input_data_into_hist(input_history, client_frame, scratch_input, buffer)

func _read_input_data_into_hist(input_history : InputHistory, frame : int, scratch_input : InputData, buffer : StableBufferData) -> void:
	while !BitStreamReader.is_finished(bit_stream):
		_decompress_action_into(bit_stream, scratch_input, frame)
		_write_input(input_history, scratch_input, buffer)
		frame = CommandFrame.get_previous_frame(frame)

func _write_input(input_history : InputHistory, input_data : InputData, buffer : StableBufferData) -> void:
	var old_data : InputData = input_history.input_array[input_data.frame % InputHistory.HISTORY_SIZE]
	if input_data.is_from_client and not old_data.is_from_client:
		buffer.current_bufffer_in_frames += 1
	old_data.set_data_with_obj(input_data)

func _read_input(input_history : InputHistory, frame : int, buffer : StableBufferData) -> InputData:
	var input_data : InputData = input_history.input_array[frame % InputHistory.HISTORY_SIZE]
	if input_data.is_from_client and input_data.frame == frame and frame == CommandFrame.input_frame:
		buffer.current_bufffer_in_frames -= 1
	return input_data

func _decompress_action_into(bit_stream : BitStream, input : InputData, frame : int) -> void:
	input.input_vector = BitStreamReader.decompress_quantized_input_vec(bit_stream)
	input.looking_vector = BitStreamReader.decompress_unit_vector(bit_stream)
	input.action_bitmap = BitStreamReader.decompress_int(bit_stream, BITS_FOR_BITMAP)
	input.frame = frame
	input.is_from_client = true

func reset() -> void:
	_input_packets.reset()
	_input_histories.clear()
	_input_actions.clear()
	bit_stream.reset()
