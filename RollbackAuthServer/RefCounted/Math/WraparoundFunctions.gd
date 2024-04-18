extends Object
class_name WrapAroundFunctions

static func is_greater_than(future : int, past : int, half_max_value : int) -> bool:
	return (future > past) and ((future - past) <= half_max_value) or (
				(future < past) and ((past - future) > half_max_value))

static func is_greater_than_or_equal(future : int, past : int, half_max_value) -> bool:
	return future == past or is_greater_than(future, past, half_max_value)

static func difference(future : int, past : int, max_value : int, half_max_value : int) -> int:
	if abs(past - future) > half_max_value:
		if past < future:
			return -(max_value - future) - past - 1
		else:
			return future + (max_value - past)
	else:
		return future - past

static func set_value(value : int, max_value : int) -> int:
	return value % max_value

static func advance(value: int, advance_by : int, max_value : int) -> int:
	return set_value(value + advance_by, max_value)

static func get_max(val_a : int, val_b : int, half_max_value : int) -> int:
	if is_greater_than(val_a, val_b, half_max_value):
		return val_a
	else:
		return val_b
