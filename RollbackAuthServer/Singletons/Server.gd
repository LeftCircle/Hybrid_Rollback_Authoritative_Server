extends Node

signal player_connected(network_id)
signal player_disconnected(network_id)

var network = ENetMultiplayerPeer.new()
var server_api = SceneMultiplayer.new()

var expected_tokens : Array = []
var connected_players : Array[int] = []

@export var lobby : Node

func execute() -> void:
	server_api.poll()

func _ready() -> void:
	var server_initalizer = ServerInitializer.new()
	server_initalizer.init_server(get_tree(), network, server_api, self)
	_create_token_expiration_timer()

func send_packet(packet : Packet) -> void:
	server_api.send_bytes(packet.mBuffer, packet.target, packet.transfer_mode, packet.channel)

####################################################################################################
######### Player Data
####################################################################################################

func _on_packet_received(id : int, packet) -> void:
	packet = Array(packet)
	var packet_type = packet.pop_back()
	if packet_type == Packet.TYPE.INPUTS:
		_receive_player_inputs(id, packet)
	elif packet_type == Packet.TYPE.ITERATION_CHANGE:
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
		packet += [Packet.TYPE.INPUTS]
		for player_id in server_api.get_peers():
			if player_id != id and player_id != 0:
				server_api.send_bytes(packet, player_id, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE)

####################################################################################################
######### Connecting players to the server
####################################################################################################

func _on_peer_connected(player_id):
	PlayerVerification.start(player_id)
	await get_tree().process_frame
	print("Peer connected. Sending for the token from %s" % [player_id])
	rpc_id(player_id, "get_token_rpc")

func on_player_verified(player_id : int) -> void:
	emit_signal("player_connected", player_id)

func _on_peer_disconnected(player_id):
	rpc_id(0, "disconnect_player", player_id)
	emit_signal("player_disconnected", player_id)

@rpc("any_peer")
func return_token(token):
	var player_id = server_api.get_remote_sender_id()
	print("We should be starting player verification for %s" % [player_id])
	PlayerVerification.verify(player_id, token)

@rpc("any_peer")
func get_token_rpc():
	# RPC calls are annoying. Both projects must have this function
	pass

func return_token_verification_results(player_id : int, result : bool) -> void:
	rpc_id(player_id, "return_token_verification_results_rpc", result)

@rpc("any_peer")
func return_token_verification_results_rpc(result):
	# RPC calls are annoying. Both projects must have this function
	pass

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

