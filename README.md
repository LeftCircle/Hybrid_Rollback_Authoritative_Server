# Hybrid Rollback Authoritative Server Networking

This is a work in progress cleaning/converting two and a half years of work from a previous project into a more extendable, readable, and reusable solution. This networking solution creates networked components that will be synced between clients and an authoritative server. Each client will predict their gameplay state based on their own inputs and predicted/received inputs from other players. The authoritative server will then send the actual state of the world to clients, who will then roll back and re-predict if any mismatch occurs. This solution is ideal for a top down shooter or hack and slash game where you must respect both the view of the shooter and the dodger. 

## Usage

### Components
Components are either Local or Synced. Local components must be placed in Resources -> Components -> LocalComponents. Synced must be placed in Resources -> Components -> SyncedComponents. As of now, both the script and .tres file must be created and placed in their respective folders to create and register new components. Eventually there will be a streamlined process for this. 

Components must have a unique instance_id. This confirms that there are no duplicate components, and is also used to communicate what component is sent over the network. Each instance id is a unique 3 character string.  

#### Synced Components
Synced components will have their data sent from the server to clients and are used to keep game-play synced. They require custom compressor/decompressors that read/write data into a packet. For example:


```
extends Resource
class_name EnetIDCompresser

@export var res_to_compress : ENetID

## Used to compress state data from an update. The class_instance and all relavent
## data of each component should be compressed.
func compress_update(bit_stream : BitStream, components : Array[ENetID]) -> void:
    for enet_id in components:
   	 BitStreamWriter.compress_instance_id(bit_stream, enet_id.instance_id)
   	 BitStreamWriter.variable_compress(bit_stream, enet_id.id)
```

#### Local Components
These are components that are used by systems that do not require their information to be tracked between the client and server. One example of this is the CommandFrameSync on the server that tracks the iteration speed of clients and how long it has been since their iteration speed has been adjusted. 

### GDExtension
Shared base classes between the client and server should be written in C++ with GDExtension or custom Godot modules.
