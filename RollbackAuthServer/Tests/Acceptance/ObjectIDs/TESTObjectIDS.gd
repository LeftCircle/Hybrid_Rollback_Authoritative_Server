extends GutTest

var all_netcode_res : ResourceGroup = load("res://Resources/Components/AllSyncedComponents.tres")
var all_local_res : ResourceGroup = load("res://Resources/Components/AllLocalComponents.tres")

func test_no_components_have_same_class_id() -> void:
	var netcode_components : Array[NetcodeData]
	all_netcode_res.load_all_into(netcode_components)
	var unique_class_id = {}
	for i in range(netcode_components.size()):
		var id : NetcodeData = netcode_components[i]
		assert_false(unique_class_id.has(id.class_id), "%s ID already exists!! component #%s" % [id.class_id, i])
		assert_false(id.class_id == "", "Netcode component #%s not given class_id" % [i])

func test_local_resources_dont_have_ids() -> void:
	var local_components : Array = []
	all_local_res.load_all_into(local_components)
	for i in range(local_components.size()):
		var comp = local_components[i]
		assert_true(comp.get("class_id") == null, "local component #%s is a netcode component!!" % [i])

func test_move_resource_has_class_id() -> void:
	var move = Move.new()
	assert_eq(move.class_id, "MVE")

#func test_profile_speed_of_storing_resources() -> void:
	## We want to compare the speed of storing the resources then copying them
	## to create new resources vs initing the id in 
	## class_id to script
	#var n_objects = 10000
	#var start = Time.get_ticks_usec()
	#for i in range(n_objects):
		## Remove _init()function from Move before testing
		#var move : Move = ObjectCreationRegistry.class_id_to_resource["MVE"].duplicate()
		##var move : Move = ObjectCreationRegistry.new_obj("MVE")
		## Add _init function to Move before Testing
		##var move : Move = Move.new()
	#var end = Time.get_ticks_usec()
	#print(end - start, " usec")
	
