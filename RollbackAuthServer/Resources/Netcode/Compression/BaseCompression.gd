extends RefCounted
class_name BaseCompression


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
