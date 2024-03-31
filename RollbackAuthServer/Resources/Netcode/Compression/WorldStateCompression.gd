extends RefCounted
class_name WorldStateCompression

var class_dictionary = {}
var bits_in_byte_array = 0
var bit_packer = BitStreamWriter.new()

func reset():
	class_dictionary.clear()
	bits_in_byte_array = 0
	bit_packer.reset()

func add_data(netcode) -> void:
	if netcode.class_id in class_dictionary.keys():
		class_dictionary[netcode.class_id].append(netcode)
	else:
		class_dictionary[netcode.class_id] = [netcode]

func create_array_to_send() -> Array:
	# [class_id, n_objects, object_data, class_id, n_objects, object_data, ....]
	for class_id in class_dictionary.keys():
		compress_class_objects(class_id)
	var byte_array = bit_packer.get_byte_array()
	byte_array += BaseCompression.compress_int_to_x_bytes(CommandFrame.frame, BitStream.BYTES_FOR_FRAME)
	byte_array += BaseCompression.compress_int_to_x_bytes(bit_packer.total_bits, BitStream.BYTES_FOR_N_BITS)
	if byte_array.size() > 1450:
		print("BYTE ARRAY TOO BIG!!! %s" % [byte_array.size()])
	return byte_array

func compress_class_objects(class_id : String) -> void:
	bit_packer.compress_class_id(ObjectCreationRegistry.class_id_to_int_id[class_id])
	bit_packer.compress_int_into_x_bits(class_dictionary[class_id].size(), BitStream.BITS_FOR_N_OBJECTS)
	var compression_func : Callable = ObjectCreationRegistry.class_id_to_compression_func[class_id]
	for netcode in class_dictionary[class_id]:
		compression_func.call(netcode.data_container, bit_packer)
		netcode.write_compressed_data_to_stream(bit_packer)

