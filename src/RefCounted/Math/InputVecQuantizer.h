#ifndef INPUT_VEC_QUANTIZER_H
#define INPUT_VEC_QUANTIZER_H

#include <godot_cpp\core\defs.hpp>
#include <godot_cpp\godot.hpp>
#include <godot_cpp\classes\ref.hpp>
#include <godot_cpp\core\binder_common.hpp>
#include <godot_cpp\variant\utility_functions.hpp>

namespace godot
{

    class InputVecQuantizer : public RefCounted
    {
        GDCLASS(InputVecQuantizer, RefCounted)

    protected:
        static void _bind_methods();

    public:
        static const float INPUT_VEC_LENGTH_SNAP;
        static const int N_MOVEMENT_DIRECTIONS = 16;
        static const float INPUT_VEC_DEGREE_SNAP;
        static const int BITS_FOR_LENGTH = 3;
        static const int BITS_FOR_DEGREES = 4;

        static Vector2 quantize_vec(Vector2 vec);
        static int get_quantized_length(Vector2 vec);
        static int get_quantized_angle(Vector2 vec);
        static float quantized_len_to_length(int quantized_len);
        static float quantized_deg_to_degrees(int quantized_deg);
        static Vector2 quantized_len_and_deg_to_vector(int quantized_len, int quantized_degrees);
    };
}

#endif // INPUT_VEC_QUANTIZER_H
