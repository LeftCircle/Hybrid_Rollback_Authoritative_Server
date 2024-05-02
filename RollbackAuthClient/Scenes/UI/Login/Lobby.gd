extends Control
class_name Lobby

const NILL_START = -1

var scene_handler_path = "/root/SceneHandler"
var players_in_lobby = []
var max_lobby_size = 20
var command_game_start_step : int = NILL_START
#var player_spawn_positions = {}

@onready var dungeon_title = get_node("Background/LobbyScreen/DungeonTitle")
@onready var player_0_name = get_node("Background/LobbyScreen/Player0/NameLabel")
@onready var player_1_name = get_node("Background/LobbyScreen/Player1/NameLabel")
@onready var ready_button = get_node("Background/LobbyScreen/ReadyButton")

func set_command_game_start_step(_command_game_start_step : int) -> void:
	command_game_start_step = _command_game_start_step
	print("command start step = ", command_game_start_step, " Current command frame = ", CommandFrame.get_command_frame_number())
	# We are losing the first frame of the world to allow for player spawns
	WorldState.last_world_frame = _command_game_start_step + 1

#func set_player_spawn_positions(player_spawn_dict : Dictionary) -> void:
#	player_spawn_positions = player_spawn_dict

func _ready():
	var player_id = Server.server_api.get_unique_id()
	players_in_lobby.append(player_id)
	player_0_name.text = str(player_id)
	print("Player name should be set in the lobby")

func _physics_process(_delta):
	_add_players_to_lobby()
	if CommandFrame.frame >= command_game_start_step:
		start_game()

func _add_players_to_lobby() -> void:
	var n_players = players_in_lobby.size()
	for player_id in Server.server_api.get_peers():
		if player_id != 1 and n_players < max_lobby_size and not player_id in players_in_lobby:
			print("Network peers = ", Server.server_api.get_peers())
			print("Local id = %s" % Server.server_api.get_unique_id())
			players_in_lobby.append(player_id)
			var name_path = "Background/LobbyScreen/Player" + str(n_players) + "/NameLabel"
			get_node(name_path).text = str(player_id)
			n_players += 1
			# TO DO -> be able to remove these as well
			InputProcessing.add_player_to_action_dicts(player_id)

func start_game() -> void:
	#spawn_players()
#	if ProjectSettings.get_setting("global/ClientOnlyTest"):
#		var character = load("res://Scenes/Characters/PlayerCharacter/ClientPlayerCharacter.tscn").instantiate()
#		ObjectCreationRegistry.add_child(character)
	queue_free()

func spawn_players():
	# Spawning players should be handled by receiving the player object from the server
	pass
#	var map = get_node("/root/SceneHandler/Map") as Map
#	for player_id in players_in_lobby:
#		var serialized_id = WorldState.client_serialization.get_serialized_id(player_id)
#		map.spawn_new_player(serialized_id, player_spawn_positions[serialized_id])

func _on_ReadyButton_toggled(button_pressed):
	if button_pressed:
		Server.lobby_ready_button_activated()
	else:
		Server.lobby_ready_button_deactivated()
