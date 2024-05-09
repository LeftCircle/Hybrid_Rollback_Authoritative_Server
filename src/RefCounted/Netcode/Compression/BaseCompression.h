#ifndef BASE_COMPRESSION_H
#define BASE_COMPRESSION_H

#include <godot_cpp\classes\ref.hpp>
#include <godot_cpp\core\binder_common.hpp>
#include <godot_cpp\core\defs.hpp>
#include <godot_cpp\variant\utility_functions.hpp>
#include <cassert>

namespace godot
{
	class BaseCompression : public RefCounted
	{
		GDCLASS(BaseCompression, RefCounted)
	public:
		static const int VARIABLE_COMPRESS_FLOATING_POINT_PRECISION = 3;
		static const int VARIABLE_COMPRESS_FLOATING_POINT_SCALE = 1000;

	protected:
		static void _bind_methods();

	public:
		static int n_bits_for_int(int val, bool is_signed = false);
		static PackedByteArray compress_int_to_x_bytes(int inData, int n_bytes);
		static int decompress_byte_array_to_int(PackedByteArray byte_array);
		static int n_bits_for_vector(Vector2 vec, bool is_signed = false);
		static int n_bits_for_float(float val, bool is_signed = false);
	};
}

#endif