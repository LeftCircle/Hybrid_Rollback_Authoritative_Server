extends Node

const EXECUTE_EVERY_X_FRAMES : int = 5
const STABLE_AHEAD : float = 2.5
const MAX_AHEAD : float = 5.0

var enet_id_to_frame_sync : Dictionary = {}
var _id_to_frame_sync = {}
var _max_average_buffer : float
var _frame_counter : int = 0

func _ready() -> void:
	Server.player_disconnected.connect(_on_player_disconnected)

func register(entity : BaseEntity) -> void:
	var enet_id : ENetID = entity.get_component("EID")
	var frame_sync : FrameSync = entity.get_component("FSY")

func execute(frame) -> void:
	if _frame_counter >= EXECUTE_EVERY_X_FRAMES:
		_frame_counter = 0
		_execute(frame)
	else:
		_frame_counter += 1

func _execute(frame) -> void:
	_update_max_average()
	for id in _id_to_frame_sync.keys():
		var frame_sync : FrameSync = _id_to_frame_sync[id]
		# We need a way to map the player_id to the max buffer... that way we
		# can calculate how large of a buffer each client needs to stay synced.
		# Send iteration change if iteration isn't up to par

func _update_max_average() -> void:
	for id in _id_to_frame_sync.keys():
		pass

func _on_player_disconnected(enet_id : int) -> void:
	_id_to_frame_sync.erase(enet_id)
