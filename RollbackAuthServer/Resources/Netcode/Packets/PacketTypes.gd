extends RefCounted
class_name PacketTypes

enum {INPUTS,
	PLAYER_STATES,
	WORLD_STATE,
	ITERATION_CHANGE,
	OBJECTS_TO_FREE,
	N_ENUM}

var _n_bits_for_packet_type

func _init():
	_n_bits_for_packet_type = BaseCompression.n_bits_for_int(N_ENUM)

func get_n_bits_for_packet_type() -> int:
	return _n_bits_for_packet_type
