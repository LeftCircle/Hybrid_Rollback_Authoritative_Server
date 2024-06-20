#include "register_types.h"

#include "BitStream.h"
#include "Packet.h"
#include "Compression\BaseCompression.h"
#include "Compression\BitStreamWriter.h"
#include "Compression\BitStreamReader.h"
// #include "RefCounted\Math\InputVecQuantizer.h"
// #include "RefCounted\Math\WrapAroundFunctions.h"

#include <gdextension_interface.h>
#include <godot_cpp\core\defs.hpp>
#include <godot_cpp\godot.hpp>

using namespace godot;

void initialize_netcode_module(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
	{
		return;
	}

	// ClassDB::register_class<InputVecQuantizer>();
	// ClassDB::register_class<WrapAroundFunctions>();
	// The order matters here. If Packet extends from BitStream, it must come after BitStream.
	ClassDB::register_class<BitStream>();
	ClassDB::register_class<Packet>();
	ClassDB::register_class<BaseCompression>();
	ClassDB::register_class<BitStreamWriter>();
	ClassDB::register_class<BitStreamReader>();
}

void uninitialize_netcode_module(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
	{
		return;
	}
}

extern "C"
{
	// Initialization.
	GDExtensionBool GDE_EXPORT netcode_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization)
	{
		godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

		init_obj.register_initializer(initialize_netcode_module);
		init_obj.register_terminator(uninitialize_netcode_module);
		init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

		return init_obj.init();
	}
}
