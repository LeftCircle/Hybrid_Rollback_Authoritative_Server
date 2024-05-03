#include "BaseCompression.h"

using namespace godot;

void BaseCompression::_bind_methods()
{
	// Be sure to bind the default arguments as well
	// And the static functions
	BIND_CONSTANT(VARIABLE_COMPRESS_FLOATING_POINT_PRECISION);
	BIND_CONSTANT(VARIABLE_COMPRESS_FLOATING_POINT_SCALE);

	ClassDB::bind_static_method("BaseCompression", D_METHOD("n_bits_for_int", "val", "is_signed"), &BaseCompression::n_bits_for_int, DEFVAL(false));
	ClassDB::bind_static_method("BaseCompression", D_METHOD("compress_int_to_x_bytes", "inData", "n_bytes"), &BaseCompression::compress_int_to_x_bytes);
	ClassDB::bind_static_method("BaseCompression", D_METHOD("decompress_byte_array_to_int", "byte_array"), &BaseCompression::decompress_byte_array_to_int);
	ClassDB::bind_static_method("BaseCompression", D_METHOD("n_bits_for_vector", "vec", "is_signed"), &BaseCompression::n_bits_for_vector, DEFVAL(false));
	ClassDB::bind_static_method("BaseCompression", D_METHOD("n_bits_for_float", "val", "is_signed"), &BaseCompression::n_bits_for_float, DEFVAL(false));
}

int BaseCompression::n_bits_for_int(int val, bool is_signed)
{
	val = abs(val);
	int bits = 1;
	int max_value = 1;
	while (true)
	{
		max_value = (1 << bits) - 1;
		if (max_value >= val || bits >= 64)
		{
			break;
		}
		bits += 1;
	}
	if (is_signed)
	{
		bits += 1;
	}
	return bits;
}

PackedByteArray BaseCompression::compress_int_to_x_bytes(int inData, int n_bytes)
{
	PackedByteArray byte_array;
	for (int i = 0; i < n_bytes; i++)
	{
		byte_array.append(inData & 0xff);
		inData = inData >> 8;
	}
	return byte_array;
}

int BaseCompression::decompress_byte_array_to_int(PackedByteArray byte_array)
{
	int val = 0;
	int n_bytes = byte_array.size();
	for (int i = 0; i < n_bytes; i++)
	{
		val = val | (byte_array[i] << (8 * i));
	}
	return val;
}

int BaseCompression::n_bits_for_vector(Vector2 vec, bool is_signed)
{
	float max_val = UtilityFunctions::maxf(abs(vec.x), abs(vec.y));
	int n_bits = n_bits_for_int(int(round(max_val)), is_signed);
	return 2 * n_bits;
}

int BaseCompression::n_bits_for_float(float val, bool is_signed)
{
	int int_val = int(round(val * VARIABLE_COMPRESS_FLOATING_POINT_SCALE));
	return n_bits_for_int(int_val, is_signed);
}