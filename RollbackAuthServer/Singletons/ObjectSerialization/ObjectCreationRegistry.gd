extends Node

@export var file_lister: Resource
@export var synced_fx_file_lister: Resource

var class_id_to_class_counter = {}
var class_id_to_int_id = {}
var network_id_to_instance_id = {}
var int_id_to_str_id = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_serialize_entities_and_components()

func _serialize_entities_and_components():
	file_lister.load_resources()
	var paths = file_lister.get_file_paths()
	for path in paths:
		serialize_class_id(path)

func serialize_class_id(path : String) -> void:
	if path.ends_with(".tmp"):
		return
	var loaded_scene = load(path)
	var scene = loaded_scene.instantiate()
	var netcode_ref = scene.get("netcode")
	if netcode_ref != null:
		_register_netcode_scene(netcode_ref, path)
	scene.queue_free()

func _register_netcode_scene(netcode_ref, path : String) -> void:
	var class_id = netcode_ref.class_id
	var num_id = id_to_int(class_id)
	if class_id_to_int_id.has(class_id):
		assert(false) #,"This class_id already exists: " + str(class_id))
	else:
		class_id_to_int_id[class_id] = num_id
		class_id_to_class_counter[class_id] = 0
		int_id_to_str_id[num_id] = class_id

func assign_class_instance_id(entity) -> void:
	var class_id : String = entity.netcode.class_id
	entity.netcode.class_instance_id = class_id_to_class_counter[entity.netcode.class_id]
	class_id_to_class_counter[entity.netcode.class_id] += 1

func id_to_int(id : String):
	id = id.to_upper()
	var ascii_A = "A".unicode_at(0)
	var a = id.unicode_at(0) - ascii_A
	var b = id.unicode_at(1) - ascii_A
	var c = id.unicode_at(2) - ascii_A
	var first_cantor = cantor(a, b)
	return cantor(first_cantor, c)

func cantor(a : int, b : int) -> int:
	return (a + b) * (a + b + 1) / 2 + b

# See https://en.wikipedia.org/wiki/Pairing_function#Inverting_the_Cantor_pairing_function
func reverse_cantor(cantor_number : int):
	var w = int((sqrt(8 * cantor_number + 1) - 1) / 2)
	var t = w * (w + 1) / 2
	var y = cantor_number - t
	var x = w - y
	return [x, y]

