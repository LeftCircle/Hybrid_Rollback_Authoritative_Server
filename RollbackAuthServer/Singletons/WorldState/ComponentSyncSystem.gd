extends Node
# WorldState

const SEND_TO_ALL = -1
var component_updates = {}
var component_create = {}
var component_delete = {}
var updates_to_players = {}
var creations_to_players = {}
var deletions_to_players = {}

func _init():
	Server.player_connected.connect(_on_player_connected)
	Server.player_disconnected.connect(_on_player_disconnected)

func execute() -> void:
	_send_all_world_states()
	_reset()

func _on_player_connected(player_id : int) -> void:
	_create_compressor(player_id, Packet.TYPE.UPDATE, updates_to_players)
	_create_compressor(player_id, Packet.TYPE.CREATION, creations_to_players)
	_create_compressor(player_id, Packet.TYPE.DELETION, deletions_to_players)

func _create_compressor(player_id : int, type : Packet.TYPE, add_to : Dictionary) -> void:
	var compressor = SnapshotCompressor.new()
	compressor.type = type
	add_to[player_id] = compressor

func _on_player_disconnected(player_id : int) -> void:
	# TODO -> It might be better to call deferred this
	updates_to_players.erase(player_id)
	creations_to_players.erase(player_id)
	deletions_to_players.erase(player_id)

func sync_component_update(component, send_to_player_ids : Array = [SEND_TO_ALL]) -> void:
	if not component_updates.has(component):
		component_updates[component] = null
		if send_to_player_ids[0] == SEND_TO_ALL:
			_add_to_all_players(component, updates_to_players)
		else:
			_add_netcode_to_players(component, send_to_player_ids, updates_to_players)

func sync_creation(component, send_to_players : Array = [SEND_TO_ALL]) -> void:
	if not component_create.has(component):
		component_create[component] = null
		if send_to_players[0] == SEND_TO_ALL:
			_add_to_all_players(component, creations_to_players)
		else:
			_add_netcode_to_players(component, send_to_players, creations_to_players)

func _add_to_all_players(component, dict_to_add_to : Dictionary) -> void:
	for client_id in dict_to_add_to.keys():
		dict_to_add_to[client_id].add_data(component)

func _add_netcode_to_players(netcode, player_ids : Array, dict_to_add_to : Dictionary) -> void:
	for player_id in player_ids:
		dict_to_add_to[player_id].add_data(netcode)

func _send_all_world_states():
	for client_id in updates_to_players.keys():
		if updates_to_players[client_id].has_data():
			var world_state_packet : Packet = updates_to_players[client_id].create_packet()
			Server.send_packet(world_state_packet)
		if creations_to_players[client_id].has_data():
			var world_state_packet : Packet = creations_to_players[client_id].create_packet()
			Server.send_packet(world_state_packet)
		if deletions_to_players[client_id].has_data():
			var world_state_packet : Packet = deletions_to_players[client_id].create_packet()
			Server.send_packet(world_state_packet)

func _reset():
	component_updates.clear()
	component_create.clear()
	component_delete.clear()
	for client_id in updates_to_players.keys():
		updates_to_players[client_id].reset()
		creations_to_players[client_id].reset()
		deletions_to_players[client_id].reset()


