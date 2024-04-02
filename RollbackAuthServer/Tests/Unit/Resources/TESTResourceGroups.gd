extends GutTest

var bulk_compressor_group : ResourceGroup = load("res://Resources/Netcode/Compression/BulkCompressors.tres")

func test_we_can_get_the_compress_function_using_resource_groups() -> void:
	var compressors : Array[Resource] = []
	bulk_compressor_group.load_all_into(compressors)
	for compressor in compressors:
		assert_true(compressor.has_method("compress_update"))
		assert_true(compressor.has_method("compress_create"))

	
