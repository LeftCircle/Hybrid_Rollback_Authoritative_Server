extends BaseEntity
class_name S_PlayerCharacter

func _ready() -> void:
	add_component(ObjectCreationRegistry.new_obj("INP")) # InputAction
	add_component(ObjectCreationRegistry.new_obj("INH")) # InputHistory
	add_component(ObjectCreationRegistry.new_obj("SBD")) # StableBufferData
	CommandFrameSyncSystem.register(self)
	assert(components.has("EID"))

func add_enet_id(enet_id : int) -> void:
	var new_enet_id : ENetID = ObjectCreationRegistry.new_obj("EID") # ENetId
	new_enet_id.id = enet_id
	add_component(new_enet_id)
