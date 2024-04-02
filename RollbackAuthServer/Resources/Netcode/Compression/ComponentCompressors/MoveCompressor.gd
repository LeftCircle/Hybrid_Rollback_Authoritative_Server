extends Resource
class_name MoveCompressor

@export var res_to_compress : Move

func compress_update(bit_writer : BitStreamWriter, move_components : Array[Move]) -> void:
	for move in move_components:
		bit_writer.compress_instance_id(move.instance_id)
		bit_writer.variable_compress(move.friction)
		bit_writer.variable_compress(move.acceleration)
		bit_writer.variable_compress(move.max_speed)
		bit_writer.variable_compress(move.velocity, true)
		bit_writer.variable_compress(move.global_position, true)

func compress_create(bit_writer : BitStreamWriter, move_components : Array[Move]) -> void:
	for move in move_components:
		bit_writer.compress_instance_id(move.instance_id)
		bit_writer.compress_class_id(move.owner_class_id)
		bit_writer.compress_instance_id(move.owner_instance_id)
		bit_writer.variable_compress(move.friction)
		bit_writer.variable_compress(move.acceleration)
		bit_writer.variable_compress(move.max_speed)
		bit_writer.variable_compress(move.velocity, true)
		bit_writer.variable_compress(move.global_position, true)
