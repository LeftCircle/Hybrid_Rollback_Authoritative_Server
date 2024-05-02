extends Node


func _physics_process(delta: float) -> void:
	Server.execute()
