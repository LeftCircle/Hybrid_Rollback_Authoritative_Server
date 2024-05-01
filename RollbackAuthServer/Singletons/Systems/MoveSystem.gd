## Moves all registered entities using move_and_slide() on their kinematic body component
extends Node

# If we wanted, all other systems that affect Move could just update the Move
# component, then the Move System can use the Move component and the Character
# Body 2D component to actually move the entity at the end of the frame.


func _register(entity : BaseEntity) -> void:
	pass



