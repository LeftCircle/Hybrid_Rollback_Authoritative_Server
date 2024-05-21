#ifndef NETCODE_REGISTER_TYPES_H
#define NETCODE_REGISTER_TYPES_H

#include <godot_cpp\core\class_db.hpp>

using namespace godot;

void initialize_netcode_module(ModuleInitializationLevel p_level);
void uninitialize_netcode_module(ModuleInitializationLevel p_level);

#endif // NETCODE_REGISTER_TYPES_H