extends Node

const MAX_FRAME_NUMBER = 16777215
const MAX_FRAME_FOR_MOD = MAX_FRAME_NUMBER + 1
const HALF_MAX_FRAME = MAX_FRAME_NUMBER / 2

var frame_length_sec : float = 1.0 / float(ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))
var frame_length_msec : float = frame_length_sec * 1000
var frame = 0

var previous_command_frame : int = -1

func execute():
	previous_command_frame = frame
	frame = (frame + 1) % MAX_FRAME_NUMBER

static func is_more_recent_than(future_frame : int, past_frame : int) -> bool:
	return (((future_frame > past_frame) and (future_frame - past_frame <= HALF_MAX_FRAME)) or
			(future_frame < past_frame) and (past_frame - future_frame > HALF_MAX_FRAME))

static func greater_than_or_eq_to(frame_a : int, frame_b : int) -> bool:
	return is_more_recent_than(frame_a, frame_b) or frame_a == frame_b

static func get_previous_frame(frame : int, frames_back : int = 1) -> int:
	return posmod(frame - frames_back, MAX_FRAME_FOR_MOD)

static func frame_difference(future_frame : int, past_frame : int) -> int:
	if abs(past_frame - future_frame) > HALF_MAX_FRAME:
		# Frame wraparound has occured.
		if past_frame < future_frame:
			# The past frame is actually ahead!
			var frames_till_wrap = MAX_FRAME_NUMBER - future_frame
			return -(frames_till_wrap + past_frame) - 1
		else:
			var frames_till_wrap = MAX_FRAME_NUMBER - past_frame
			return future_frame + frames_till_wrap
	else:
		return future_frame - past_frame
