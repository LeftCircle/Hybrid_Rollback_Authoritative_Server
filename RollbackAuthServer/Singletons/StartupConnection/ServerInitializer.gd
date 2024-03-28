extends RefCounted
class_name ServerInitializer

var port : int = 28836
var max_players : int = 100

func init_server(scene_tree : SceneTree, network : ENetMultiplayerPeer, server_api : SceneMultiplayer, server_node : Node) -> void:
	connect_and_check_connection(scene_tree, network, server_api, server_node)
	start_server(network, server_api)

func start_server(network : ENetMultiplayerPeer, server_api : SceneMultiplayer):
	print("Server has started!!")
	network.connect("peer_connected",Callable(self,"_peer_connected"))
	network.connect("peer_disconnected",Callable(self,"_peer_disconnected"))
	server_api.peer_packet.connect(self._on_packet_received)

func connect_and_check_connection(scene_tree : SceneTree, network : ENetMultiplayerPeer, server_api : SceneMultiplayer, server_node : Node):
	var server_status = network.create_server(port, max_players)
	_check_status(server_status)
	server_api.multiplayer_peer = network
	var server_node_path : NodePath = server_node.get_path()
	server_api.root_path = server_node_path
	scene_tree.set_multiplayer(server_api, server_node_path)
	scene_tree.multiplayer_poll = false

func _check_status(status) -> void:
	if status != OK:
		OS.alert("Server creation failed")


