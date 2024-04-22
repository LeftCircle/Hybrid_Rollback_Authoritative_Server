extends RefCounted

const TYPE_TO_MODE : Dictionary = {
	Packet.TYPE.CREATION : MultiplayerPeer.TRANSFER_MODE_RELIABLE,
	Packet.TYPE.UPDATE : MultiplayerPeer.TRANSFER_MODE_UNRELIABLE,
	Packet.TYPE.DELETION : MultiplayerPeer.TRANSFER_MODE_RELIABLE,
	Packet.TYPE.ITERATION_CHANGE : MultiplayerPeer.TRANSFER_MODE_RELIABLE
}

var _packet_compressor : PacketCompressor = PacketCompressor.new()
var SEND_TO_ALL = 0

func new_packet(type : Packet.TYPE, target : int = SEND_TO_ALL) -> Packet:
	var packet = Packet.new()
	packet.type = type
	packet.target = target
	packet.channel = packet.type
	packet.transfer_mode = TYPE_TO_MODE[type]
	packet.bit_stream.init_buffer()
	_packet_compressor.compress(packet)
	return packet


func read_packet_data(byte_array) -> Packet:
	var packet = Packet.new()
	BitStreamReader.init_read(packet.bit_stream, byte_array)
	_packet_compressor.decompress(packet)
	return packet
