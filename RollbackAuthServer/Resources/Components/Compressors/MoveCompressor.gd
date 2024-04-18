extends Resource
class_name MoveCompressor

@export var res_to_compress : Move

func compress_update(bit_stream : BitStream, move_components : Array[Move]) -> void:
	for move in move_components:
		BitStreamWriter.compress_instance_id(bit_stream, move.instance_id)
		BitStreamWriter.variable_compress(bit_stream, move.friction)
		BitStreamWriter.variable_compress(bit_stream, move.acceleration)
		BitStreamWriter.variable_compress(bit_stream, move.max_speed)
		BitStreamWriter.variable_compress(bit_stream, move.velocity, true)
		BitStreamWriter.variable_compress(bit_stream, move.global_position, true)

func compress_create(bit_stream : BitStream, move_components : Array[Move]) -> void:
	for move in move_components:
		BitStreamWriter.compress_instance_id(bit_stream, move.instance_id)
		BitStreamWriter.compress_class_id(bit_stream, move.owner_class_id)
		BitStreamWriter.compress_instance_id(bit_stream, move.owner_instance_id)
		BitStreamWriter.variable_compress(bit_stream, move.friction)
		BitStreamWriter.variable_compress(bit_stream, move.acceleration)
		BitStreamWriter.variable_compress(bit_stream, move.max_speed)
		BitStreamWriter.variable_compress(bit_stream, move.velocity, true)
		BitStreamWriter.variable_compress(bit_stream, move.global_position, true)

func compress_delete(bit_stream : BitStream, move_components : Array[Move]) -> void:
	for move in move_components:
		BitStreamWriter.compress_instance_id(bit_stream, move.instance_id)
