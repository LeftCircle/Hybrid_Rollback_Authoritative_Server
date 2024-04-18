extends RefCounted
class_name BitStreamReader


# The array MUST have the last x bytes be the total number of bits
static func init_read(bit_stream : BitStream, new_buffer : PackedByteArray) -> void:
	var bytes_for_bits : PackedByteArray = new_buffer.slice(-BitStream.BYTES_FOR_N_BITS)
	bit_stream.total_bits = BaseCompression.decompress_byte_array_to_int(bytes_for_bits)
	bit_stream.mBuffer = new_buffer
	bit_stream.scratch = 0
	bit_stream.scratch_bits = 0
	bit_stream.read_bits = 0
	bit_stream.word_index = 0

static func gaffer_read(bit_stream : BitStream, x_bits : int) -> int:
	if bit_stream.scratch_bits < x_bits:
		read_word(bit_stream)
	var val : int = ((1 << x_bits) - 1) & (bit_stream.scratch >> bit_stream.scratch_bits - x_bits)
	bit_stream.scratch_bits -= x_bits
	bit_stream.read_bits += x_bits
	return val

static func is_finished(bit_stream : BitStream) -> bool:
	assert(bit_stream.read_bits <= bit_stream.total_bits) #,"assert_debug")
	return bit_stream.read_bits == bit_stream.total_bits

static func read_word(bit_stream : BitStream) -> void:
	bit_stream.scratch = bit_stream.scratch << BitStream.WORD_SIZE
	var buffer_index : int = bit_stream.word_index * 4
	bit_stream.scratch = bit_stream.scratch | (bit_stream.mBuffer[buffer_index] << 24)
	bit_stream.scratch = bit_stream.scratch | (bit_stream.mBuffer[buffer_index + 1] << 16)
	bit_stream.scratch = bit_stream.scratch | (bit_stream.mBuffer[buffer_index + 2] << 8)
	bit_stream.scratch = bit_stream.scratch | (bit_stream.mBuffer[buffer_index + 3])
	bit_stream.scratch_bits += BitStream.WORD_SIZE
	bit_stream.word_index += 1

static func decompress_int_array(bit_stream : BitStream, is_signed = false) -> Array:
	var n_elements = variable_decompress(bit_stream, TYPE_INT)
	var int_array = []
	for i in range(n_elements):
		int_array.append(variable_decompress(bit_stream, TYPE_INT, is_signed))
	return int_array

static func variable_decompress(bit_stream : BitStream, type : int, signed = false):
	var n_bits = decompress_int(bit_stream, BitStream.VARIABLE_COMPRESS_BITS_FOR_SIZE)
	if type == TYPE_INT:
		return decompress_int(bit_stream, n_bits, signed)
	elif type == TYPE_VECTOR2:
		return decompress_vector(bit_stream, n_bits, signed)
	elif type == TYPE_FLOAT:
		return decompress_float(bit_stream, n_bits, signed)
	else:
		assert(false) #,"variable decompression does not support type for " + str(type))

static func decompress_int(bit_stream : BitStream, inBitCount : int, is_signed = false) -> int:
	if is_signed:
		var neg_mod = -1 if gaffer_read(bit_stream, 1) == 1 else 1
		var abs_val = gaffer_read(bit_stream, inBitCount - 1)
		return neg_mod * abs_val
	else:
		return gaffer_read(bit_stream, inBitCount)

static func decompress_vector(bit_stream : BitStream, bits_per_component : int, signed = false) -> Vector2:
	var x = decompress_int(bit_stream, bits_per_component, signed)
	var y = decompress_int(bit_stream, bits_per_component, signed)
	return Vector2(x, y)

static func decompress_float(bit_stream : BitStream, inBitCount : int, signed = false, n_decimals = 3) -> float:
	var float_as_int = decompress_int(bit_stream, inBitCount, signed)
	return float(float_as_int) / pow(10.0, n_decimals)

static func decompress_unit_vector(bit_stream : BitStream):
	var x = decompress_float(bit_stream, BitStream.UNIT_VECTOR_FLOAT_BITS, true)
	var y = decompress_float(bit_stream, BitStream.UNIT_VECTOR_FLOAT_BITS, true)
	return Vector2(x, y)

static func decompress_class_id(bit_stream : BitStream) -> int:
	return gaffer_read(bit_stream, BitStream.N_CLASS_ID_BITS)

static func decompress_instance_id(bit_stream : BitStream) -> int:
	return gaffer_read(bit_stream, BitStream.N_CLASS_INSTANCE_BITS)

static func decompress_frame(bit_stream : BitStream) -> int:
	return gaffer_read(bit_stream, BitStream.BITS_FOR_FRAME)

static func decompress_bool(bit_stream : BitStream) -> bool:
	return bool(gaffer_read(bit_stream, 1))

static func decompress_quantized_input_vec(bit_stream : BitStream) -> Vector2:
	var quantized_length = gaffer_read(bit_stream, InputVecQuantizer.BITS_FOR_LENGTH)
	var quantized_degrees = gaffer_read(bit_stream, InputVecQuantizer.BITS_FOR_DEGREES)
	return InputVecQuantizer.quantized_len_and_deg_to_vector(quantized_length, quantized_degrees)

## Reads the byte array starting with bit i (zero indexed) and reading n_bits
static func read_arbitrary_bits(byte_array : PackedByteArray, bit_start : int, n_bits : int) -> int:
	assert(n_bits <= 32) #,"assert_debug")
	# The one is added because bit_start is zero inexed
	var byte_start : int = (bit_start) / 8
	var byte_end : int = ((bit_start + n_bits) / 8) + 1
	# We have to at least read a word in
	var word_end = byte_start + 4
	byte_end = max(byte_end, word_end)
	if byte_end > byte_array.size():
		byte_array.resize(byte_end)
	var bytes_to_read : PackedByteArray = byte_array.slice(byte_start, byte_end)

	var n_junk_bits_at_start : int = (bit_start) % 8
	var new_stream = BitStream.new()
	BitStreamReader.init_read(new_stream, bytes_to_read)
	var _junk_bits_at_start : int = BitStreamReader.gaffer_read(new_stream, n_junk_bits_at_start)
	var result : int = BitStreamReader.gaffer_read(new_stream, n_bits)
	return result
