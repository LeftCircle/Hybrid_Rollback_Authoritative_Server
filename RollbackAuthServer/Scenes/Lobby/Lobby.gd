extends Node
class_name Lobby
# Keeps track of all players that have joined and if they have pressed the
# ready button or not. Once all players have pressed the ready button,
# A start command step is decided, then we will determine on what
# command step each client should start the game

const START_IN_X_COMMAND_STEPS : int = 20
enum {NOT_READY, READY, SYNCED_COMMAND, WAITING_FOR_START}
const CLIENT_BUFFER_PAD = 5

# States
enum {IN_LOBBY, SYNCING_COMMAND}

var players_in_lobby : Dictionary = {}
var all_ready = false
var game_start_frame : int = INF
var state = IN_LOBBY

func _ready():
	Server.player_connected.connect(_on_player_connected)
	Server.player_disconnected.connect(_on_player_disconnected)

func _on_player_connected(player_id : int) -> void:
	players_in_lobby[player_id] = NOT_READY

func _on_player_disconnected(player_id : int) -> void:
	if players_in_lobby.has(player_id):
		players_in_lobby.erase(player_id)

func _physics_process(_delta):
	match state:
		IN_LOBBY:
			while_players_in_lobby()
		SYNCING_COMMAND:
			while_players_sync_command()
		WAITING_FOR_START:
			while_waiting_for_start()

func while_players_in_lobby():
	if all_players_ready():
		sync_command_frames_and_set_buffers(players_in_lobby.keys())
		all_ready = true
		state = SYNCING_COMMAND

func sync_command_frames_and_set_buffers(player_ids : Array) -> void:
	for player_id in player_ids:
		var rtt_in_ms = Server.get_rtt_in_ms(player_id)
		var rtt_in_frames = rtt_in_ms / CommandFrame.frame_length_msec
		var client_ahead_by = rtt_in_frames
		var buffer = rtt_in_frames + CLIENT_BUFFER_PAD
		Server.sync_command_frames(player_id, rtt_in_frames, client_ahead_by, buffer)

func all_players_ready() -> bool:
	if not players_in_lobby.is_empty():
		return _all_players_ready()
	return false

func _all_players_ready() -> bool:
	for player_id in players_in_lobby.keys():
		if players_in_lobby[player_id] == NOT_READY:
			return false
	return true

func while_players_sync_command():
	if all_players_synced():
		#_send_map_data()
		_send_start_frame()

func _send_map_data() -> void:
	# If you have a procedurally generated map, you can send over the map
	# data to be loaded by the client, then wait for them to finish loading before 
	# moving on
	#Map.send_map_data()
	#state = LOADING_MAP
	pass

func all_players_synced():
	for player_id in players_in_lobby.keys():
		if not players_in_lobby[player_id] == SYNCED_COMMAND:
			return false
	return true

func while_players_load_map():
	if all_players_loaded() == true:
		_send_start_frame()

func _send_start_frame() -> void:
	game_start_frame = CommandFrame.frame + START_IN_X_COMMAND_STEPS
	send_players_starting_step(game_start_frame)
	state = WAITING_FOR_START
	print("All players loaded map")

func send_players_starting_step(game_start_step : int) -> void:
	for player_id in players_in_lobby.keys():
		Server.send_starting_command_step(player_id, game_start_step)

func all_players_loaded() -> bool:
	for player_id in players_in_lobby.keys():
		if players_in_lobby[player_id] != MAP_LOADED:
			return false
	return true

func while_waiting_for_start():
	if CommandFrame.frame >= game_start_frame:
		WorldState.start_sending_world_state()
		PlayerStateSync.start_syncing_state()
		PlayerSyncController.adjusting_process_speeds = true
		_spawn_players()
		Logging.log_line("GAME START!!")
		print("Game start!!")
		queue_free()

func _spawn_players():
	# Spawn players and sync the serialized_id's to uids
	for player_id in players_in_lobby.keys():
		Map.spawn_new_player(player_id)
		var class_instance_id = Map.get_player_node(player_id).netcode.class_instance_id
		Server.send_client_serialization(player_id, class_instance_id)


func player_ready(player_serialized_id) -> void:
	if not players_in_lobby[player_serialized_id] == READY:
		players_in_lobby[player_serialized_id] = READY
		#Map.spawn_new_player(player_serialized_id)

func player_not_ready(player_id) -> void:
	if not all_ready:
		players_in_lobby[player_id] = NOT_READY

func player_command_step_synced(player_id) -> void:
	players_in_lobby[player_id] = SYNCED_COMMAND

#func player_map_loaded(player_id : int, client_command_step : int, server_command_step : int):
	#players_in_lobby[player_id] = MAP_LOADED
	#print("Player map loaded on client step ", client_command_step, " Server receieved ", server_command_step)
