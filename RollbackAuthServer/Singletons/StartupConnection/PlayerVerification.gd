extends Node

# Made Following the Game Development Center server-client tutorial
# https://www.youtube.com/watch?v=lnFN6YabFKg

var awaiting_verification_dict = {}

func _ready():
	_create_verification_expiration_timer()

func _create_verification_expiration_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = 20.0
	timer.autostart = true
	timer.set_name("VerificationExpiration")
	timer.connect("timeout",Callable(self,"_on_VerificationExpiration_timeout"))
	self.add_child(timer, true)

func start(player_id : int) -> void:
	awaiting_verification_dict[player_id] = {"Timestamp": Time.get_unix_time_from_system()}

func verify(player_id : int, token : String) -> void:
	print("Verifying the token from the client")
	var token_verification = false
	while Time.get_unix_time_from_system() - int(token.right(64)) <= 30:
		var time_difference = Time.get_unix_time_from_system() - int(token.right(64))
		print("Time difference between now and the token is ", time_difference)
		if Server.expected_tokens.has(token):
			print("Token has been verified. Creating Player Container!")
			token_verification = true
			_on_verification(player_id, token)
			break
		else:
			print("Token not yet found, waiting two seconds")
			await get_tree().create_timer(2).timeout
	Server.return_token_verification_results(player_id, token_verification)
	if token_verification == false:
		# Players must be disconnected if the verification fails
		print("Token verification failed. Removing player")
		# TO DO -> also remove the latency tracker for the player
		awaiting_verification_dict.erase(player_id)
		Server.network.disconnect_peer(player_id)

func _on_verification(player_id : int, token : String):
	awaiting_verification_dict.erase(player_id)
	Server.expected_tokens.erase(token)
	Server.on_player_verified(player_id)

func _on_VerificationExpiration_timeout():
	var current_time = Time.get_unix_time_from_system()
	var start_time
	if awaiting_verification_dict != {}:
		for key in awaiting_verification_dict.keys():
			start_time = awaiting_verification_dict[key].Timestamp
			if current_time - start_time >= 30:
				awaiting_verification_dict.erase(key)
				var connected_peers = Array(get_tree().get_peers())
				if connected_peers.has(key):
					Server.return_token_verification_results(key, false)
					Server.network.disconnect_peer(key)
