#include "CommandFrame.h"

using namespace godot;

void S_CommandFrame::_bind_methods()
{
}

void S_CommandFrame::execute()
{
    previous_command_frame = frame;
    frame = (frame + 1) % MAX_FRAME_FOR_MOD;
    input_frame = UtilityFunctions::posmod(frame - input_buffer, MAX_FRAME_FOR_MOD);
}

S_CommandFrame::S_CommandFrame()
{
}

S_CommandFrame::~S_CommandFrame()
{
}