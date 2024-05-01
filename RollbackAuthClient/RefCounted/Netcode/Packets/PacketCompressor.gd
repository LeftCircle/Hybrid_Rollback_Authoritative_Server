extends RefCounted
class_name PacketCompressor

var BITS_FOR_TYPE : int


func _init() -> void:
	BITS_FOR_TYPE = BaseCompression.n_bits_for_int(Packet.TYPE.N_ENUM)

func compress(packet : Packet) -> void:
	BitStreamWriter.gaffer_write_int(packet.bit_stream, packet.type, BITS_FOR_TYPE)

func decompress(into_packet : Packet) -> void:
	into_packet.type = BitStreamReader.gaffer_read(into_packet.bit_stream, BITS_FOR_TYPE)
