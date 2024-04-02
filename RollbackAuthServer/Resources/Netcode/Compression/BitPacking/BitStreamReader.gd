extends BitStream
class_name BitStreamReader

var read_bits : int = 0

func reset() -> void:
	super.reset()
	read_bits = 0

# The array MUST have the last x bytes be the total number of bits
func init_read(new_buffer : PackedByteArray) -> void:
	var bytes_for_bits : PackedByteArray = new_buffer.slice(-BYTES_FOR_N_BITS)
	total_bits = BaseCompression.decompress_byte_array_to_int(bytes_for_bits)
	gaffer_start_read(new_buffer, total_bits)

func gaffer_start_read(new_buffer : PackedByteArray, bits_to_read : int) -> void:
	mBuffer = new_buffer
	scratch = 0
	scratch_bits = 0
	total_bits = bits_to_read
	read_bits = 0
	word_index = 0

func gaffer_read(x_bits : int) -> int:
	if scratch_bits < x_bits:
		read_word()
	var val : int = scratch & ((1 << x_bits) - 1)
	scratch = scratch >> x_bits
	scratch_bits -= x_bits
	read_bits += x_bits
	return val

func is_finished() -> bool:
	assert(read_bits <= total_bits) #,"assert_debug")
	return read_bits == total_bits

func read_word() -> void:
	var word : int = 0
	var buffer_index : int = word_index * 4
	word = word | mBuffer[buffer_index]
	word = word | (mBuffer[buffer_index + 1] << 8)
	word = word | (mBuffer[buffer_index + 2] << 16)
	word = word | (mBuffer[buffer_index + 3] << 24)
	word = word << scratch_bits
	scratch = word | scratch
	scratch_bits += WORD_SIZE
	word_index += 1

func decompress_int_array(is_signed = false) -> Array:
	var n_elements = variable_decompress(TYPE_INT)
	var int_array = []
	for i in range(n_elements):
		int_array.append(variable_decompress(TYPE_INT, is_signed))
	return int_array

func variable_decompress(type : int, signed = false):
	var n_bits = decompress_int(VARIABLE_COMPRESS_BITS_FOR_SIZE)
	if type == TYPE_INT:
		return decompress_int(n_bits, signed)
	elif type == TYPE_VECTOR2:
		return decompress_vector(n_bits, signed)
	elif type == TYPE_FLOAT:
		return decompress_float(n_bits, signed)
	else:
		assert(false) #,"variable decompression does not support type for " + str(type))

func decompress_int(inBitCount : int, is_signed = false) -> int:
	if is_signed:
		var neg_mod = -1 if gaffer_read(1) == 1 else 1
		var abs_val = gaffer_read(inBitCount - 1)
		return neg_mod * abs_val
	else:
		return gaffer_read(inBitCount)

func decompress_vector(bits_per_component : int, signed = false) -> Vector2:
	var x = decompress_int(bits_per_component, signed)
	var y = decompress_int(bits_per_component, signed)
	return Vector2(x, y)

func decompress_float(inBitCount : int, signed = false, n_decimals = 3) -> float:
	var float_as_int = decompress_int(inBitCount, signed)
	return float(float_as_int) / pow(10.0, n_decimals)

func decompress_unit_vector():
	var x = decompress_float(UNIT_VECTOR_FLOAT_BITS, true)
	var y = decompress_float(UNIT_VECTOR_FLOAT_BITS, true)
	return Vector2(x, y)

func decompress_quantized_input_vec() -> Vector2:
	var quantized_length = gaffer_read(InputVecQuantizer.BITS_FOR_LENGTH)
	var quantized_degrees = gaffer_read(InputVecQuantizer.BITS_FOR_DEGREES)
	return InputVecQuantizer.quantized_len_and_deg_to_vector(quantized_length, quantized_degrees)

func decompress_class_id() -> int:
	return gaffer_read(N_CLASS_ID_BITS)

func decompress_frame() -> int:
	return gaffer_read(BITS_FOR_FRAME)

func decompress_bool() -> bool:
	return bool(gaffer_read(1))
