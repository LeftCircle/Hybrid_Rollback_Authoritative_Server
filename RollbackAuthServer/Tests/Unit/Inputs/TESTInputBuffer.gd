## The input buffer is used to determine how far of the server a client is. There
## should always be inputs in the buffer. If not, the client needs to increase
## their processing speed to execute inputs a little faster.
## If the input buffer is too large, then the clients need to slow their processing
## speed to come closer in line with the server/other clients.
extends GutTest

func before_each() -> void:
	InputSystem.reset()

## When writing an input into the buffer, the input should be marked as from
## the client and the buffer counter should increase by 1
func test_write_new_input_into_input_buffer_from_client() -> void:
	var frame = random_frame()
	var test_id = 1
	var input_history = _add_history_to_input_system(test_id)
	var input = _get_test_input(frame, true)
	var buffer = StableBufferData.new()
	InputSystem._write_input(input_history, input, buffer)
	assert_eq(buffer.current_bufffer_in_frames, 1)
	assert_true(input.matches(input_history.input_array[frame % InputHistory.HISTORY_SIZE]))

func test_write_already_received_input_into_buffer() -> void:
	var frame = random_frame()
	var test_id = randi()
	var input_history = _add_history_to_input_system(test_id)
	var input = _get_test_input(frame, true)
	var buffer : StableBufferData = StableBufferData.new()
	InputSystem._write_input(input_history, input, buffer)
	InputSystem._write_input(input_history, input, buffer)
	assert_eq(buffer.current_bufffer_in_frames, 1)

func test_write_predicted_input_into_buffer() -> void:
	var frame = random_frame()
	var test_id = randi()
	var input_history = _add_history_to_input_system(test_id)
	var input = _get_test_input(frame, false)
	var buffer : StableBufferData = StableBufferData.new()
	InputSystem._write_input(input_history, input, buffer)
	assert_eq(buffer.current_bufffer_in_frames, 0)
	assert_true(input.matches(input_history.input_array[frame % InputHistory.HISTORY_SIZE]))

func test_read_frame_not_from_client() -> void:
	var frame = random_frame()
	var test_id = randi()
	var input_history = _add_history_to_input_system(test_id)
	var input = _get_test_input(frame, true)
	var buffer : StableBufferData = StableBufferData.new()
	InputSystem._write_input(input_history, input, buffer)
	var next_frame = CommandFrame.next_frame(frame)
	var read_input = InputSystem._read_input(input_history, next_frame, buffer)
	assert_eq(buffer.current_bufffer_in_frames, 1)

func test_read_frame_from_client() -> void:
	var frame = random_frame()
	var test_id = randi()
	var input_history = _add_history_to_input_system(test_id)
	var input = _get_test_input(frame, true)
	var buffer : StableBufferData = StableBufferData.new()
	InputSystem._write_input(input_history, input, buffer)
	var read_input = InputSystem._read_input(input_history, frame, buffer)
	assert_eq(buffer.current_bufffer_in_frames, 0)

func test_decrement_only_occurs_once() -> void:
	# When we get InputActions for a frame, that requires reading the current and previous
	# frame. But we only want to decrement the buffer size for the current frame
	# When reading an input, check to see if it is for the current command frame
	# before decrementing the buffer size
	var frame = random_frame()
	# Add an input for this frame and the previous one, then get an action or duplicate for the current frame
	var test_id = randi()
	var input_history = _add_history_to_input_system(test_id)
	var input = _get_test_input(frame, true)
	var buffer : StableBufferData = StableBufferData.new()
	InputSystem._write_input(input_history, input, buffer)
	var previous_frame = CommandFrame.get_previous_frame(frame)
	var previous_input = _get_test_input(previous_frame, true)
	InputSystem._write_input(input_history, previous_input, buffer)

	var new_input_actions : InputAction = InputAction.new()
	InputSystem._set_inputs_from_history(input_history, new_input_actions, frame, buffer)
	assert_eq(buffer.current_bufffer_in_frames, 1)

func _add_history_to_input_system(test_id: int) -> InputHistory:
	var input_history = InputHistory.new()
	InputSystem._input_histories[test_id] = input_history
	return input_history

func _get_test_input(frame : int, is_from_client : bool) -> InputData:
	var input = InputData.new()
	input.action_bitmap = 1
	input.frame = frame
	input.is_from_client = is_from_client
	return input

func random_frame() -> int:
	var frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	CommandFrame.frame = frame
	CommandFrame.previous_command_frame = CommandFrame.get_previous_frame(frame)
	CommandFrame.input_frame = CommandFrame.get_previous_frame(frame, CommandFrame.input_buffer)
	return frame
