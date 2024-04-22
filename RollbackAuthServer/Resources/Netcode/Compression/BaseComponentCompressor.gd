extends Resource
class_name BaseComponentCompressor
## All component compressors must follow this format.
## The res_to_compress should be exported from SyncedComponents, this way compressors
## can be linked by their class_id at run time.
## Functions for compress_update, compress_create, and compress_delete must also
## be defined.
## You can optionally extend this class, but creating an instance of this per
## component type is easier since the res_to_compress and all component arrays
## can be typed.


## The resource from SyncedComponents that this bulk compressor will compress.
## The class_id from the resource is used to map components to compressors at
## runtime.
@export var res_to_compress : Resource

## Used to compress state data from an update. The class_instance and all relavent
## data of each component should be compressed.
func compress_update(bit_writer : BitStreamWriter, components : Array[Resource]) -> void:
	pass

## Used to compress component creation. Contains the class_id, owner_id, and owner_instance
## along with all starting state data
func compress_create(bit_writer : BitStreamWriter, components : Array[Resource]) -> void:
	pass

## Used to compress component deletion. Just compresses the instance_id.
func compress_delete(bit_writer : BitStreamWriter, components : Array[Resource]) -> void:
	pass
