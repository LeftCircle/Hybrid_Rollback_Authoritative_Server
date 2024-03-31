extends RefCounted
class_name PackageBuilder

const SEND_TO_ALL = -1

var netcode_objs_to_compress = {}
var packets_to_players = {}

func _init():
	Server.player_connected.connect(_on_player_connected)
	Server.player_disconnected.connect(_on_player_disconnected)

func _on_player_connected(player_id : int) -> void:
	packets_to_players[player_id] = WorldStateCompression.new()

func _on_player_disconnected(player_id : int) -> void:
	if packets_to_players.has(player_id):
		packets_to_players.erase(player_id)

func add_netcode_to_compress(netcode, send_to_player_ids : Array = [SEND_TO_ALL]) -> void:
	if is_physics_processing():
		_add_netcode_to_compress(netcode, send_to_player_ids)

func _add_netcode_to_compress(netcode, send_to_player_ids : Array = [SEND_TO_ALL]):
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
		if packets_to_players.has(player_id):
			packets_to_players[player_id].add_data(netcode)

func _compress_netcode_objects():
	# TO DO -> This can 100% be multithreaded
	for netcode in netcode_objs_to_compress.keys():
		netcode.compress()

func _reset():
	netcode_objs_to_compress.clear()

func has_component(component) -> bool:
	return netcode_objs_to_compress.has(component.netcode)
