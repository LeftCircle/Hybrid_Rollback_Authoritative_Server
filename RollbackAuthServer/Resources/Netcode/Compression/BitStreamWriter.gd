extends BitStream
class_name BitStreamWriter

func gaffer_write_int(inData : int, inBitCount : int) -> void:
	if inBitCount > 32:
		assert(false) #," We must handle the case of writing values greater than 32 bits")
	if scratch_bits + inBitCount > 64:
		assert(false) #,"We must handle writing more than 32 bits to a nearly full scratch")
	# Shift the data to the left to insert it into the end of the scratch
	# Data is inserted from right to left
	var bits_to_write : int = inData << scratch_bits
	scratch = scratch | bits_to_write
	scratch_bits += inBitCount
	if scratch_bits >= WORD_SIZE:
		# Flush the word to memory!
		write_word_to_buffer(scratch)
		scratch_bits = scratch_bits - WORD_SIZE
		scratch = scratch >> WORD_SIZE
	total_bits += inBitCount

func write_word_to_buffer(word : int) -> void:
	# The word is packed in big Endian order
	# Data is inserted into the buffer from right to left
	var data_to_mem : int = word & 0xffffffff
	var byte_index : int = 4 * word_index
	mBuffer[byte_index] = data_to_mem & 0xff
	mBuffer[byte_index + 1] = data_to_mem >> 8 & 0xff
	mBuffer[byte_index + 2] = data_to_mem >> 16 & 0xff
	mBuffer[byte_index + 3] = data_to_mem >> 24 & 0xff
	word_index += 1

func get_byte_array() -> PackedByteArray:
	flush_scratch_to_buffer()
	var word_index_to_grab : int
	if word_index < SCRATCH_SIZE_BYTES:
		word_index_to_grab = SCRATCH_SIZE_BYTES
	else:
		word_index_to_grab = word_index + (SCRATCH_SIZE_BYTES) - (word_index % (SCRATCH_SIZE_BYTES))
	return mBuffer.slice(0, (4 * word_index_to_grab))

func flush_scratch_to_buffer():
	if scratch_bits != 0 or mBuffer.size() % 4 != 0:
		assert(scratch_bits <= WORD_SIZE) #,"somehow the scratch is larger than one word")
		#scratch = byteswap_word(scratch)
		write_word_to_buffer(scratch)

func compress_int_into_x_bits(inData : int, inBitCount : int, is_signed = false) -> void:
	if is_signed:
		var is_negative : int = 1 if inData < 0 else 0
		gaffer_write_int(is_negative, 1)
		gaffer_write_int(abs(inData), inBitCount - 1)
	else:
		assert(inData >= 0) #," Cannot pass negative data without sign!")
		gaffer_write_int(inData, inBitCount)

func compress_int_array(int_array : Array, is_signed = false) -> void:
	var n_elements : int = int_array.size()
	variable_compress(n_elements)
	for i in range(n_elements):
		variable_compress(int_array[i], is_signed)

func variable_compress(value, signed : bool = false):
	var n_bits : int
	if typeof(value) == TYPE_INT:
		n_bits = BaseCompression.n_bits_for_int(value, signed)
		compress_int_into_x_bits(n_bits, VARIABLE_COMPRESS_BITS_FOR_SIZE)
		compress_int_into_x_bits(value, n_bits, signed)
	elif typeof(value) == TYPE_VECTOR2:
		n_bits = BaseCompression.n_bits_for_vector(value, signed)
		compress_int_into_x_bits(n_bits / 2, VARIABLE_COMPRESS_BITS_FOR_SIZE)
		compress_vector_into_x_bits(value, n_bits, signed)
	elif typeof(value) == TYPE_FLOAT:
		n_bits = BaseCompression.n_bits_for_float(value, signed)
		compress_int_into_x_bits(n_bits, VARIABLE_COMPRESS_BITS_FOR_SIZE)
		compress_float_into_x_bits(value, n_bits, signed)
	else:
		assert(false) #,"variable compression does not support type for " + str(value))

func compress_vector_into_x_bits(vec : Vector2, n_bits : int, signed = false):
	assert(n_bits % 2 == 0)
	var bits_per_component : int = n_bits / 2
	var x_int : int = int(round(vec.x))
	var y_int : int = int(round(vec.y))
	compress_int_into_x_bits(x_int, bits_per_component, signed)
	compress_int_into_x_bits(y_int, bits_per_component, signed)

func compress_float_into_x_bits(in_float : float, n_bits : int, signed = false, n_decimals = 3):
	var float_to_int = int(round(in_float * pow(10.0, n_decimals)))
	compress_int_into_x_bits(float_to_int, n_bits, signed)

func compress_bool(bool_var : bool) -> void:
	gaffer_write_int(int(bool_var), 1)

func compress_unit_vector(invec : Vector2) -> void:
	compress_float_into_x_bits(invec.x, UNIT_VECTOR_FLOAT_BITS, true)
	compress_float_into_x_bits(invec.y, UNIT_VECTOR_FLOAT_BITS, true)

func compress_quantized_input_vec(input_vec : Vector2) -> void:
	var quantized_length = InputVecQuantizer.get_quantized_length(input_vec)
	var quantized_degrees = InputVecQuantizer.get_quantized_angle(input_vec)
	compress_int_into_x_bits(quantized_length, InputVecQuantizer.BITS_FOR_LENGTH)
	compress_int_into_x_bits(quantized_degrees, InputVecQuantizer.BITS_FOR_DEGREES)

# TO DO -> optimize this so we don't have to find the required bits each time
func compress_enum(enum_value : int, n_enums : int):
	var required_bits = BaseCompression.n_bits_for_int(n_enums)
	compress_int_into_x_bits(enum_value, required_bits)

func compress_class_instance(instance_id : int) -> void:
	gaffer_write_int(instance_id, N_CLASS_INSTANCE_BITS)

func compress_class_id(class_id : int) -> void:
	assert(class_id <= 878500) #,"id is greater than the max cantor of 'ZZZ'")
	gaffer_write_int(class_id, N_CLASS_ID_BITS)

func compress_frame(frame : int) -> void:
	gaffer_write_int(frame, BITS_FOR_FRAME)
