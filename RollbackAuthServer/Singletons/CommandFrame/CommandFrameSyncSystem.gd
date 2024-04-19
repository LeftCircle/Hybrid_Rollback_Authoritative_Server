## Checks to see how much far ahead or behind of the current command frame
## each client is. If the client is too far ahead or behind, the clients
## processing speed is adjusted for a few frames to bring them as close to
## the most out of sync player as possible. This keeps rollback between clients
## consistent.
extends Node

enum SPEEDS{FAST, SLOW, NORMAL}
const ADJUST_EVERY_X_FRAMES = 5
#const MINIMUM_BUFFER = 2.75

var NORMAL_ITERATIONS = int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))
var FAST_ITERATIONS = NORMAL_ITERATIONS + 5
var SLOW_ITERATIONS = NORMAL_ITERATIONS - 5
var DOUBLE_FAST_ITERATIONS = 2 * NORMAL_ITERATIONS
var DOUBLE_SLOW_ITERATIONS = NORMAL_ITERATIONS / 2
var SLOW_OVER_FAST = float(SLOW_ITERATIONS) / float(FAST_ITERATIONS)
var BUFFER_DENOM = float(NORMAL_ITERATIONS) * (1.0 / float(SLOW_ITERATIONS) - 1.0 / float(NORMAL_ITERATIONS))

var iteration_speed = {}
var _command_frame_syncs : Dictionary = {}
var _stable_buffers : Dictionary = {}
var _frames_since_adjust : int = 0

func _ready() -> void:
	Server.player_disconnected.connect(_on_player_disconnect)

func register(entity : BaseEntity) -> void:
	var enet_id : ENetID = entity.components["EID"]
	iteration_speed[enet_id.id] = SPEEDS.NORMAL
	var stable_buffer : StableBufferData = entity.components["SBD"]
	_stable_buffers[enet_id.id] = stable_buffer

func execute():
	if _frames_since_adjust >= ADJUST_EVERY_X_FRAMES:
		adjust_processing_speeds()
		_frames_since_adjust = 0
	_frames_since_adjust += 1

func adjust_processing_speeds():
	for id in _stable_buffers.keys():
		var sbd : StableBufferData = _stable_buffers[id]
		if sbd.current_bufffer_in_frames >= sbd.stable_buffer and sbd.current_bufffer_in_frames <= sbd.max_buffer:
			# Run normal speed
			_run_at_normal_speed(id)
		elif sbd.current_bufffer_in_frames < sbd.stable_buffer:
			# speed up!!
			_speed_up(id)
		elif sbd.current_bufffer_in_frames >= sbd.max_buffer:
			_slow_down_buffer_to_stable(id, sbd.current_bufffer_in_frames, sbd.stable_buffer)

func _run_at_normal_speed(network_id : int) -> void:
	if iteration_speed[network_id] != SPEEDS.NORMAL:
		Server.send_iteration_change(network_id, SPEEDS.NORMAL)
		iteration_speed[network_id] = SPEEDS.NORMAL

func _speed_up(network_id : int) -> void:
	if iteration_speed[network_id] != SPEEDS.FAST:
		Server.send_iteration_change(network_id, SPEEDS.FAST)
		iteration_speed[network_id] = SPEEDS.FAST

func _on_player_disconnect(network_id : int) -> void:
	iteration_speed.erase(network_id)
	_stable_buffers.erase(network_id)

func _slow_down_buffer_to_stable(network_id : int, input_buffer_size : float, stable_buffer : float) -> void:
	if iteration_speed[network_id] != SPEEDS.SLOW:
		var frames_ahead = input_buffer_size - stable_buffer
		if frames_ahead <= 0:
			return
		var n_slow_frames = int(round((frames_ahead) / BUFFER_DENOM))
		Server.send_iteration_change(network_id, SPEEDS.SLOW, n_slow_frames)
		iteration_speed[network_id] = SPEEDS.SLOW


