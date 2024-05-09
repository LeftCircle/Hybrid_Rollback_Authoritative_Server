#ifndef BITSTREAM_H
#define BITSTREAM_H

#include <godot_cpp\classes\ref.hpp>
#include <godot_cpp\core\binder_common.hpp>
#include <godot_cpp\core\defs.hpp>
#include <godot_cpp\variant\utility_functions.hpp>

#include "core/attributes.hpp"
// #include "util/bind.hpp"

namespace godot
{
	class BitStream : public RefCounted
	{
		GDCLASS(BitStream, RefCounted)
		friend class BitStreamWriter;
		friend class BitStreamReader;

	public:
		static const int WORD_SIZE = 32;
		static const int SCRATCH_SIZE = 2 * WORD_SIZE;
		static const int FOUR_BYTES = 65355;
		static const int WORD_SIZE_IN_BYTES = 4;
		static const int SCRATCH_SIZE_BYTES = 2 * WORD_SIZE_IN_BYTES;
		static const int MAX_BYTES = 1450 * 2;
		static const int VARIABLE_COMPRESS_BITS_FOR_SIZE = 5;
		static const int UNIT_VECTOR_FLOAT_BITS = 11;
		static const int N_CLASS_INSTANCE_BITS = 16;
		static const int N_CLASS_ID_BITS = 20;
		static const int BITS_FOR_N_OBJECTS = 9;
		static const int BYTES_FOR_N_BITS = 2;
		static const int BYTES_FOR_FRAME = 3;
		static const int BITS_FOR_FRAME = BYTES_FOR_FRAME * 8;

	protected:
		int64_t scratch;
		int scratch_bits;
		int word_index;
		int total_bits;
		int read_bits;
		PackedByteArray mBuffer;

		static void _bind_methods();

	public:
		void init_buffer(int buffer_size);
		void reset();

		[[property]] int get_scratch() { return scratch; }
		[[property]] int get_scratch_bits() { return scratch_bits; }
		[[property]] int get_word_index() { return word_index; }
		[[property]] int get_total_bits() { return total_bits; }
		[[property]] int get_read_bits() { return read_bits; }

		[[property]] void set_scratch(const int value) { scratch = value; }
		[[property]] void set_scratch_bits(const int value) { scratch_bits = value; }
		[[property]] void set_word_index(const int value) { word_index = value; }
		[[property]] void set_total_bits(const int value) { total_bits = value; }
		[[property]] void set_read_bits(const int value) { read_bits = value; }

		PackedByteArray get_buffer() { return mBuffer; }
		void set_buffer(PackedByteArray value) { mBuffer = value; }

		BitStream();
		~BitStream();
	};
}

#endif