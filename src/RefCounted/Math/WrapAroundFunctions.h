#ifndef WRAPOUNDFUNCTIONS_H
#define WRAPOUNDFUNCTIONS_H

#include <godot_cpp\classes\ref.hpp>
#include <godot_cpp\core\binder_common.hpp>
#include <godot_cpp\core\defs.hpp>
#include <godot_cpp\variant\utility_functions.hpp>

namespace godot
{
	class WrapAroundFunctions : public RefCounted
	{
		GDCLASS(WrapAroundFunctions, RefCounted)

	protected:
		static void _bind_methods();

	public:
		static bool is_greater_than(const int future, const int past, const int half_max_val);
		static bool is_greater_than_or_equal(const int future, const int past, const int half_max_val);
		static int difference(const int future, const int past, const int max_value, const int half_max_val);
		static int advance(const int value, const int advance_by, const int max_value);
		static int get_max(const int a, const int b, const int half_max_val);
		static int get_previous(const int starting_value, const int n_back, const int max_value);

		WrapAroundFunctions();
		~WrapAroundFunctions();
	};
}

#endif