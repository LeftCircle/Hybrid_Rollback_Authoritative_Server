extends Node

# NOTE - to remove the login screen, this requires a path to the login screen
# node. This path will change as we update the UI and the workflow for logging
# in and playing the game. This path is relative to the Gateway autoload

var login_path = "/root/SceneHandler/LoginScreen"

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var ip # Set from Server.gd
# MUST match the port on the gateway server
var port = 28838 # 1910 on tutorial
var certificate = load("res://Assets/Certificate/X509_Certificate.crt")

var username : String
var password : String
var new_account := false

func _ready():
	ip = Server.ip

func _physics_process(_delta):
	if not gateway_api.has_multiplayer_peer():
		return
	gateway_api.poll()

func connect_to_server(_username : String, _password : String, _new_account : bool):
	_set_username_and_password(_username, _password, _new_account)
	_create_client_and_connect_to_gateway()

func _set_username_and_password(_username : String, _password : String, _new_account : bool) -> void:
	username = _username
	password = _password.sha256_text()
	new_account = _new_account

func _create_client_and_connect_to_gateway() -> void:
	print("Connecting to gateway server")
	network.create_client(ip, port)
	gateway_api.multiplayer_peer = network
	gateway_api.root_path = get_path()
	get_tree().set_multiplayer(gateway_api, self.get_path())
	gateway_api.connection_failed.connect(self._on_connection_failed)
	gateway_api.connected_to_server.connect(self._on_connection_succeeded)

func _on_connection_failed():
	print("Failed to connect")
	print("Pop up server may be offline or account creation failed")
	get_node(login_path).enable_login_buttons(false)
	get_node(login_path).enable_create_account_buttons(false)

func _on_connection_succeeded():
	print("Successfully connected")
	if new_account:
		request_create_account()
	else:
		print("Connected peers are ", gateway_api.get_peers())
		request_login()

func request_create_account():
	print("Connecting to the gateway to request a new account")
	rpc_id(1, "create_account_request", username, password)
	_reset_username_password_account()

@rpc("any_peer")
func create_account_request(username : String, password : String):
	pass

func request_login():
	print("Connecting to gateway to request login")
	print("Unique ID on the Gateway server = ", gateway_api.get_unique_id())
	# Sends login request to the gateway server (which has the same port)
	#gateway_api.rpc(1, self, "login_request", [username, password])
	rpc_id(1, "login_request", username, password)
	_reset_username_password_account()

@rpc("any_peer")
func login_request(username : String, password : String):
	pass

func _reset_username_password_account():
	username = ""
	password = ""
	new_account = false

@rpc("any_peer")
func return_login_request_rpc(results, token):
	print("Authentication results received and are " + str(results))
	if results == true:
		Server.token = token
		# Only connect to the server once we have logged in
		Server.connect_to_server()
		# Verificaiton of the token must occur before login screen can go away
	else:
		print("Username and/or password are incorrect")
		get_node(login_path).login_button.disabled = false
		get_node(login_path).create_account_button.disabled = false

	# Disconnect so the player can make a second login attempt.
	gateway_api.disconnect("connection_failed",Callable(self,"_on_connection_failed"))
	gateway_api.disconnect("connected_to_server",Callable(self,"_on_connection_succeeded"))


@rpc("any_peer")
func return_create_account_request(result : bool, message : int):
	print("Account creation results received")
	if result == true:
		print("Account created. Please proceed with logging in")
		get_node(login_path)._on_BackButton_pressed()
	else:
		if message == 1:
			print("Could not create account. Username or password is invalid")
		elif message == 2:
			print("The username already exists. Please pick a new one")
	get_node(login_path).confirm_button.disabled = false
	get_node(login_path).back_button.disabled = false
	# Disconnect player so they can make another login attempt
	network.disconnect("connection_failed",Callable(self,"_on_connection_failed"))
	network.disconnect("connection_succeeded",Callable(self,"_on_connection_succeeded()"))
