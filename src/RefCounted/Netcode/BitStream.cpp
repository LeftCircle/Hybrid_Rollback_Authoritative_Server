#include "BitStream.h"

using namespace godot;

void BitStream::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("init_buffer", "buffer_size"), &BitStream::init_buffer);
    ClassDB::bind_method(D_METHOD("reset"), &BitStream::reset);

    ClassDB::bind_method(D_METHOD("get_scratch"), &BitStream::get_scratch);
    ClassDB::bind_method(D_METHOD("set_scratch", "value"), &BitStream::set_scratch);

    ClassDB::bind_method(D_METHOD("get_scratch_bits"), &BitStream::get_scratch_bits);
    ClassDB::bind_method(D_METHOD("set_scratch_bits", "value"), &BitStream::set_scratch_bits);

    ClassDB::bind_method(D_METHOD("get_word_index"), &BitStream::get_word_index);
    ClassDB::bind_method(D_METHOD("set_word_index", "value"), &BitStream::set_word_index);

    ClassDB::bind_method(D_METHOD("get_total_bits"), &BitStream::get_total_bits);
    ClassDB::bind_method(D_METHOD("set_total_bits", "value"), &BitStream::set_total_bits);

    ClassDB::bind_method(D_METHOD("get_read_bits"), &BitStream::get_read_bits);
    ClassDB::bind_method(D_METHOD("set_read_bits", "value"), &BitStream::set_read_bits);

    ClassDB::bind_method(D_METHOD("get_buffer"), &BitStream::get_buffer);
    ClassDB::bind_method(D_METHOD("set_buffer", "value"), &BitStream::set_buffer);

    ClassDB::add_property("BitStream", PropertyInfo(Variant::INT, "scratch"), "set_scratch", "get_scratch");
    ClassDB::add_property("BitStream", PropertyInfo(Variant::INT, "scratch_bits"), "set_scratch_bits", "get_scratch_bits");
    ClassDB::add_property("BitStream", PropertyInfo(Variant::INT, "word_index"), "set_word_index", "get_word_index");
    ClassDB::add_property("BitStream", PropertyInfo(Variant::INT, "total_bits"), "set_total_bits", "get_total_bits");
    ClassDB::add_property("BitStream", PropertyInfo(Variant::INT, "read_bits"), "set_read_bits", "get_read_bits");

    BIND_CONSTANT(WORD_SIZE);
    BIND_CONSTANT(SCRATCH_SIZE);
    BIND_CONSTANT(FOUR_BYTES);
    BIND_CONSTANT(WORD_SIZE_IN_BYTES);
    BIND_CONSTANT(SCRATCH_SIZE_BYTES);
    BIND_CONSTANT(MAX_BYTES);
    BIND_CONSTANT(VARIABLE_COMPRESS_BITS_FOR_SIZE);
    BIND_CONSTANT(UNIT_VECTOR_FLOAT_BITS);
    BIND_CONSTANT(N_CLASS_INSTANCE_BITS);
    BIND_CONSTANT(N_CLASS_ID_BITS);
    BIND_CONSTANT(BITS_FOR_N_OBJECTS);
    BIND_CONSTANT(BYTES_FOR_N_BITS);
    BIND_CONSTANT(BYTES_FOR_FRAME);
    BIND_CONSTANT(BITS_FOR_FRAME);
}

void BitStream::init_buffer(int buffer_size)
{
    buffer_size = UtilityFunctions::snappedi(buffer_size + 2, WORD_SIZE_IN_BYTES);
    mBuffer.resize(buffer_size);
    mBuffer.fill(0);
}

void BitStream::reset()
{
    scratch = 0;
    scratch_bits = 0;
    total_bits = 0;
    word_index = 0;
    read_bits = 0;
}

BitStream::BitStream()
{
    scratch = 0;
    scratch_bits = 0;
    word_index = 0;
    total_bits = 0;
    read_bits = 0;
}

BitStream::~BitStream()
{
}