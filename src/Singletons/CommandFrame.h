#ifndef COMMAND_FRAME_H
#define COMMAND_FRAME_H

#include <godot_cpp\classes\node.hpp>
#include <godot_cpp\core\binder_common.hpp>
#include <godot_cpp\core\defs.hpp>
#include <godot_cpp\classes\project_settings.hpp>
#include <godot_cpp\variant\utility_functions.hpp>

namespace godot
{
	class S_CommandFrame : public Node
	{
		GDCLASS(S_CommandFrame, Node)

	protected:
		static void _bind_methods();

	public:
		const int MAX_FRAME_NUMBER = 16777215;
		const int MAX_FRAME_FOR_MOD = MAX_FRAME_NUMBER + 1;
		const int HALF_MAX_FRAME = MAX_FRAME_NUMBER / 2;

		float frame_length_sec = 1.0 / float(ProjectSettings::get_singleton()->get_setting("physics/common/physics_ticks_per_second", 60));
		float frame_length_msec = frame_length_sec * 1000;
		int frame = 0;
		int input_buffer = ProjectSettings::get_singleton()->get_setting("global/input_buffer", 0);

		int input_frame = 0;
		int previous_command_frame = -1;

		void execute();

		S_CommandFrame();
		~S_CommandFrame();
	};
}

#endif