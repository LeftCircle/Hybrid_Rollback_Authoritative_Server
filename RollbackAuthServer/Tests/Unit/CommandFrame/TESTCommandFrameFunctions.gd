extends GutTest


func test_frame_difference() -> void:
	var max_frame = CommandFrame.MAX_FRAME_NUMBER
	#var expected_neg_1 = CommandFrame.frame_difference(max_frame, 0)
	var expected_neg_1 = WrapAroundFunctions.difference(max_frame, 0, max_frame, CommandFrame.HALF_MAX_FRAME)
	var expected_neg_2 = WrapAroundFunctions.difference(max_frame, 1, max_frame, CommandFrame.HALF_MAX_FRAME)
	var expected_1 = WrapAroundFunctions.difference(10, 9, max_frame, CommandFrame.HALF_MAX_FRAME)
	var expected_0 = WrapAroundFunctions.difference(10, 10, max_frame, CommandFrame.HALF_MAX_FRAME)
	assert_eq(expected_neg_1, -1)
	assert_eq(expected_neg_2, -2)
	assert_eq(expected_1, 1)
	assert_eq(expected_0, 0)


