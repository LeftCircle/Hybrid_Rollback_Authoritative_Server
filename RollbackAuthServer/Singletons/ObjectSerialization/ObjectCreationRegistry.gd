extends Node

@export var synced_component_group : ResourceGroup
@export var bulk_compressors : ResourceGroup
@export var local_scenes_group : ResourceGroup

var class_id_to_class_counter = {}
var network_id_to_instance_id = {}
var class_id_to_resource = {}
var class_id_to_compressor = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_serialize_entities_and_components()
	_map_compressors()

# NOTE -> You can get a 7x performance increase by writing
# a create_new() function on each script. This can be automated
# when godot is saved. See how ResourceGroup does it.
func new_obj(class_id : StringName):
	var new_obj = class_id_to_resource[class_id].duplicate()
	new_obj.instance_id = class_id_to_class_counter[class_id]
	class_id_to_class_counter[class_id] += 1
	return new_obj

func assign_class_instance_id(entity) -> void:
	var class_id : String = entity.netcode.class_id
	entity.netcode.class_instance_id = class_id_to_class_counter[entity.netcode.class_id]
	class_id_to_class_counter[entity.netcode.class_id] += 1

func _serialize_entities_and_components():
	var synced_components : Array[NetcodeData]
	synced_component_group.load_all_into(synced_components)
	for component in synced_components:
		serialize_synced_comp(component)
	_serialize_scenes()

func _serialize_scenes() -> void:
	var local_scenes : Array = []
	local_scenes_group.load_all_into(local_scenes)
	for scene_res in local_scenes:
		var scene = scene_res.scene.instantiate()
		scene.class_id = scene_res.class_id
		serialize_local_comp(scene)

func serialize_synced_comp(component : NetcodeData) -> void:
	serialize_local_comp(component)
	var num_id = id_to_int(component.class_id)
	component.class_id_int = num_id

func serialize_local_comp(component) -> void:
	var class_id = component.class_id
	if class_id_to_class_counter.has(class_id):
		assert(false) #,"This class_id already exists: " + str(class_id))
	else:
		class_id_to_class_counter[class_id] = 0
		class_id_to_resource[class_id] = component

func _map_compressors() -> void:
	var compressors : Array[Resource]
	bulk_compressors.load_all_into(compressors)
	for compressor in compressors:
		var class_id : StringName = compressor.res_to_compress.class_id
		class_id_to_compressor[class_id] = compressor

static func id_to_int(id : StringName) -> int:
	id = id.to_upper()
	var ascii_A : int = "A".unicode_at(0)
	var a : int = id.unicode_at(0) - ascii_A
	var b : int = id.unicode_at(1) - ascii_A
	var c : int = id.unicode_at(2) - ascii_A
	var first_cantor : int = cantor(a, b)
	return cantor(first_cantor, c)

static func cantor(a : int, b : int) -> int:
	return (a + b) * (a + b + 1) / 2 + b

# See https://en.wikipedia.org/wiki/Pairing_function#Inverting_the_Cantor_pairing_function
func reverse_cantor(cantor_number : int):
	var w : int = int((sqrt(8 * cantor_number + 1) - 1) / 2)
	var t : int = w * (w + 1) / 2
	var y : int = cantor_number - t
	var x : int = w - y
	return [x, y]

func _exit_tree() -> void:
	for id in class_id_to_resource:
		if class_id_to_resource[id].is_class("Node"):
			class_id_to_resource[id].free()

