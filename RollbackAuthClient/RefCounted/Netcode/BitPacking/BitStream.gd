extends RefCounted
#class_name BitStream

const WORD_SIZE : int = 32
const SCRATCH_SIZE : int = 2 * WORD_SIZE
const FOUR_BYTES : int = 65355
const WORD_SIZE_IN_BYTES : int = 4
const SCRATCH_SIZE_BYTES : int = 2 * WORD_SIZE_IN_BYTES
const MAX_BYTES : int = 1450 * 2
const VARIABLE_COMPRESS_BITS_FOR_SIZE : int = 5
const UNIT_VECTOR_FLOAT_BITS : int = 11
const N_CLASS_INSTANCE_BITS : int = 16
const N_CLASS_ID_BITS : int = 20
const BITS_FOR_N_OBJECTS = 9
const BYTES_FOR_N_BITS = 2
const BYTES_FOR_FRAME = 3
const BITS_FOR_FRAME = BYTES_FOR_FRAME * 8

# a 64 bit scratch so we can write to the buffer 32 bits (4 bytes, or one word) at a time
var scratch : int
var scratch_bits : int
var word_index : int = 0
var total_bits : int = 0
var read_bits : int = 0
var mBuffer : PackedByteArray = []

# func _init():
# 	_init_buffer()

func init_buffer(buffer_size : int = MAX_BYTES) -> void:
	buffer_size = snappedi(buffer_size + 2, WORD_SIZE_IN_BYTES)
	mBuffer.resize(buffer_size)
	mBuffer.fill(0)

func reset():
	scratch = 0
	scratch_bits = 0
	total_bits = 0
	word_index = 0
	read_bits = 0

func byteswap_word(inData : int):
	inData = inData & 0xffffffff
	return (((inData >> 24) & 0xff) |
		((inData >> 8) & 0xff00) |
		((inData << 8) & 0xff0000) |
		((inData << 24) & 0xff000000))
