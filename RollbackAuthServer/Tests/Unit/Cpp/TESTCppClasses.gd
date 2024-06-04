extends GutTest


func test_cpp_classes_exist() -> void:
	var bit_stream_writer : BitStreamWriter
	var packet : Packet = Packet.new()
	assert_true(is_instance_valid(packet))

func test_command_frame_singleton_exists_and_ticks() -> void:
	assert_true(is_instance_valid(CommandFrame))
	CommandFrame.frame = 0
	CommandFrame.execute()
	assert_eq(CommandFrame.frame, 1)
