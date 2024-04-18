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
var _frame_syncs : Dictionary = {}
var input_buffer : int = ProjectSettings.get_setting("global/input_buffer")
var bit_stream : BitStream = BitStream.new()

func register(entity : BaseEntity) -> void:
	var enet_id : ENetID = entity.components["EID"]
	var input_history : InputHistory = entity.components["INH"]
	var input_action : InputAction = entity.components["INP"]
	_input_histories[enet_id.id] = input_history
	_input_actions[enet_id.id] = input_action
	_frame_syncs[enet_id.id] = entity.components["FSY"]

func receive_input_packet(enet_id : int, packet : PackedByteArray) -> void:
	_input_packets.receive_data([enet_id, packet])

func execute(frame : int) -> void:
	_read_input_packets()
	_set_input_actions(frame)

func _read_input_packets() -> void:
	# Step through all of the received packets and update the inputs and buffers
	var input_packets = _input_packets.get_data_to_process()
	for id_and_packet in input_packets:
		var enet_id : int = id_and_packet[0]
		var packet : PackedByteArray = id_and_packet[1]
		_read_input_packet_and_update_buffers(enet_id, packet)

## Steps through all of the input actions and histories, then sets the inputs
## based on the history
func _set_input_actions(frame : int) -> void:
	var previous_frame : int = CommandFrame.previous_command_frame
	for class_instance in _input_histories.keys():
		var input_hist : InputHistory = _input_histories[class_instance]
		var input_actions : InputAction = _input_actions[class_instance]
		var las_last_frame : int = CommandFrame.get_previous_frame(CommandFrame.previous_command_frame, 1)
		input_actions.previous_actions = _get_inputs_or_duplicate_for_frame(CommandFrame.previous_command_frame, las_last_frame, input_hist)
		input_actions.current_inputs = _get_inputs_or_duplicate_for_frame(frame, CommandFrame.previous_command_frame, input_hist)

func _get_inputs_or_duplicate_for_frame(frame : int, previous_frame : int, history : InputHistory) -> InputData:
	var current_index : int = frame % history.HISTORY_SIZE
	var has_frame : bool = history.frame_array[current_index] == frame
	var frame_inputs : InputData = history.input_array[current_index]
	if not has_frame:
		var previous_index : int = previous_frame % history.HISTORY_SIZE
		var previous_frame_inputs : InputData = history.input_array[previous_index]
		frame_inputs.set_data_with_obj(previous_frame_inputs)
	return frame_inputs

func _read_input_packet_and_update_buffers(enet_id : int, packet : PackedByteArray) -> void:
	BitStreamReader.init_read(bit_stream, packet)
	var input_history : InputHistory = _input_histories[enet_id]
	var client_frame = BitStreamReader.decompress_frame(bit_stream)
	_set_most_recent_received_frame(enet_id, client_frame)
	_read_input_data_into_hist(client_frame, input_history.input_array, input_history.frame_array)

func _read_input_data_into_hist(frame : int, input_array : Array[InputData], frame_array : Array[int]) -> void:
	var h_size : int = InputHistory.HISTORY_SIZE
	while !BitStreamReader.is_finished(bit_stream):
		var index : int = frame % h_size
		var input = input_array[frame % h_size]
		frame_array[index] = frame
		_decompress_action_into(bit_stream, input)
		frame = CommandFrame.get_previous_frame(frame)

func _set_most_recent_received_frame(enet_id : int, client_frame : int) -> void:
	var frame_sync : FrameSync = _frame_syncs[enet_id]
	if CommandFrame.is_more_recent_than(client_frame, frame_sync.most_recent_received_frame):
		var frame_dif = CommandFrame.frame_difference(client_frame, CommandFrame.frame)
		frame_sync.add_frame_difference(frame_dif)

func _decompress_action_into(bit_stream : BitStream, input : InputData) -> void:
	input.input_vector = BitStreamReader.decompress_quantized_input_vec(bit_stream)
	input.looking_vector = BitStreamReader.decompress_unit_vector(bit_stream)
	input.action_bitmap = BitStreamReader.decompress_int(bit_stream, BITS_FOR_BITMAP)

