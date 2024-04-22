## This script uses the RTT of each client to determine the stable buffer
## size. The stable buffer is such that each client is at about the same
## frame. This way packets between clients will only differ by half RTT between
## clients, and not be dependent on how close each client is to the server.
extends Node

const MIN_STABLE_BUFFER : float = 2.5
const MAX_AHED_OF_STABLE : float = 2

var buffer_data_array : Array[StableBufferData]

var frame_length_msec : float
var longest_current_rtt : float = 0

func _init() -> void:
	frame_length_msec = CommandFrame.frame_length_msec
	Server.player_disconnected.connect(_on_player_disconnected)

func register(entity : BaseEntity) -> void:
	var enet_id : ENetID = entity.components["EID"]
	var buffer_data : StableBufferData = entity.compoennts["SBD"]
	buffer_data.packet_peer = Server.network.get_peer(enet_id.id)
	buffer_data_array.append(buffer_data)

func execute() -> void:
	longest_current_rtt = 0
	_update_rtts()
	_update_stable_buffers()

func _update_rtts() -> void:
	for data in buffer_data_array:
		data.rtt = data.packet_peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
		longest_current_rtt = max(longest_current_rtt, data.rtt)

func _update_stable_buffers() -> void:
	for data in buffer_data_array:
		var half_rtt_diff : float = (data.rtt - longest_current_rtt) / 2.0
		data.stable_buffer = (half_rtt_diff / frame_length_msec) + MIN_STABLE_BUFFER
		data.max_buffer = data.stable_buffer + MAX_AHED_OF_STABLE

func reset() -> void:
	buffer_data_array.clear()
	longest_current_rtt = 0

func _on_player_disconnected(_enet_id : int) -> void:
	for buffer_data in buffer_data_array:
		if buffer_data.packet_peer.get_state() == ENetPacketPeer.STATE_DISCONNECTED:
			buffer_data_array.erase(buffer_data)
			break

func has(enet_id : int) -> bool:
	for buffer_data in buffer_data_array:
		if buffer_data.packet_peer.get_enet_id() == enet_id:
			return true
	return false
