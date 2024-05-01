extends Node


func _ready():
	pass

func _physics_process(delta):
	CommandFrame.execute()
	InputSystem.execute(CommandFrame.frame)
	StableBufferSystem.execute()
	CommandFrameSyncSystem.execute()
	InputBasedMoveSystem.execute(delta)
