extends GutTest

var all_netcode_res : ResourceGroup = load("res://Resources/Components/AllSyncedComponents.tres")
var all_local_res : ResourceGroup = load("res://Resources/Components/AllLocalComponents.tres")

func test_no_components_have_same_class_id() -> void:
	var netcode_components : Array
	var local_components : Array
	all_netcode_res.load_all_into(netcode_components)
	all_local_res.load_all_into(local_components)
	var all_components = []
	all_components.append_array(netcode_components)
	all_components.append_array(local_components)
	var unique_class_id = {}
	for i in range(all_components.size()):
		var component = all_components[i]
		assert_false(unique_class_id.has(component.class_id), "%s ID already exists!! component #%s" % [component.class_id, i])
		assert_false(component.class_id == "", "Netcode component #%s not given class_id" % [i])

func test_move_resource_has_class_id() -> void:
	var move = ObjectCreationRegistry.new_obj("MVE")
	assert_eq(move.class_id, "MVE")

func test_creating_new_object_assigns_instance_id() -> void:
	var move : Move = ObjectCreationRegistry.new_obj("MVE")
	var second_move : Move = ObjectCreationRegistry.new_obj("MVE")
	assert_eq(move.instance_id, second_move.instance_id - 1)

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

