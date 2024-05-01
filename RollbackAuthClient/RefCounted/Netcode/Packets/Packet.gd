extends RefCounted
#class_name Packet

var packet : Packet

enum TYPE{
	CREATION,
	UPDATE,
	DELETION,
	ITERATION_CHANGE,
	LOBBY,
	INPUTS,
	N_ENUM
}

var type : TYPE
var transfer_mode : MultiplayerPeer.TransferMode
var channel : int = 0
var target : int
var bit_stream : BitStream = BitStream.new()

