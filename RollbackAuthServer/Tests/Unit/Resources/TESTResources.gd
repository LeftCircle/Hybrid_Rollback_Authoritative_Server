extends GutTest


func test_resources_have_different_data() -> void:
	var max_speed_a = 100
	var max_speed_b = 200
	var move_a = Move.new()
	move_a.max_speed = max_speed_a
	var move_b = Move.new()
	assert_ne(move_a.max_speed, move_b.max_speed)
