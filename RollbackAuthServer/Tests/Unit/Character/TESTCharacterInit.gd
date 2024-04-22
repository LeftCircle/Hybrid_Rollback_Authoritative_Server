extends GutTest


func test_character_is_registered_to_systems_on_creation() -> void:
	# Must be registered to InputSystem
	# Must also have the FrameSync component
	# Must also have the EnetID component
	# Must register to the StableBufferSystem
	var character = null
	var enet_id_of_character = 0
	assert_true(CommandFrameSyncSystem.has(enet_id_of_character))
	assert_true(StableBufferSystem.has(enet_id_of_character))
	assert_true(false, "Not yet implemented")
