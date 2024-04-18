extends Resource
class_name EnetIDCompresser

@export var res_to_compress : ENetID

## Used to compress state data from an update. The class_instance and all relavent
## data of each component should be compressed.
func compress_update(bit_stream : BitStream, components : Array[ENetID]) -> void:
	for enet_id in components:
		BitStreamWriter.compress_instance_id(bit_stream, enet_id.instance_id)
		BitStreamWriter.variable_compress(bit_stream, enet_id.id)

## Used to compress component creation. Contains the class_id, owner_id, and owner_instance
## along with all starting state data
func compress_create(bit_stream : BitStream, components : Array[ENetID]) -> void:
	for enet_id in components:
		BitStreamWriter.compress_instance_id(bit_stream, enet_id.instance_id)
		BitStreamWriter.compress_class_id(bit_stream, enet_id.owner_class_id)
		BitStreamWriter.compress_instance_id(bit_stream, enet_id.owner_instance_id)
		BitStreamWriter.variable_compress(bit_stream, enet_id.id)

## Used to compress component deletion. Just compresses the instance_id.
func compress_delete(bit_stream : BitStream, components : Array[ENetID]) -> void:
	for enet_id in components:
		BitStreamWriter.compress_instance_id(bit_stream, enet_id.instance_id)
