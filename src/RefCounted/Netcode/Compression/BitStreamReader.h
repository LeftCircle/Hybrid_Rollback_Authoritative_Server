#ifndef BIT_STREAM_READER_H
#define BIT_STREAM_READER_H

#include "BaseCompression.h"
#include "..\BitStream.h"
#include "..\..\Math\InputVecQuantizer.h"

#include <cassert>

namespace godot
{
    class BitStreamReader : public RefCounted
    {
        GDCLASS(BitStreamReader, RefCounted)
    protected:
        static void _bind_methods();

    public:
        static void init_read(BitStream &bit_stream, PackedByteArray new_buffer);
        static int read(BitStream &bit_stream, int x_bits);
        static bool is_finished(BitStream &bit_stream);
        static void read_word(BitStream &bit_stream);
        static Array decompress_int_array(BitStream &bit_stream, bool is_signed = false);
        static Variant variable_decompress(BitStream &bit_stream, Variant::Type type, bool is_signed = false);
        static int decompress_int(BitStream &bit_stream, int inBitCount, bool is_signed = false);
        static Vector2 decompress_vector(BitStream &bit_stream, int bits_per_component, bool is_signed = false);
        static float decompress_float(BitStream &bit_stream, int inBitCount, bool is_signed = false, int n_decimals = 3);
        static Vector2 decompress_unit_vector(BitStream &bit_stream);
        static int decompress_class_id(BitStream &bit_stream);
        static int decompress_instance_id(BitStream &bit_stream);
        static int decompress_frame(BitStream &bit_stream);
        static bool decompress_bool(BitStream &bit_stream);
        static Vector2 decompress_quantized_input_vec(BitStream &bit_stream);
        static int read_arbitrary_bits(PackedByteArray byte_array, int bit_start, int n_bits);
    };
}

#endif