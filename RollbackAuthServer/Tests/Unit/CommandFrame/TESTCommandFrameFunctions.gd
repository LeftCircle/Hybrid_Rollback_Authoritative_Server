extends GutTest


func test_frame_difference() -> void:
	var max_frame = CommandFrame.MAX_FRAME_NUMBER
	var expected_neg_1 = CommandFrame.frame_difference(max_frame, 0)
	var expected_neg_2 = CommandFrame.frame_difference(max_frame, 1)
	var expected_1 = CommandFrame.frame_difference(10, 9)
	var expected_0 = CommandFrame.frame_difference(10, 10)
	assert_eq(expected_neg_1, -1)
	assert_eq(expected_neg_2, -2)
	assert_eq(expected_1, 1)
	assert_eq(expected_0, 0)


