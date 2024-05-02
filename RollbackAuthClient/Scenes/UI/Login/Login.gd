extends Control

# UI State nodes
@onready var login_screen = get_node("Background/LoginScreen")
@onready var create_account_screen = get_node("Background/CreateAccount")
# Login nodes
@onready var username_input = get_node("Background/LoginScreen/Username")
@onready var password_input = get_node("Background/LoginScreen/Password")
@onready var login_button = get_node("Background/LoginScreen/LoginButton")
@onready var create_account_button = get_node("Background/LoginScreen/CreateAccountButton")
# Create account nodes
@onready var create_username_input = get_node("Background/CreateAccount/Username")
@onready var create_password_input = get_node("Background/CreateAccount/Password")
@onready var confirm_password_input = get_node("Background/CreateAccount/ConfirmPassword")
@onready var confirm_button = get_node("Background/CreateAccount/ConfirmButton")
@onready var back_button = get_node("Background/CreateAccount/BackButton")

func _ready():
	#Gateway.connect_to_server("asdf", "asdfasdf", false)
	pass

# Signals
func _on_LoginButton_pressed():
	if username_input.text == "" or password_input.text == "":
		print("Please provide a valid userID and password")
	else:
		login_button.disabled = true
		create_account_button.disabled = true
		var username = username_input.get_text()
		var password = password_input.get_text()
		print("Attempting to login " + username)
		Gateway.connect_to_server(username, password, false)

func _on_CreateAccountButton_pressed():
	login_screen.hide()
	login_screen.set_process_input(false)
	create_account_screen.show()
	create_account_screen.set_process_input(true)

func _on_BackButton_pressed():
	create_account_screen.hide()
	create_account_screen.set_process_input(false)
	login_screen.show()
	login_screen.set_process_input(true)

func _on_ConfirmButton_pressed():
	if create_username_input.get_text() == "":
		print("Please provide a valid username")
	elif create_password_input.get_text() == "":
		print("Password cannot be empty")
	elif create_password_input.get_text().length() <= 6:
		print("Password must be at least 7 characters")
	elif confirm_password_input.get_text() == "":
		print("Confirm password cannot be empty")
	elif create_password_input.get_text() != confirm_password_input.get_text():
		print("Passwords do not match")
	else:
		confirm_button.disabled = true
		back_button.disabled = true
		var username = create_username_input.get_text()
		var password = create_password_input.get_text()
		print("New account created. Logging the player in and sending to server!")
		Gateway.connect_to_server(username, password, true)
		create_username_input.text = ""
		create_password_input.text = ""
		confirm_password_input.text = ""

func enable_login_buttons(to_enable : bool):
	login_button.disabled = to_enable
	create_account_button.disabled = to_enable

func enable_create_account_buttons(to_enable : bool):
	back_button.disabled = to_enable
	confirm_button.disabled = to_enable
