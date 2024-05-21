#include <type_traits>
#include <gdextension_interface.h>
#include <godot_cpp\core\defs.hpp>
#include <godot_cpp\godot.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/memory.hpp>
#include <godot_cpp/variant/string_name.hpp>

#include "register_types.h"
#include "CommandFrame.h"

using namespace godot;

static inline godot::CommandFrame *command_frame_singleton{nullptr};

void initialize_static_objects()
{
	command_frame_singleton = memnew(godot::CommandFrame);
	Engine::get_singleton()->register_singleton("CommandFrame", command_frame_singleton);
}

void teardown_static_objects()
{
	Engine::get_singleton()->unregister_singleton("CommandFrame");
	memdelete(command_frame_singleton);
}

void initialize_singletons_module(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
	{
		return;
	}
	ClassDB::register_class<CommandFrame>();
	initialize_static_objects();
}

void uninitialize_singletons_module(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
	{
		return;
	}
	teardown_static_objects();
}

extern "C"
{
	// Singletons library initialization.
	GDExtensionBool GDE_EXPORT singletons_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization)
	{
		godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

		init_obj.register_initializer(initialize_singletons_module);
		init_obj.register_terminator(uninitialize_singletons_module);
		init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

		return init_obj.init();
	}
}
