extends Node


func _ready():
	pass

func _physics_process(delta):
	CommandFrame.execute()
	
	WorldState.execute()
