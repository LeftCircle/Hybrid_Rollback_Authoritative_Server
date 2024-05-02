extends RefCounted
class_name ClientInitializer

var local_ip = "127.0.0.1"
var server_ip = "20.185.61.230"
var port : int = 28836
var max_players : int = 100
var max_channels : int = 3

func init_client(scene_tree : SceneTree, network : ENetMultiplayerPeer, server_api : SceneMultiplayer, server_node : Node) -> void:
	_connect_network_and_server(scene_tree, network, server_api, server_node)
	_connect_to_server_api_functions(server_api, server_node)

func _connect_network_and_server(scene_tree : SceneTree, network : ENetMultiplayerPeer, server_api : SceneMultiplayer, server_node : Node):
	var ip = local_ip if ProjectSettings.get_setting("global/connect_to_local") else server_ip
	var client_status = network.create_client(ip, port, max_channels)
	_check_status(client_status, network)
	server_api.multiplayer_peer = network
	server_api.root_path = server_node.get_path()
	scene_tree.set_multiplayer(server_api, server_node.get_path())
	scene_tree.multiplayer_poll = false

func _connect_to_server_api_functions(server_api : SceneMultiplayer, server_node : Node):
	server_api.connection_failed.connect(server_node._on_connection_failed)
	server_api.connected_to_server.connect(server_node._on_connection_succeeded)
	server_api.peer_packet.connect(server_node._on_packet_received)

func _check_status(client_status, network : ENetMultiplayerPeer) -> void:
	if client_status != OK:
		OS.alert("Client creation failed")
	if network.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to connect to the authintiaction server")
