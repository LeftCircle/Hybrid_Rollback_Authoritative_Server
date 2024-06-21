#ifndef BIT_STREAM_WRITER_H
#define BIT_STREAM_WRITER_H

#include "BaseCompression.h"
#include "BitStreamReader.h"
#include "..\BitStream.h"
#include "..\..\Math\InputVecQuantizer.h"

#include <godot_cpp\classes\ref.hpp>
#include <godot_cpp\core\binder_common.hpp>
#include <godot_cpp\core\defs.hpp>
#include <godot_cpp\variant\utility_functions.hpp>
#include <cassert>

namespace godot
{
	class BitStreamWriter : public RefCounted
	{
		GDCLASS(BitStreamWriter, RefCounted)

	protected:
		static void _bind_methods();

	public:
		static void write_int(BitStream *const bitstream, int inData, int inBitCount);
		static void write_scratch_to_buffer(BitStream *const bitstream);
		static PackedByteArray get_byte_array(BitStream *const bitstream);
		static void flush_scratch_to_buffer(BitStream *const bitstream);
		static void compress_int_into_x_bits(BitStream *const bitstream, int inData, int inBitCount, bool is_signed = false);
		static void compress_int_array(BitStream *const bitstream, Array int_array, bool is_signed = false);
		static void variable_compress(BitStream *const bitstream, Variant value, bool is_signed = false);
		static void compress_vector_into_x_bits(BitStream *const bitstream, Vector2 vec, int n_bits, bool is_signed = false);
		static void compress_float_into_x_bits(BitStream *const bitstream, float in_float, int n_bits, bool is_signed = false, int n_decimals = 3);
		static void compress_bool(BitStream *const bitstream, bool bool_var);
		static void compress_unit_vector(BitStream *const bitstream, Vector2 invec);
		static void compress_instance_id(BitStream *const bitstream, int instance_id);
		static void compress_class_id(BitStream *const bitstream, int class_id);
		static void compress_frame(BitStream *const bitstream, int frame);
		static void compress_quantized_input_vec(BitStream *const bit_stream, Vector2 input_vec);
		static PackedByteArray write_bits_into(PackedByteArray byte_array, int inData, int bit_start, int inBitCount);
	};
}

#endif
