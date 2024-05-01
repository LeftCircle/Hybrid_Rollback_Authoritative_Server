extends RefCounted
class_name SnapshotCompressor

var class_dictionary = {}
var packet : Packet
var type : Packet.TYPE = Packet.TYPE.UPDATE

func _init() -> void:
	_init_packet()

func _init_packet() -> void:
	packet = PacketFlow.new_packet(type)

func reset():
	class_dictionary.clear()
	_init_packet()

func add_data(netcode) -> void:
	if netcode.class_id_int in class_dictionary.keys():
		class_dictionary[netcode.class_id_int].append(netcode)
	else:
		class_dictionary[netcode.class_id_int] = [netcode]

func create_packet(enet_id : int) -> Packet:
	# [class_id, n_objects, object_data, class_id, n_objects, object_data, ....]
	for class_id_int in class_dictionary.keys():
		compress_class_objects(class_id_int, packet.bit_stream)
	var byte_array : PackedByteArray = BitStreamWriter.get_byte_array(packet.bit_stream)
	byte_array += BaseCompression.compress_int_to_x_bytes(CommandFrame.frame, BitStream.BYTES_FOR_FRAME)
	byte_array += BaseCompression.compress_int_to_x_bytes(packet.bit_stream.total_bits, BitStream.BYTES_FOR_N_BITS)
	if byte_array.size() > 1450:
		print("BYTE ARRAY TOO BIG!!! %s" % [byte_array.size()])
	packet.bit_stream.mBuffer = byte_array
	packet.target = enet_id
	return packet

func compress_class_objects(class_id_int : int, bit_stream : BitStream) -> void:
	BitStreamWriter.compress_class_id(bit_stream, class_id_int)
	BitStreamWriter.compress_int_into_x_bits(bit_stream, class_dictionary[class_id_int].size(), BitStream.BITS_FOR_N_OBJECTS)
	var compression_func : Callable = ObjectCreationRegistry.int_id_to_compression_func[class_id_int]
	for netcode in class_dictionary[class_id_int]:
		compression_func.call(netcode.data_container, bit_stream)
		netcode.write_compressed_data_to_stream(bit_stream)

func has_data() -> bool:
	return !class_dictionary.is_empty()

