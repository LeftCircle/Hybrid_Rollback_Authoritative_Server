#include "CommandFrame.h"

using namespace godot;

void S_CommandFrame::_bind_methods()
{
	BIND_CONSTANT(MAX_FRAME_NUMBER);
	BIND_CONSTANT(HALF_MAX_FRAME);

	ClassDB::bind_method(D_METHOD("execute"), &S_CommandFrame::execute);

	ClassDB::bind_method(D_METHOD("get_frame"), &S_CommandFrame::get_frame);
	ClassDB::bind_method(D_METHOD("set_frame", "frame"), &S_CommandFrame::set_frame);
	ClassDB::bind_method(D_METHOD("get_frame_length_sec"), &S_CommandFrame::get_frame_length_sec);
	ClassDB::bind_method(D_METHOD("set_frame_length_sec", "frame_length_sec"), &S_CommandFrame::set_frame_length_sec);
	ClassDB::bind_method(D_METHOD("get_frame_length_msec"), &S_CommandFrame::get_frame_length_msec);
	ClassDB::bind_method(D_METHOD("set_frame_length_msec", "frame_length_msec"), &S_CommandFrame::set_frame_length_msec);
	ClassDB::bind_method(D_METHOD("get_input_buffer"), &S_CommandFrame::get_input_buffer);
	ClassDB::bind_method(D_METHOD("set_input_buffer", "input_buffer"), &S_CommandFrame::set_input_buffer);
	ClassDB::bind_method(D_METHOD("get_input_frame"), &S_CommandFrame::get_input_frame);
	ClassDB::bind_method(D_METHOD("set_input_frame", "input_frame"), &S_CommandFrame::set_input_frame);
	ClassDB::bind_method(D_METHOD("get_previous_command_frame"), &S_CommandFrame::get_previous_command_frame);
	ClassDB::bind_method(D_METHOD("set_previous_command_frame", "previous_command_frame"), &S_CommandFrame::set_previous_command_frame);

	ClassDB::add_property("S_CommandFrame", PropertyInfo(Variant::INT, "frame"), "set_frame", "get_frame");
	ClassDB::add_property("S_CommandFrame", PropertyInfo(Variant::FLOAT, "frame_length_sec"), "set_frame_length_sec", "get_frame_length_sec");
	ClassDB::add_property("S_CommandFrame", PropertyInfo(Variant::FLOAT, "frame_length_msec"), "set_frame_length_msec", "get_frame_length_msec");
	ClassDB::add_property("S_CommandFrame", PropertyInfo(Variant::INT, "input_buffer"), "set_input_buffer", "get_input_buffer");
	ClassDB::add_property("S_CommandFrame", PropertyInfo(Variant::INT, "input_frame"), "set_input_frame", "get_input_frame");
	ClassDB::add_property("S_CommandFrame", PropertyInfo(Variant::INT, "previous_command_frame"), "set_previous_command_frame", "get_previous_command_frame");
}

void S_CommandFrame::execute()
{
	previous_command_frame = frame;
	frame = (frame + 1) % MAX_FRAME_NUMBER;
	input_frame = UtilityFunctions::posmod(frame - input_buffer, MAX_FRAME_NUMBER);
}

S_CommandFrame::S_CommandFrame()
{
	frame_length_sec = 1.0 / float(ProjectSettings::get_singleton()->get_setting("physics/common/physics_ticks_per_second", 60));
	frame_length_msec = frame_length_sec * 1000;
	frame = 0;
	input_buffer = ProjectSettings::get_singleton()->get_setting("global/input_buffer", 0);
	input_frame = 0;
	previous_command_frame = -1;
}

S_CommandFrame::~S_CommandFrame()
{
}