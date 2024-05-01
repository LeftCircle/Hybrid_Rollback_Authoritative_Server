#ifndef PACKET_H
#define PACKET_H

#include <godot_cpp/classes/ref.hpp>
#include <godot_cpp\core\binder_common.hpp>
#include <godot_cpp/classes/multiplayer_peer.hpp>
#include "BitStream.h"

namespace godot
{
	class Packet : public BitStream
	{
		GDCLASS(Packet, BitStream)

	public:
		enum TYPE
		{
			CREATION,
			UPDATE,
			DELETION,
			ITERATION_CHANGE,
			LOBBY,
			INPUTS,
			N_ENUM
		};

	protected:
		static void _bind_methods();

	public:
		void set_type(const TYPE p_type);
		TYPE get_type() const;

		void set_transfer_mode(const MultiplayerPeer::TransferMode p_transfer_mode);
		MultiplayerPeer::TransferMode get_transfer_mode() const;

		void set_channel(const int p_channel);
		int get_channel() const;

		void set_target(const int p_target);
		int get_target() const;

		Packet();
		~Packet();

	private:
		TYPE type;
		MultiplayerPeer::TransferMode transfer_mode;
		int channel;
		int target;
	};
}
VARIANT_ENUM_CAST(Packet::TYPE);

#endif