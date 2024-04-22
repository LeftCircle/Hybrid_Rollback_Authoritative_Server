extends CharacterBody2D
class_name ECSCharacterBody2D

@export var class_id : StringName : set = set_class_id
var instance_id : int

func set_class_id(new_id : StringName) -> void:
	class_id = new_id.substr(0, 3)

func _ready() -> void:
	get_parent().add_component(self)
