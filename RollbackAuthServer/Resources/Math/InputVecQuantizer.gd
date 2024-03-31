extends RefCounted
class_name InputVecQuantizer

const INPUT_VEC_LENGTH_SNAP = 0.25
const N_MOVEMENT_DIRECTIONS = 16
const INPUT_VEC_DEGREE_SNAP = 360.0 / 16.0
const BITS_FOR_LENGTH = 3
const BITS_FOR_DEGREES = 4

static func quantize_vec(vec : Vector2) -> Vector2:
	# Quantize the length and the angle in degrees.
	var length = vec.length()
	var quantized_len = snapped(length, INPUT_VEC_LENGTH_SNAP)
	var degrees = rad_to_deg(vec.angle())
	var quantized_deg = snapped(degrees, INPUT_VEC_DEGREE_SNAP)
	var quantized_rad = deg_to_rad(quantized_deg)
	vec = quantized_len * Vector2(cos(quantized_rad), sin(quantized_rad))
	return vec

static func get_quantized_length(vec : Vector2) -> int:
	return int(round(snapped(vec.length(), INPUT_VEC_LENGTH_SNAP) / INPUT_VEC_LENGTH_SNAP))

static func get_quantized_angle(vec : Vector2) -> int:
	var degrees = rad_to_deg(vec.angle())
	degrees = degrees + 360 if degrees < 0 else degrees
	return int(round(snapped(degrees, INPUT_VEC_DEGREE_SNAP) / INPUT_VEC_DEGREE_SNAP))

static func quantized_len_to_length(quantized_len : int) -> float:
	return quantized_len * INPUT_VEC_LENGTH_SNAP

static func quantized_deg_to_degrees(quantized_deg : int) -> float:
	return quantized_deg * INPUT_VEC_DEGREE_SNAP

static func quantized_len_and_deg_to_vector(quantized_len : int, quantized_degrees : int) -> Vector2:
	var quantized_rad = deg_to_rad(quantized_degrees * INPUT_VEC_DEGREE_SNAP)
	return quantized_len * INPUT_VEC_LENGTH_SNAP * Vector2(cos(quantized_rad), sin(quantized_rad))
