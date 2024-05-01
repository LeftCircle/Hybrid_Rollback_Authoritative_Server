#include "Packet.h"

using namespace godot;

void Packet::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("set_type", "type"), &Packet::set_type);
    ClassDB::bind_method(D_METHOD("get_type"), &Packet::get_type);

    ClassDB::bind_method(D_METHOD("set_transfer_mode", "transfer_mode"), &Packet::set_transfer_mode);
    ClassDB::bind_method(D_METHOD("get_transfer_mode"), &Packet::get_transfer_mode);

    ClassDB::bind_method(D_METHOD("set_channel", "channel"), &Packet::set_channel);
    ClassDB::bind_method(D_METHOD("get_channel"), &Packet::get_channel);

    ClassDB::bind_method(D_METHOD("set_target", "target"), &Packet::set_target);
    ClassDB::bind_method(D_METHOD("get_target"), &Packet::get_target);

    ClassDB::add_property("Packet", PropertyInfo(Variant::INT, "type"), "set_type", "get_type");
    ClassDB::add_property("Packet", PropertyInfo(Variant::INT, "transfer_mode"), "set_transfer_mode", "get_transfer_mode");
    ClassDB::add_property("Packet", PropertyInfo(Variant::INT, "channel"), "set_channel", "get_channel");
    ClassDB::add_property("Packet", PropertyInfo(Variant::INT, "target"), "set_target", "get_target");

    BIND_ENUM_CONSTANT(CREATION);
    BIND_ENUM_CONSTANT(UPDATE);
    BIND_ENUM_CONSTANT(DELETION);
    BIND_ENUM_CONSTANT(ITERATION_CHANGE);
    BIND_ENUM_CONSTANT(LOBBY);
    BIND_ENUM_CONSTANT(INPUTS);
    BIND_ENUM_CONSTANT(N_ENUM);
}

Packet::TYPE Packet::get_type() const
{
    return type;
}

void Packet::set_type(const TYPE p_type)
{
    type = p_type;
}

MultiplayerPeer::TransferMode Packet::get_transfer_mode() const
{
    return transfer_mode;
}

int Packet::get_channel() const
{
    return channel;
}

int Packet::get_target() const
{
    return target;
}

void Packet::set_transfer_mode(const MultiplayerPeer::TransferMode p_transfer_mode)
{
    transfer_mode = p_transfer_mode;
}

void Packet::set_channel(const int p_channel)
{
    channel = p_channel;
}

void Packet::set_target(const int p_target)
{
    target = p_target;
}

Packet::Packet()
{
}

Packet::~Packet()
{
}
