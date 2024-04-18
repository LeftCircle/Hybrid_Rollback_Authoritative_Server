## Checks to see how much far ahead or behind of the current command frame
## each client is. If the client is too far ahead or behind, the clients
## processing speed is adjusted for a few frames to bring them as close to
## the most out of sync player as possible. This keeps rollback between clients
## consistent.
extends RefCounted
class_name CommandFrameSyncController

enum {FAST, SLOW, NORMAL, DOUBLE_FAST, HALF_SPEED}
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
var client_ahead_by = {}
var client_buffer_ranges = {}
var frames_since_adjust = 0
var adjusting_process_speeds = false
var reset_counter = false
#var stable_buffer_size = 4
#var stable_buffer_finder = StableBufferFinder.new()

# We need a map of player_id (for the server send) to character_id


func execute(frame : int):
	if frames_since_adjust >= ADJUST_EVERY_X_FRAMES:
		adjust_processing_speeds()
	frames_since_adjust += 1

func adjust_processing_speeds():
	var average_buffer : float = InputProcessing.get_average_buffer(player_id)
	var stable_buffer : float = stable_buffer_finder.get_stable_buffer(player_id)
	#print("Average buffer = ", average_buffer)
	adjust_client_with_input_buffer(player_id, average_buffer, stable_buffer)
	reset_counter = true

func _on_player_connect(network_id : int) -> void:
	iteration_speed[network_id] = NORMAL
	client_ahead_by[network_id] = 0
	client_buffer_ranges[network_id] = ClientBufferRanges.new()
	stable_buffer_finder.track_player(network_id)

func _on_player_disconnect(network_id : int) -> void:
	iteration_speed.erase(network_id)
	client_ahead_by.erase(network_id)
	stable_buffer_finder.stop_tracking(network_id)

func adjust_client(network_id : int, c_ahead_by : float, half_rtt : float):
	client_ahead_by[network_id] = c_ahead_by
	var buffer_ranges = client_buffer_ranges[network_id]
	buffer_ranges.set_buffer_ranges(half_rtt)
	if c_ahead_by > buffer_ranges.too_close and c_ahead_by < buffer_ranges.too_far:
		_run_at_normal_speed(network_id)
	elif c_ahead_by < 0:
		#print("Doubling ", network_id)
		double_client_speed(network_id)
	elif c_ahead_by < buffer_ranges.too_close:
		_speed_up(network_id)
	elif c_ahead_by > buffer_ranges.way_too_far:
		_half_speed(network_id)
	elif c_ahead_by > buffer_ranges.too_far:
		_slow_down(network_id)

func adjust_client_with_input_buffer(network_id : int, input_buffer_size : float, stable_buffer : float) -> void:
	if input_buffer_size < stable_buffer:
		_speed_up(network_id)
	elif input_buffer_size > stable_buffer + StableBufferFinder.MAX_AHEAD_OF_STABLE:
		slow_down_buffer_to_stable(network_id, input_buffer_size, stable_buffer)

func slow_down_buffer_to_stable(network_id : int, input_buffer_size : float, stable_buffer : float) -> void:
	if iteration_speed[network_id] != SLOW:
		var slow_frames = input_buffer_size - stable_buffer # - 1 ?
		if slow_frames <= 0:
			return
		var n_slow_frames = int(round((slow_frames) / BUFFER_DENOM))
		Server.send_iteration_change(network_id, SLOW, n_slow_frames)
		iteration_speed[network_id] = SLOW


func adjust_client_buffer_ranges(network_id : int) -> void:
	var half_rtt = Server.ping_tracker.get_half_rtt(network_id)
	var buffer_ranges = client_buffer_ranges[network_id]
	buffer_ranges.set_buffer_ranges(half_rtt)

func adjust_client_from_input_frame(network_id : int, input_frame : int) -> void:
	var c_ahead_by = CommandFrame.frame_difference(input_frame, CommandFrame.frame)
	var buffer_ranges = client_buffer_ranges[network_id]
	if c_ahead_by > buffer_ranges.too_close and c_ahead_by < buffer_ranges.too_far:
		_run_at_normal_speed(network_id)
	elif c_ahead_by < 0:
		double_client_speed(network_id)
	elif c_ahead_by < buffer_ranges.too_close:
		_speed_up(network_id)
	elif c_ahead_by > buffer_ranges.way_too_far:
		_half_speed(network_id)
	elif c_ahead_by > buffer_ranges.too_far:
		_slow_down(network_id)

func _run_at_normal_speed(network_id) -> void:
	if iteration_speed[network_id] != NORMAL:
		Server.send_iteration_change(network_id, NORMAL)
		iteration_speed[network_id] = NORMAL

func _speed_up(network_id) -> void:
	Server.send_iteration_change(network_id, FAST)
	iteration_speed[network_id] = FAST

func _slow_down(network_id) -> void:
	Server.send_iteration_change(network_id, SLOW)
	iteration_speed[network_id] = SLOW

func _half_speed(network_id) -> void:
	Server.send_iteration_change(network_id, HALF_SPEED)
	iteration_speed[network_id] = HALF_SPEED

func double_client_speed(network_id : int) -> void:
	Server.send_iteration_change(network_id, DOUBLE_FAST)
	iteration_speed[network_id] = DOUBLE_FAST

func client_is_at_normal_iterations(player_id : int) -> void:
	iteration_speed[player_id] = NORMAL

