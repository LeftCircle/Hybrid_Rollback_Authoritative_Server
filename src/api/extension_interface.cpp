#include <type_traits>

// https://github.com/vorlac/godot-roguelite/blob/main/src/api/extension_interface.cpp

#include <gdextension_interface.h>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/memory.hpp>
#include <godot_cpp/variant/string_name.hpp>

#include "api/extension_interface.hpp"
#include "Singletons/CommandFrame.h"

// Math Includes
#include "RefCounted\Math\InputVecQuantizer.h"
#include "RefCounted\Math\WrapAroundFunctions.h"

// Netcode Includes
#include "RefCounted\Netcode\BitStream.h"
#include "RefCounted\Netcode\Packet.h"
#include "RefCounted\Netcode\Compression\BaseCompression.h"
#include "RefCounted\Netcode\Compression\BitStreamWriter.h"
#include "RefCounted\Netcode\Compression\BitStreamReader.h"

// Singletons
#include "Singletons\CommandFrame.h"

namespace rl
{
	static inline godot::CommandFrame *command_frame_singleton{nullptr};

	void initialize_static_objects()
	{
		command_frame_singleton = memnew(godot::CommandFrame);
		godot::Engine::get_singleton()->register_singleton("CommandFrame", command_frame_singleton);
	}

	void teardown_static_objects()
	{
		godot::Engine::get_singleton()->unregister_singleton("CommandFrame");
		memdelete(command_frame_singleton);
	}

	void initialize_extension_module(godot::ModuleInitializationLevel init_level)
	{
		if (init_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
			return;
		godot::ClassDB::register_class<godot::CommandFrame>();

		godot::ClassDB::register_class<godot::InputVecQuantizer>();
		godot::ClassDB::register_class<godot::WrapAroundFunctions>();

		godot::ClassDB::register_class<godot::BitStream>();
		godot::ClassDB::register_class<godot::Packet>();

		godot::ClassDB::register_class<godot::BaseCompression>();
		godot::ClassDB::register_class<godot::BitStreamWriter>();
		godot::ClassDB::register_class<godot::BitStreamReader>();

		initialize_static_objects();
	}

	void uninitialize_extension_module(godot::ModuleInitializationLevel init_level)
	{
		if (init_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
			return;

		teardown_static_objects();
	}

	extern "C"
	{
		GDExtensionBool GDE_EXPORT extension_library_init(GDExtensionInterfaceGetProcAddress addr,
														  GDExtensionClassLibraryPtr lib,
														  GDExtensionInitialization *init)
		{
			const auto init_level = godot::MODULE_INITIALIZATION_LEVEL_SCENE;
			godot::GDExtensionBinding::InitObject init_obj(addr, lib, init);

			init_obj.register_initializer(initialize_extension_module);
			init_obj.register_terminator(uninitialize_extension_module);
			init_obj.set_minimum_library_initialization_level(init_level);

			return init_obj.init();
		}
	}
}