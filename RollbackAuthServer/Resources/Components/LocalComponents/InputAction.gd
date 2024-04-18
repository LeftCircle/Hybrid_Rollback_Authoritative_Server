## This contains actions for the current and previous frame
## This can be used to determine if an action is held, released, just pressed, 
## or just_released.
extends LocalData
class_name InputAction

var current_inputs : InputData
var previous_inputs : InputData
