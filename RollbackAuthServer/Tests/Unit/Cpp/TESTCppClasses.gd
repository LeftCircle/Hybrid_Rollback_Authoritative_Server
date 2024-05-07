extends GutTest


func test_cpp_classes_exist() -> void:
	var bit_stream_writer : BitStreamWriter
	var packet : Packet = Packet.new()
	assert_true(is_instance_valid(packet))

