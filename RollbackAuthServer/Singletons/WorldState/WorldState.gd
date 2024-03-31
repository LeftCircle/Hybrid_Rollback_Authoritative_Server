extends Node
# WorldState

const SEND_TO_ALL = -1
var netcode_objs_to_compress = {}
var packets_to_players = {}

func _init():
	Server.player_connected.connect(_on_player_connected)
	Server.player_disconnected.connect(_on_player_disconnected)

func execute() -> void:
	_send_all_world_states()
	_reset()

func _on_player_connected(player_id : int) -> void:
	packets_to_players[player_id] = WorldStateCompression.new()

func _on_player_disconnected(player_id : int) -> void:
	# TODO -> It might be better to call deferred this
	packets_to_players.erase(player_id)

func add_netcode_to_compress(netcode, send_to_player_ids : Array = [SEND_TO_ALL]) -> void:
	if not netcode_objs_to_compress.has(netcode):
		netcode_objs_to_compress[netcode] = null
		if send_to_player_ids[0] == SEND_TO_ALL:
			_add_netcode_to_all_players(netcode)
		else:
			_add_netcode_to_players(netcode, send_to_player_ids)

func _add_netcode_to_all_players(netcode) -> void:
	for client_id in packets_to_players.keys():
		packets_to_players[client_id].add_data(netcode)

func _add_netcode_to_players(netcode, player_ids : Array) -> void:
	for player_id in player_ids:
		packets_to_players[player_id].add_data(netcode)

func _send_all_world_states():
	for client_id in packets_to_players.keys():
		var comp_world_state : PackedByteArray = packets_to_players[client_id].create_array_to_send()
		Server.send_world_state(client_id, comp_world_state)

func _reset():
	netcode_objs_to_compress.clear()
	for client_id in packets_to_players.keys():
		packets_to_players[client_id].reset()

func has_component(component) -> bool:
	return netcode_objs_to_compress.has(component.netcode)
