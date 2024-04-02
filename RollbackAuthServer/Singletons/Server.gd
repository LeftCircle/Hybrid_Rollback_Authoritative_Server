extends Node

signal player_connected(network_id)
signal player_disconnected(network_id)

var network = ENetMultiplayerPeer.new()
var server_api = SceneMultiplayer.new()

var packet_types = PacketTypes.new()
var expected_tokens : Array = []

@export var lobby : Node

func _ready() -> void:
	var server_initalizer = ServerInitializer.new()
	server_initalizer.init_server(get_tree(), network, server_api, self)
	_create_token_expiration_timer()

####################################################################################################
######### Player Data
####################################################################################################

func _on_packet_received(id : int, packet) -> void:
	packet = Array(packet)
	var packet_type = packet.pop_back()
	if packet_type == packet_types.INPUTS:
		_receive_player_inputs(id, packet)
	elif packet_type == packet_types.ITERATION_CHANGE:
		#TODO -> add player sync controller
		#PlayerSyncController.client_is_at_normal_iterations(id)
		pass
	else:
		assert(false, "Packet type not yet supported " + str(packet_type))

func _receive_player_inputs(id, packet : Array) -> void:
	# TODO -> add InputProcessing
	#InputProcessing.receive_unreliable_history(id, packet)
	if ProjectSettings.get_setting("global/rollback_enabled") and ObjectCreationRegistry.network_id_to_instance_id.has(id):
		#var input_history = InputHistoryCompresser.get_input_bytes(packet)
		var instance_id = ObjectCreationRegistry.network_id_to_instance_id[id]
		# TO DO -> error here if more than 255 players
		packet += [instance_id]
		packet += [packet_types.INPUTS]
		for player_id in server_api.get_peers():
			if player_id != id and player_id != 0:
				server_api.send_bytes(packet, player_id, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE)

####################################################################################################
######### Connecting players to the server
####################################################################################################

func _peer_connected(player_id):
	PlayerVerification.start(player_id)
	rpc_id(player_id, "get_token_rpc")

func on_player_verified(player_id : int) -> void:
	emit_signal("player_connected", player_id)

func _peer_disconnected(player_id):
	rpc_id(0, "disconnect_player", player_id)
	emit_signal("player_disconnected", player_id)

@rpc("any_peer")
func return_token(token):
	var player_id = server_api.get_remote_sender_id()
	PlayerVerification.verify(player_id, token)

func return_token_verification_results(player_id : int, result : bool) -> void:
	rpc_id(player_id, "return_token_verification_results_rpc", result)

func _create_token_expiration_timer():
	var timer = Timer.new()
	timer.wait_time = 30.0
	timer.autostart = true
	timer.set_name("TokenExpiration")
	timer.timeout.connect(_on_token_expiration_timeout)
	add_child(timer, true)

func _on_token_expiration_timeout():
	var current_time = Time.get_unix_time_from_system()
	var token_time
	if expected_tokens != []:
		# Go through tokens in reverse order to avoid shifting indexes
		for i in range(expected_tokens.size() -1, -1, -1):
			var token = expected_tokens[i]
			token_time = int(token.right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove_at(i)

####################################################################################################

####################################################################################################
######### Syncing players in the lobby. 
####################################################################################################

@rpc("any_peer")
func lobby_ready_button_activated_rpc() -> void:
	var player_id = server_api.get_remote_sender_id()
	lobby.player_ready(player_id)

@rpc("any_peer")
func lobby_ready_button_deactivated_rpc() -> void:
	var player_id = server_api.get_remote_sender_id()
	var lobby = get_node_or_null("/root/SceneHandler/Lobby")
	lobby.player_not_ready(player_id)

func send_client_serialization(client_id : int, class_instance_id : int) -> void:
	var network_id_and_instance = [client_id, class_instance_id]
	rpc_id(0, "receive_client_serialization", network_id_and_instance)

func sync_command_frames(player_id : int, latency : float, clients_ahead_by, client_buffer : int) -> void:
	var synced_frame = int(round(latency) + CommandFrame.frame) + clients_ahead_by + client_buffer
	rpc_id(player_id, "receive_synced_command_frame", synced_frame)

@rpc("any_peer")
func receive_command_frame_sync_complete():
	var player_id = server_api.get_remote_sender_id()
	lobby.player_command_step_synced(player_id)

func send_starting_command_step(player_id : int, starting_command_step : int) -> void:
	rpc_id(player_id, "receive_starting_command_step", starting_command_step)
	print("Sending start command step of ", starting_command_step)

