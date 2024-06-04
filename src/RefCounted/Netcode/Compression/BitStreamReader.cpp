#include "BitStreamReader.h"

using namespace godot;

void BitStreamReader::_bind_methods()
{
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("init_read", "bit_stream", "new_buffer"), &BitStreamReader::init_read);
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("read", "bit_stream", "x_bits"), &BitStreamReader::read);
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("is_finished", "bit_stream"), &BitStreamReader::is_finished);
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("read_word", "bit_stream"), &BitStreamReader::read_word);
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("decompress_int_array", "bit_stream", "is_signed"), &BitStreamReader::decompress_int_array, DEFVAL(false));
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("variable_decompress", "bit_stream", "type", "is_signed"), &BitStreamReader::variable_decompress, DEFVAL(false));
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("decompress_int", "bit_stream", "inBitCount", "is_signed"), &BitStreamReader::decompress_int, DEFVAL(false));
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("decompress_vector", "bit_stream", "bits_per_component", "is_signed"), &BitStreamReader::decompress_vector, DEFVAL(false));
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("decompress_float", "bit_stream", "inBitCount", "is_signed", "n_decimals"), &BitStreamReader::decompress_float, DEFVAL(3));
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("decompress_unit_vector", "bit_stream"), &BitStreamReader::decompress_unit_vector);
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("decompress_class_id", "bit_stream"), &BitStreamReader::decompress_class_id);
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("decompress_instance_id", "bit_stream"), &BitStreamReader::decompress_instance_id);
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("decompress_frame", "bit_stream"), &BitStreamReader::decompress_frame);
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("decompress_bool", "bit_stream"), &BitStreamReader::decompress_bool);
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("decompress_quantized_input_vec", "bit_stream"), &BitStreamReader::decompress_quantized_input_vec);
	ClassDB::bind_static_method("BitStreamReader", D_METHOD("read_arbitrary_bits", "byte_array", "bit_start", "n_bits"), &BitStreamReader::read_arbitrary_bits);
}

void BitStreamReader::init_read(BitStream *const bit_stream, PackedByteArray new_buffer)
{
	PackedByteArray bytes_for_bits = new_buffer.slice(-BitStream::BYTES_FOR_N_BITS);
	bit_stream->total_bits = BaseCompression::decompress_byte_array_to_int(bytes_for_bits);
	bit_stream->mBuffer = new_buffer;
	bit_stream->scratch = 0;
	bit_stream->scratch_bits = 0;
	bit_stream->read_bits = 0;
	bit_stream->word_index = 0;
}

int BitStreamReader::read(BitStream *const bit_stream, int x_bits)
{
	if (bit_stream->scratch_bits < x_bits)
	{
		read_word(bit_stream);
	}
	int val = ((1 << x_bits) - 1) & (bit_stream->scratch >> bit_stream->scratch_bits - x_bits);
	bit_stream->scratch_bits -= x_bits;
	bit_stream->read_bits += x_bits;
	return val;
}

bool BitStreamReader::is_finished(BitStream *const bit_stream)
{
	assert(bit_stream->read_bits <= bit_stream->total_bits);
	return bit_stream->read_bits == bit_stream->total_bits;
}

void BitStreamReader::read_word(BitStream *const bit_stream)
{
	bit_stream->scratch = bit_stream->scratch << BitStream::WORD_SIZE;
	int buffer_index = bit_stream->word_index * 4;
	// static cast to an int64_t to avoid overflow
	bit_stream->scratch = bit_stream->scratch | (static_cast<int64_t>(bit_stream->mBuffer[buffer_index]) << 24);
	bit_stream->scratch = bit_stream->scratch | (static_cast<int64_t>(bit_stream->mBuffer[buffer_index + 1]) << 16);
	bit_stream->scratch = bit_stream->scratch | (static_cast<int64_t>(bit_stream->mBuffer[buffer_index + 2]) << 8);
	bit_stream->scratch = bit_stream->scratch | (static_cast<int64_t>(bit_stream->mBuffer[buffer_index + 3]));
	bit_stream->scratch_bits += BitStream::WORD_SIZE;
	bit_stream->word_index += 1;
}

Array BitStreamReader::decompress_int_array(BitStream *const bit_stream, bool is_signed)
{
	int n_elements = variable_decompress(bit_stream, Variant::INT);
	Array int_array;
	for (int i = 0; i < n_elements; i++)
	{
		int_array.append(variable_decompress(bit_stream, Variant::INT, is_signed));
	}
	return int_array;
}

Variant BitStreamReader::variable_decompress(BitStream *const bit_stream, Variant::Type type, bool is_signed)
{
	int n_bits = decompress_int(bit_stream, BitStream::VARIABLE_COMPRESS_BITS_FOR_SIZE);
	if (type == Variant::INT)
	{
		return decompress_int(bit_stream, n_bits, is_signed);
	}
	else if (type == Variant::VECTOR2)
	{
		return decompress_vector(bit_stream, n_bits, is_signed);
	}
	else if (type == Variant::FLOAT)
	{
		return decompress_float(bit_stream, n_bits, is_signed);
	}
	else
	{
		assert(false);
	}
}

int BitStreamReader::decompress_int(BitStream *const bit_stream, int inBitCount, bool is_signed)
{
	if (is_signed)
	{
		int neg_mod = read(bit_stream, 1) == 1 ? -1 : 1;
		int abs_val = read(bit_stream, inBitCount - 1);
		return neg_mod * abs_val;
	}
	else
	{
		return read(bit_stream, inBitCount);
	}
}

Vector2 BitStreamReader::decompress_vector(BitStream *const bit_stream, int bits_per_component, bool is_signed)
{
	int x = decompress_int(bit_stream, bits_per_component, is_signed);
	int y = decompress_int(bit_stream, bits_per_component, is_signed);
	return Vector2(x, y);
}

float BitStreamReader::decompress_float(BitStream *const bit_stream, int inBitCount, bool is_signed, int n_decimals)
{
	int float_as_int = decompress_int(bit_stream, inBitCount, is_signed);
	return float(float_as_int) / pow(10.0, n_decimals);
}

Vector2 BitStreamReader::decompress_unit_vector(BitStream *const bit_stream)
{
	float x = decompress_float(bit_stream, BitStream::UNIT_VECTOR_FLOAT_BITS, true);
	float y = decompress_float(bit_stream, BitStream::UNIT_VECTOR_FLOAT_BITS, true);
	return Vector2(x, y);
}

int BitStreamReader::decompress_class_id(BitStream *const bit_stream)
{
	return read(bit_stream, BitStream::N_CLASS_ID_BITS);
}

int BitStreamReader::decompress_instance_id(BitStream *const bit_stream)
{
	return read(bit_stream, BitStream::N_CLASS_INSTANCE_BITS);
}

int BitStreamReader::decompress_frame(BitStream *const bit_stream)
{
	return read(bit_stream, BitStream::BITS_FOR_FRAME);
}

bool BitStreamReader::decompress_bool(BitStream *const bit_stream)
{
	return bool(read(bit_stream, 1));
}

Vector2 BitStreamReader::decompress_quantized_input_vec(BitStream *const bit_stream)
{
	int quantized_length = read(bit_stream, InputVecQuantizer::BITS_FOR_LENGTH);
	int quantized_degrees = read(bit_stream, InputVecQuantizer::BITS_FOR_DEGREES);
	return InputVecQuantizer::quantized_len_and_deg_to_vector(quantized_length, quantized_degrees);
}

int BitStreamReader::read_arbitrary_bits(PackedByteArray byte_array, int bit_start, int n_bits)
{
	assert(n_bits <= 32);
	int byte_start = (bit_start) / 8;
	int byte_end = ((bit_start + n_bits) / 8) + 1;
	int word_end = byte_start + 4;
	byte_end = std::max(byte_end, word_end);
	if (byte_end > byte_array.size())
	{
		byte_array.resize(byte_end);
	}
	PackedByteArray bytes_to_read = byte_array.slice(byte_start, byte_end);
	int n_junk_bits_at_start = (bit_start) % 8;
	BitStream new_stream;
	BitStreamReader::init_read(&new_stream, bytes_to_read);
	int _junk_bits_at_start = BitStreamReader::read(&new_stream, n_junk_bits_at_start);
	int result = BitStreamReader::read(&new_stream, n_bits);
	return result;
}