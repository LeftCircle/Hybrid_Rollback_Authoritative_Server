#ifndef COMMAND_FRAME_H
#define COMMAND_FRAME_H

#include <godot_cpp\classes\node.hpp>
#include <godot_cpp\core\binder_common.hpp>
#include <godot_cpp\core\defs.hpp>
#include <godot_cpp\classes\project_settings.hpp>
#include <godot_cpp\variant\utility_functions.hpp>

namespace godot
{
	class CommandFrame : public Node
	{
		GDCLASS(CommandFrame, Node)

	protected:
		static void _bind_methods();

	public:
		static const int MAX_FRAME_NUMBER = 16777216;
		static const int HALF_MAX_FRAME = MAX_FRAME_NUMBER / 2;

		void execute();

		float get_frame_length_sec() { return frame_length_sec; }
		void set_frame_length_sec(const float p_frame_length_sec) { frame_length_sec = p_frame_length_sec; }

		float get_frame_length_msec() { return frame_length_msec; }
		void set_frame_length_msec(const float p_frame_length_msec) { frame_length_msec = p_frame_length_msec; }

		int get_frame() { return frame; }
		void set_frame(const int p_frame) { frame = p_frame; }

		int get_input_buffer() { return input_buffer; }
		void set_input_buffer(const int p_input_buffer) { input_buffer = p_input_buffer; }

		int get_input_frame() { return input_frame; }
		void set_input_frame(const int p_input_frame) { input_frame = p_input_frame; }

		int get_previous_command_frame() { return previous_command_frame; }
		void set_previous_command_frame(const int p_previous_command_frame) { previous_command_frame = p_previous_command_frame; }

		static inline CommandFrame *get_singleton() { return m_static_inst; }

		CommandFrame();
		~CommandFrame();

	private:
		float frame_length_sec;
		float frame_length_msec;
		int frame;
		int input_buffer;

		int input_frame;
		int previous_command_frame;
		static inline CommandFrame *m_static_inst{nullptr};
	};
}

#endif