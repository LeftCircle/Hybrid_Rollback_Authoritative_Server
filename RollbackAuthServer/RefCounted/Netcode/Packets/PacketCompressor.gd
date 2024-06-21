extends RefCounted
class_name PacketCompressor

var BITS_FOR_TYPE : int


func _init() -> void:
	BITS_FOR_TYPE = BaseCompression.n_bits_for_int(Packet.TYPE.N_ENUM)

func compress(packet : Packet) -> void:
	BitStreamWriter.write_int(packet, packet.type, BITS_FOR_TYPE)

func decompress(into_packet : Packet) -> void:
	into_packet.type = BitStreamReader.read(into_packet, BITS_FOR_TYPE)
