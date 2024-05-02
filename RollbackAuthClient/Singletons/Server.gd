extends Node

signal player_connected(network_id)
signal player_disconnected(network_id)

@export var login_screen : Node

var network = ENetMultiplayerPeer.new()
var server_api = SceneMultiplayer.new()
var token

func execute() -> void:
	server_api.poll()

func connect_to_server() -> void:
	print("Connecting to server...")
	var client_init = ClientInitializer.new()
	client_init.init_client(get_tree(), network, server_api, self)

func _on_packet_received(id : int, packet) -> void:
	pass

func _on_connection_succeeded() -> void:
	print("Connection to server succeeded!")

func _on_connection_failed() -> void:
	print("Connection to server failed")

####################################################################################################
### Some gateway/authintication rpc stuff
####################################################################################################

@rpc("any_peer")
func return_token(token):
	# Needs to be here to hit the server
	pass

@rpc("any_peer")
func get_token_rpc():
	# Send this token back to the main server
	print("Sending token ", token)
	rpc_id(1, "return_token", token)

# All required startup information will begin to be acquired once the
# athentication results are received and true. This is where the lobby is created,
# the rng is set, and potentially more to come!
@rpc("any_peer")
func return_token_verification_results_rpc(result):
	if result == true:
		#get_node(scene_handler_path).enter_lobby()
		print("We should enter the lobby now once it is set up")
		login_screen.queue_free()
	else:
		print("Verification failed. Try logging in again")
		login_screen.enable_login_buttons(true)
