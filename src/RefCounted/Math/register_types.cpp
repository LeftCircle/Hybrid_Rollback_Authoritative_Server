#include "register_types.h"

#include "InputVecQuantizer.h"
#include "WrapAroundFunctions.h"

#include <gdextension_interface.h>
#include <godot_cpp\core\defs.hpp>
#include <godot_cpp\godot.hpp>

using namespace godot;

void initialize_math_module(ModuleInitializationLevel p_level)
{
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
    {
        return;
    }

    // The order matters here. If Packet extends from BitStream, it must come after BitStream.
    ClassDB::register_class<InputVecQuantizer>();
    ClassDB::register_class<WrapAroundFunctions>();
}

void uninitialize_math_module(ModuleInitializationLevel p_level)
{
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
    {
        return;
    }
}

extern "C"
{
    // Initialization.
    GDExtensionBool GDE_EXPORT math_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization)
    {
        godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

        init_obj.register_initializer(initialize_math_module);
        init_obj.register_terminator(uninitialize_math_module);
        init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

        return init_obj.init();
    }
}