extends Node

var id_to_index : Dictionary = {}
var index_to_id : Dictionary = {}

var inputs : Array[InputAction] = []
var character_bodies : Array[ECSCharacterBody2D] = []
var move_components : Array[Move] = []
var index = 0


func register(entity : BaseEntity) -> void:
	var entity_inputs : InputAction = entity.get_component("INP")
	var e_cbd : ECSCharacterBody2D = entity.get_component("CBD")
	var move : Move = entity.get_component("MVE")
	inputs.append(entity_inputs)
	character_bodies.append(e_cbd)
	move_components.append(move)
	id_to_index[entity.get_instance_id()] = index
	index_to_id[index] = entity.get_instance_id()
	index += 1

func unregister(entity : BaseEntity) -> void:
	index -= 1
	var id : int = entity.get_instance_id()
	var id_of_last : int = index_to_id[index]
	var index_to_remove : int = id_to_index[id]
	var last_input : InputAction = inputs.pop_back()
	var last_cbd : ECSCharacterBody2D = character_bodies.pop_back()
	var last_move : Move = move_components.pop_back()
	if id_of_last != id:
		inputs[index_to_remove] = last_input
		character_bodies[index_to_remove] = last_cbd
		move_components[index_to_remove] = last_move
		id_to_index[id_of_last] = index_to_remove
		index_to_id[index_to_remove] = id_of_last

	index_to_id.erase(index)
	id_to_index.erase(id)

func execute(delta : float) -> void:
	for i in range(index):
		var input : InputAction = inputs[i]
		var cbd : ECSCharacterBody2D = character_bodies[i]
		var move : Move = move_components[i]
		move.velocity.move_toward(input.current_inputs.input_vector * move.max_speed, move.acceleration * delta)
		cbd.velocity = move.velocity
		cbd.move_and_slide()
		move.velocity = cbd.velocity
		ComponentSyncSystem.sync_component_update(move)


