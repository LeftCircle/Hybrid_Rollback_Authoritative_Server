extends RefCounted
class_name BitStreamWriter

static func gaffer_write_int(bitstream : BitStream, inData : int, inBitCount : int) -> void:
	if inBitCount > 32 or bitstream.scratch_bits > 32:
		assert(false) #," We must handle the case of writing values greater than 32 bits")
	# Shift the data to the left to insert it into the end of the scratch
	# Data is inserted from right to left
	var bits_to_write : int = inData << (BitStream.SCRATCH_SIZE - inBitCount - bitstream.scratch_bits)
	bitstream.scratch = bitstream.scratch | bits_to_write
	bitstream.scratch_bits += inBitCount
	if bitstream.scratch_bits >= BitStream.WORD_SIZE:
		# Flush the word to memory!
		write_scratch_to_buffer(bitstream)
	bitstream.total_bits += inBitCount

static func write_scratch_to_buffer(bitstream : BitStream) -> void:
	# The word is packed in big Endian order
	# Data is inserted into the buffer from right to left
	var data_to_mem : int = (bitstream.scratch >> 32)
	var byte_index : int = 4 * bitstream.word_index
	bitstream.mBuffer[byte_index] = (data_to_mem >> 24) & 0xff
	bitstream.mBuffer[byte_index + 1] = (data_to_mem >> 16) & 0xff
	bitstream.mBuffer[byte_index + 2] = (data_to_mem >> 8) & 0xff
	bitstream.mBuffer[byte_index + 3] = data_to_mem & 0xff
	bitstream.word_index += 1
	bitstream.scratch_bits = max(bitstream.scratch_bits - BitStream.WORD_SIZE, 0)
	bitstream.scratch = bitstream.scratch << BitStream.WORD_SIZE

static func get_byte_array(bitstream : BitStream) -> PackedByteArray:
	flush_scratch_to_buffer(bitstream)
	var word_index_to_grab : int
	if bitstream.word_index < BitStream.SCRATCH_SIZE_BYTES:
		word_index_to_grab = BitStream.SCRATCH_SIZE_BYTES
	else:
		word_index_to_grab = bitstream.word_index + (BitStream.SCRATCH_SIZE_BYTES) - (bitstream.word_index % (BitStream.SCRATCH_SIZE_BYTES))
	return bitstream.mBuffer.slice(0, (4 * word_index_to_grab))

static func flush_scratch_to_buffer(bitstream : BitStream):
	if bitstream.scratch_bits != 0 or bitstream.mBuffer.size() % 4 != 0:
		assert(bitstream.scratch_bits <= BitStream.WORD_SIZE) #,"somehow the scratch is larger than one word")
		#scratch = byteswap_word(scratch)
		write_scratch_to_buffer(bitstream)

static func compress_int_into_x_bits(bitstream : BitStream, inData : int, inBitCount : int, is_signed = false) -> void:
	if is_signed:
		var is_negative : int = 1 if inData < 0 else 0
		gaffer_write_int(bitstream, is_negative, 1)
		gaffer_write_int(bitstream, abs(inData), inBitCount - 1)
	else:
		assert(inData >= 0) #," Cannot pass negative data without sign!")
		gaffer_write_int(bitstream, inData, inBitCount)

static func compress_int_array(bitstream : BitStream, int_array : Array, is_signed = false) -> void:
	var n_elements : int = int_array.size()
	variable_compress(bitstream, n_elements)
	for i in range(n_elements):
		variable_compress(bitstream, int_array[i], is_signed)

static func variable_compress(bitstream : BitStream, value, signed : bool = false):
	var n_bits : int
	if typeof(value) == TYPE_INT:
		n_bits = BaseCompression.n_bits_for_int(value, signed)
		compress_int_into_x_bits(bitstream, n_bits, BitStream.VARIABLE_COMPRESS_BITS_FOR_SIZE)
		compress_int_into_x_bits(bitstream, value, n_bits, signed)
	elif typeof(value) == TYPE_VECTOR2:
		n_bits = BaseCompression.n_bits_for_vector(value, signed)
		compress_int_into_x_bits(bitstream, n_bits / 2, BitStream.VARIABLE_COMPRESS_BITS_FOR_SIZE)
		compress_vector_into_x_bits(bitstream, value, n_bits, signed)
	elif typeof(value) == TYPE_FLOAT:
		n_bits = BaseCompression.n_bits_for_float(value, signed)
		compress_int_into_x_bits(bitstream, n_bits, BitStream.VARIABLE_COMPRESS_BITS_FOR_SIZE)
		compress_float_into_x_bits(value, n_bits, signed)
	else:
		assert(false) #,"variable compression does not support type for " + str(value))

static func compress_vector_into_x_bits(bitstream : BitStream, vec : Vector2, n_bits : int, signed = false):
	assert(n_bits % 2 == 0)
	var bits_per_component : int = n_bits / 2
	var x_int : int = int(round(vec.x))
	var y_int : int = int(round(vec.y))
	compress_int_into_x_bits(bitstream, x_int, bits_per_component, signed)
	compress_int_into_x_bits(bitstream, y_int, bits_per_component, signed)

static func compress_float_into_x_bits(bitstream : BitStream, in_float : float, n_bits : int, signed = false, n_decimals = 3):
	var float_to_int = int(round(in_float * pow(10.0, n_decimals)))
	compress_int_into_x_bits(bitstream, float_to_int, n_bits, signed)

static func compress_bool(bitstream : BitStream, bool_var : bool) -> void:
	gaffer_write_int(bitstream, int(bool_var), 1)

static func compress_unit_vector(bitstream : BitStream, invec : Vector2) -> void:
	compress_float_into_x_bits(bitstream, invec.x, BitStream.UNIT_VECTOR_FLOAT_BITS, true)
	compress_float_into_x_bits(bitstream, invec.y, BitStream.UNIT_VECTOR_FLOAT_BITS, true)

static func compress_instance_id(bitstream : BitStream, instance_id : int) -> void:
	gaffer_write_int(bitstream, instance_id, BitStream.N_CLASS_INSTANCE_BITS)

static func compress_class_id(bitstream : BitStream, class_id : int) -> void:
	assert(class_id <= 878500) #,"id is greater than the max cantor of 'ZZZ'")
	gaffer_write_int(bitstream, class_id, BitStream.N_CLASS_ID_BITS)

static func compress_frame(bitstream : BitStream, frame : int) -> void:
	gaffer_write_int(bitstream, frame, BitStream.BITS_FOR_FRAME)

static func compress_quantized_input_vec(bit_stream : BitStream, input_vec : Vector2) -> void:
	var quantized_length = InputVecQuantizer.get_quantized_length(input_vec)
	var quantized_degrees = InputVecQuantizer.get_quantized_angle(input_vec)
	compress_int_into_x_bits(bit_stream, quantized_length, InputVecQuantizer.BITS_FOR_LENGTH)
	compress_int_into_x_bits(bit_stream, quantized_degrees, InputVecQuantizer.BITS_FOR_DEGREES)

static func write_bits_into(byte_array : PackedByteArray, inData : int, bit_start : int, inBitCount : int) -> PackedByteArray:
	assert(inBitCount <= 32)
	var byte_start : int = bit_start / 8
	var byte_end : int = ((bit_start + inBitCount) / 8) + 1
	var word_end : int = byte_start + 4
	byte_end = max(byte_end, word_end)
	if byte_end > byte_array.size():
		byte_array.resize(byte_end)
	var n_bytes_to_adjust : int = byte_end - byte_start

	var bytes_to_adjust : PackedByteArray = byte_array.slice(byte_start, byte_end)

	var write_stream : BitStream = BitStream.new()
	write_stream.init_buffer(n_bytes_to_adjust)

	# Grab the bits at the start we want to keep
	var bits_at_start : int = bit_start % 8
	var bits_to_keep : int = BitStreamReader.read_arbitrary_bits(bytes_to_adjust, 0, bits_at_start)

	BitStreamWriter.gaffer_write_int(write_stream, bits_to_keep, bits_at_start)
	BitStreamWriter.gaffer_write_int(write_stream, inData, inBitCount)

	# to find how many bits are left over at the end, figure out how many bits are left in the word
	# starting at the byte_start after the inData has been added
	var bits_left_in_word : int = n_bytes_to_adjust * 8 - write_stream.total_bits
	# write the remaining bits from the read stream
	var end_bits_to_keep : int = BitStreamReader.read_arbitrary_bits(bytes_to_adjust, write_stream.total_bits, bits_left_in_word)
	BitStreamWriter.gaffer_write_int(write_stream, end_bits_to_keep, bits_left_in_word)
	var byte_to_rewrite = BitStreamWriter.get_byte_array(write_stream)
	# Write the stream back into the byte array
	for i in range(byte_start, byte_end):
		byte_array[i] = byte_to_rewrite[i - byte_start]
	return byte_array
