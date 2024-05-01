extends RefCounted
class_name BaseCompression

const VARIABLE_COMPRESS_FLOATING_POINT_PRECISION = 3
const VARIABLE_COMPRESS_FLOATING_POINT_SCALE = pow(10, VARIABLE_COMPRESS_FLOATING_POINT_PRECISION)

static func n_bits_for_int(val : int, signed = false) -> int:
	val = abs(val)
	var bits : int = 1
	var max_value = 1
	while true:
		max_value = (1 << bits) - 1
		if max_value >= val or bits >= 64:
			break
		bits += 1
	if signed:
		bits += 1
	return bits

static func compress_int_to_x_bytes(inData : int, n_bytes : int) -> PackedByteArray:
	var byte_array : PackedByteArray = []
	for i in range(n_bytes):
		byte_array.append(inData & 0xff)
		inData = inData >> 8
	return byte_array

static func decompress_byte_array_to_int(byte_array : PackedByteArray) -> int:
	var val = 0
	var n_bytes = byte_array.size()
	for i in range(n_bytes):
		val = val | (byte_array[i] << (8 * i))
	return val

static func n_bits_for_vector(vec : Vector2, signed = false) -> int:
	var max_val = max(abs(vec.x), abs(vec.y))
	var n_bits = n_bits_for_int(int(round(max_val)), signed)
	return 2 * n_bits

static func n_bits_for_float(val : float, signed = false) -> int:
	var int_val = int(round(val * VARIABLE_COMPRESS_FLOATING_POINT_SCALE))
	return n_bits_for_int(int_val, signed)
