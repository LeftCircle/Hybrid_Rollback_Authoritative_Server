#include "BitStreamWriter.h"

using namespace godot;

void BitStreamWriter::_bind_methods()
{
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("write_int", "bitstream", "inData", "inBitCount"), &BitStreamWriter::write_int);
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("write_scratch_to_buffer", "bitstream"), &BitStreamWriter::write_scratch_to_buffer);
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("get_byte_array", "bitstream"), &BitStreamWriter::get_byte_array);
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("flush_scratch_to_buffer", "bitstream"), &BitStreamWriter::flush_scratch_to_buffer);
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("compress_int_into_x_bits", "bitstream", "inData", "inBitCount", "is_signed"), &BitStreamWriter::compress_int_into_x_bits, DEFVAL(false));
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("compress_int_array", "bitstream", "int_array", "is_signed"), &BitStreamWriter::compress_int_array, DEFVAL(false));
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("variable_compress", "bitstream", "value", "is_signed"), &BitStreamWriter::variable_compress, DEFVAL(false));
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("compress_vector_into_x_bits", "bitstream", "vec", "n_bits", "is_signed"), &BitStreamWriter::compress_vector_into_x_bits, DEFVAL(false));
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("compress_float_into_x_bits", "bitstream", "in_float", "n_bits", "is_signed", "n_decimals"), &BitStreamWriter::compress_float_into_x_bits, DEFVAL(3));
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("compress_bool", "bitstream", "bool_var"), &BitStreamWriter::compress_bool);
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("compress_unit_vector", "bitstream", "invec"), &BitStreamWriter::compress_unit_vector);
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("compress_instance_id", "bitstream", "instance_id"), &BitStreamWriter::compress_instance_id);
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("compress_class_id", "bitstream", "class_id"), &BitStreamWriter::compress_class_id);
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("compress_frame", "bitstream", "frame"), &BitStreamWriter::compress_frame);
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("compress_quantized_input_vec", "bit_stream", "input_vec"), &BitStreamWriter::compress_quantized_input_vec);
	ClassDB::bind_static_method("BitStreamWriter", D_METHOD("write_bits_into", "byte_array", "inData", "bit_start", "inBitCount"), &BitStreamWriter::write_bits_into);
}

void BitStreamWriter::write_int(BitStream &bitstream, int inData, int inBitCount)
{
	assert(inBitCount <= 32 || bitstream.scratch_bits <= 32);
	int bits_to_write = inData << (BitStream::SCRATCH_SIZE - inBitCount - bitstream.scratch_bits);
	bitstream.scratch = bitstream.scratch | bits_to_write;
	bitstream.scratch_bits += inBitCount;
	if (bitstream.scratch_bits >= BitStream::WORD_SIZE)
	{
		write_scratch_to_buffer(bitstream);
	}
	bitstream.total_bits += inBitCount;
}

void BitStreamWriter::write_scratch_to_buffer(BitStream &bitstream)
{
	int data_to_mem = (bitstream.scratch >> 32);
	int byte_index = 4 * bitstream.word_index;
	bitstream.mBuffer[byte_index] = (data_to_mem >> 24) & 0xff;
	bitstream.mBuffer[byte_index + 1] = (data_to_mem >> 16) & 0xff;
	bitstream.mBuffer[byte_index + 2] = (data_to_mem >> 8) & 0xff;
	bitstream.mBuffer[byte_index + 3] = data_to_mem & 0xff;
	bitstream.word_index += 1;
	bitstream.scratch_bits = std::max(bitstream.scratch_bits - BitStream::WORD_SIZE, 0);
	bitstream.scratch = bitstream.scratch << BitStream::WORD_SIZE;
}

PackedByteArray BitStreamWriter::get_byte_array(BitStream &bitstream)
{
	flush_scratch_to_buffer(bitstream);
	int word_index_to_grab;
	if (bitstream.word_index < BitStream::SCRATCH_SIZE_BYTES)
	{
		word_index_to_grab = BitStream::SCRATCH_SIZE_BYTES;
	}
	else
	{
		word_index_to_grab = bitstream.word_index + (BitStream::SCRATCH_SIZE_BYTES) - (bitstream.word_index % (BitStream::SCRATCH_SIZE_BYTES));
	}
	return bitstream.mBuffer.slice(0, (4 * word_index_to_grab));
}

void BitStreamWriter::flush_scratch_to_buffer(BitStream &bitstream)
{
	if (bitstream.scratch_bits != 0 || bitstream.mBuffer.size() % 4 != 0)
	{
		assert(bitstream.scratch_bits <= BitStream::WORD_SIZE);
		write_scratch_to_buffer(bitstream);
	}
}

void BitStreamWriter::compress_int_into_x_bits(BitStream &bitstream, int inData, int inBitCount, bool is_signed)
{
	if (is_signed)
	{
		int is_negative = inData < 0 ? 1 : 0;
		write_int(bitstream, is_negative, 1);
		write_int(bitstream, abs(inData), inBitCount - 1);
	}
	else
	{
		assert(inData >= 0);
		write_int(bitstream, inData, inBitCount);
	}
}

void BitStreamWriter::compress_int_array(BitStream &bitstream, Array int_array, bool is_signed)
{
	int n_elements = int_array.size();
	variable_compress(bitstream, n_elements);
	for (int i = 0; i < n_elements; i++)
	{
		variable_compress(bitstream, int_array[i], is_signed);
	}
}

void BitStreamWriter::variable_compress(BitStream &bitstream, Variant value, bool is_signed)
{
	int n_bits;
	Variant::Type type = value.get_type();
	if (type == Variant::Type::INT)
	{
		n_bits = BaseCompression::n_bits_for_int(value, is_signed);
		compress_int_into_x_bits(bitstream, n_bits, BitStream::VARIABLE_COMPRESS_BITS_FOR_SIZE);
		compress_int_into_x_bits(bitstream, value, n_bits, is_signed);
	}
	else if (type == Variant::Type::VECTOR2)
	{
		n_bits = BaseCompression::n_bits_for_vector(value, is_signed);
		compress_int_into_x_bits(bitstream, n_bits / 2, BitStream::VARIABLE_COMPRESS_BITS_FOR_SIZE);
		compress_vector_into_x_bits(bitstream, value, n_bits, is_signed);
	}
	else if (type == Variant::Type::FLOAT)
	{
		n_bits = BaseCompression::n_bits_for_float(value, is_signed);
		compress_int_into_x_bits(bitstream, n_bits, BitStream::VARIABLE_COMPRESS_BITS_FOR_SIZE);
		compress_float_into_x_bits(bitstream, value, n_bits, is_signed);
	}
	else
	{
		assert(false);
	}
}

void BitStreamWriter::compress_vector_into_x_bits(BitStream &bitstream, Vector2 vec, int n_bits, bool is_signed)
{
	assert(n_bits % 2 == 0);
	int bits_per_component = n_bits / 2;
	int x_int = int(round(vec.x));
	int y_int = int(round(vec.y));
	compress_int_into_x_bits(bitstream, x_int, bits_per_component, is_signed);
	compress_int_into_x_bits(bitstream, y_int, bits_per_component, is_signed);
}

void BitStreamWriter::compress_float_into_x_bits(BitStream &bitstream, float in_float, int n_bits, bool is_signed, int n_decimals)
{
	int float_to_int = int(round(in_float * pow(10.0, n_decimals)));
	compress_int_into_x_bits(bitstream, float_to_int, n_bits, is_signed);
}

void BitStreamWriter::compress_bool(BitStream &bitstream, bool bool_var)
{
	write_int(bitstream, int(bool_var), 1);
}

void BitStreamWriter::compress_unit_vector(BitStream &bitstream, Vector2 invec)
{
	compress_float_into_x_bits(bitstream, invec.x, BitStream::UNIT_VECTOR_FLOAT_BITS, true);
	compress_float_into_x_bits(bitstream, invec.y, BitStream::UNIT_VECTOR_FLOAT_BITS, true);
}

void BitStreamWriter::compress_instance_id(BitStream &bitstream, int instance_id)
{
	write_int(bitstream, instance_id, BitStream::N_CLASS_INSTANCE_BITS);
}

void BitStreamWriter::compress_class_id(BitStream &bitstream, int class_id)
{
	assert(class_id <= 878500);
	write_int(bitstream, class_id, BitStream::N_CLASS_ID_BITS);
}

void BitStreamWriter::compress_frame(BitStream &bitstream, int frame)
{
	write_int(bitstream, frame, BitStream::BITS_FOR_FRAME);
}

void BitStreamWriter::compress_quantized_input_vec(BitStream &bit_stream, Vector2 input_vec)
{
	int quantized_length = InputVecQuantizer::get_quantized_length(input_vec);
	int quantized_degrees = InputVecQuantizer::get_quantized_angle(input_vec);
	compress_int_into_x_bits(bit_stream, quantized_length, InputVecQuantizer::BITS_FOR_LENGTH);
	compress_int_into_x_bits(bit_stream, quantized_degrees, InputVecQuantizer::BITS_FOR_DEGREES);
}

PackedByteArray BitStreamWriter::write_bits_into(PackedByteArray byte_array, int inData, int bit_start, int inBitCount)
{
	assert(inBitCount <= 32);
	int byte_start = bit_start / 8;
	int byte_end = ((bit_start + inBitCount) / 8) + 1;
	int word_end = byte_start + 4;
	byte_end = std::max(byte_end, word_end);
	if (byte_end > byte_array.size())
	{
		byte_array.resize(byte_end);
	}
	PackedByteArray bytes_to_adjust = byte_array.slice(byte_start, byte_end);
	BitStream write_stream;
	write_stream.init_buffer(byte_end - byte_start);
	int bits_at_start = bit_start % 8;
	int bits_to_keep = BitStreamReader::read_arbitrary_bits(bytes_to_adjust, 0, bits_at_start);
	write_int(write_stream, bits_to_keep, bits_at_start);
	write_int(write_stream, inData, inBitCount);
	int bits_left_in_word = (byte_end - byte_start) * 8 - write_stream.total_bits;
	int end_bits_to_keep = BitStreamReader::read_arbitrary_bits(bytes_to_adjust, write_stream.total_bits, bits_left_in_word);
	write_int(write_stream, end_bits_to_keep, bits_left_in_word);
	PackedByteArray byte_to_rewrite = get_byte_array(write_stream);
	for (int i = byte_start; i < byte_end; i++)
	{
		byte_array[i] = byte_to_rewrite[i - byte_start];
	}
	return byte_array;
}