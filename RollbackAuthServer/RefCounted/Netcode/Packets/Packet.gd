extends RefCounted
class_name Packet

enum TYPE{
	CREATION,
	UPDATE,
	DELETION,
	ITERATION_CHANGE,
	N_ENUM
}

var type : TYPE
var transfer_mode : MultiplayerPeer.TransferMode
var channel : int = 0
var target : int
var bit_stream : BitStream = BitStream.new()

