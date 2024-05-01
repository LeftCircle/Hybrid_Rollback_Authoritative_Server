extends Node

signal player_connected(network_id)
signal player_disconnected(network_id)

var network = ENetMultiplayerPeer.new()
var server_api = SceneMultiplayer.new()

