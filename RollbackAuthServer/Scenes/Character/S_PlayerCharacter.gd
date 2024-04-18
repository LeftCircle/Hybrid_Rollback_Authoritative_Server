extends BaseEntity
class_name S_PlayerCharacter

func _ready() -> void:
	add_component(ObjectCreationRegistry.new_obj("INP")) # InputAction
	add_component(ObjectCreationRegistry.new_obj("INH")) # InputHistory
	add_component(ObjectCreationRegistry.new_obj("FSY")) # FrameSync
