#include "InputVecQuantizer.h"

using namespace godot;

const float InputVecQuantizer::INPUT_VEC_LENGTH_SNAP = 0.25;
const float InputVecQuantizer::INPUT_VEC_DEGREE_SNAP = 360.0 / float(N_MOVEMENT_DIRECTIONS);

void InputVecQuantizer::_bind_methods()
{
	BIND_CONSTANT(INPUT_VEC_LENGTH_SNAP);
	BIND_CONSTANT(N_MOVEMENT_DIRECTIONS);
	BIND_CONSTANT(INPUT_VEC_DEGREE_SNAP);
	BIND_CONSTANT(BITS_FOR_LENGTH);
	BIND_CONSTANT(BITS_FOR_DEGREES);

	ClassDB::bind_static_method("InputVecQuantizer", D_METHOD("quantize_vec", "vec"), &InputVecQuantizer::quantize_vec);
	ClassDB::bind_static_method("InputVecQuantizer", D_METHOD("get_quantized_length", "vec"), &InputVecQuantizer::get_quantized_length);
	ClassDB::bind_static_method("InputVecQuantizer", D_METHOD("get_quantized_angle", "vec"), &InputVecQuantizer::get_quantized_angle);
	ClassDB::bind_static_method("InputVecQuantizer", D_METHOD("quantized_len_to_length", "quantized_len"), &InputVecQuantizer::quantized_len_to_length);
	ClassDB::bind_static_method("InputVecQuantizer", D_METHOD("quantized_deg_to_degrees", "quantized_deg"), &InputVecQuantizer::quantized_deg_to_degrees);
	ClassDB::bind_static_method("InputVecQuantizer", D_METHOD("quantized_len_and_deg_to_vector", "quantized_len", "quantized_deg"), &InputVecQuantizer::quantized_len_and_deg_to_vector);
}

Vector2 InputVecQuantizer::quantize_vec(Vector2 vec)
{
	float length = vec.length();
	int quantized_len = int(round(length / INPUT_VEC_LENGTH_SNAP));
	float degrees = UtilityFunctions::rad_to_deg(vec.angle());
	int quantized_deg = int(round(degrees / INPUT_VEC_DEGREE_SNAP));
	float quantized_rad = UtilityFunctions::deg_to_rad(quantized_deg * INPUT_VEC_DEGREE_SNAP);
	vec = quantized_len * Vector2(cos(quantized_rad), sin(quantized_rad));
	return vec;
}

int InputVecQuantizer::get_quantized_length(Vector2 vec)
{
	return int(round(vec.length() / INPUT_VEC_LENGTH_SNAP));
}

int InputVecQuantizer::get_quantized_angle(Vector2 vec)
{
	float degrees = UtilityFunctions::rad_to_deg(vec.angle());
	degrees = degrees < 0 ? degrees + 360 : degrees;
	return int(round(degrees / INPUT_VEC_DEGREE_SNAP));
}

float InputVecQuantizer::quantized_len_to_length(int quantized_len)
{
	return quantized_len * INPUT_VEC_LENGTH_SNAP;
}

float InputVecQuantizer::quantized_deg_to_degrees(int quantized_deg)
{
	return quantized_deg * INPUT_VEC_DEGREE_SNAP;
}

Vector2 InputVecQuantizer::quantized_len_and_deg_to_vector(int quantized_len, int quantized_degrees)
{
	float quantized_rad = UtilityFunctions::deg_to_rad(quantized_degrees * INPUT_VEC_DEGREE_SNAP);
	return quantized_len * INPUT_VEC_LENGTH_SNAP * Vector2(cos(quantized_rad), sin(quantized_rad));
}