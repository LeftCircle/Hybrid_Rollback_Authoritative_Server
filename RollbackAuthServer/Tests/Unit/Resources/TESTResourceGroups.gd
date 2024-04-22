extends GutTest

var bulk_compressor_group : ResourceGroup = load("res://Resources/Components/BulkCompressors.tres")
var local_resource_group : ResourceGroup = load("res://Resources/Components/AllLocalComponents.tres")
var local_scenes : ResourceGroup = load("res://Resources/Components/AllLocalScenes.tres")

func test_we_can_get_the_compress_function_using_resource_groups() -> void:
	var compressors : Array[Resource] = []
	bulk_compressor_group.load_all_into(compressors)
	for compressor in compressors:
		assert_true(compressor.has_method("compress_update"))
		assert_true(compressor.has_method("compress_create"))

func test_cbd_in_local_scenes() -> void:
	var components : Array = []
	local_scenes.load_all_into(components)
	var has_cbd = false
	for comp in components:
		if comp.class_id == "CBD":
			has_cbd = true
		break
	assert_true(has_cbd)

func test_character_body_has_class_id() -> void:
	var cbd : ECSCharacterBody2D = ObjectCreationRegistry.new_obj("CBD")
	assert_eq(cbd.class_id, "CBD")
	var second_cbd : ECSCharacterBody2D = ObjectCreationRegistry.new_obj("CBD")
	assert_ne(cbd.instance_id, second_cbd.instance_id)
	cbd.free()
	second_cbd.free()


