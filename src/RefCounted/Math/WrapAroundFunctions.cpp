#include "WrapAroundFunctions.h"

using namespace godot;

void WrapAroundFunctions::_bind_methods()
{
	ClassDB::bind_static_method("WrapAroundFunctions", D_METHOD("is_greater_than", "future", "past", "half_max_val"), &WrapAroundFunctions::is_greater_than);
	ClassDB::bind_static_method("WrapAroundFunctions", D_METHOD("is_greater_than_or_equal", "future", "past", "half_max_val"), &WrapAroundFunctions::is_greater_than_or_equal);
	ClassDB::bind_static_method("WrapAroundFunctions", D_METHOD("difference", "future", "past", "max_value", "half_max_val"), &WrapAroundFunctions::difference);
	ClassDB::bind_static_method("WrapAroundFunctions", D_METHOD("advance", "value", "advance_by", "max_value"), &WrapAroundFunctions::advance);
	ClassDB::bind_static_method("WrapAroundFunctions", D_METHOD("get_max", "a", "b"), &WrapAroundFunctions::get_max);
}

bool WrapAroundFunctions::is_greater_than(const int future, const int past, const int half_max_val)
{
	return (future > past) && ((future - past) <= half_max_val) || (future < past) && ((past - future) > half_max_val);
}

bool WrapAroundFunctions::is_greater_than_or_equal(const int future, const int past, const int half_max_val)
{
	return future == past || is_greater_than(future, past, half_max_val);
}

int WrapAroundFunctions::difference(const int future, const int past, const int max_value, const int half_max_val)
{
	if (abs(past - future) > half_max_val)
	{
		if (past < future)
		{
			return -(max_value - future) - past - 1;
		}
		else
		{
			return future + (max_value - past);
		}
	}
	else
	{
		return future - past;
	}
}

int WrapAroundFunctions::advance(const int value, const int advance_by, const int max_value)
{
	return UtilityFunctions::posmod(value + advance_by, max_value);
}

int WrapAroundFunctions::get_max(const int a, const int b, const int half_max_value)
{
	if (is_greater_than(a, b, half_max_value))
	{
		return a;
	}
	else
	{
		return b;
	}
}

WrapAroundFunctions::WrapAroundFunctions()
{
}

WrapAroundFunctions::~WrapAroundFunctions()
{
}