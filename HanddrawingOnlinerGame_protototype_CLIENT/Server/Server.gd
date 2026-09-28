extends Node

# Variables for spawn position and player scene paths
var spawn_position = null
var player = preload("res://Player/Player.tscn")  # Local player scene
var otherplayer = preload("res://Player/OtherPlayer.tscn")  # Other player's scene

# Called when the node is ready
func _ready():
	# Connect signals to handle network events
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "connection_failed")

# Function to join the server
func join_server():
	# High-level API for networking
	var client = NetworkedMultiplayerENet.new()
	var err = client.create_client("127.0.0.1", 4242)
	if err != OK:
		print("Unable_to_connect")
		return
	get_tree().network_peer = client
	
	# WebSocket technology (commented out here)
	"""
	client = WebSocketClient.new()
	var err = client.connect_to_url("127.0.0.1:4242", PoolStringArray(), true)
	if err != OK:
		print("Unable to Connect")
		return
	get_tree().network_peer = client
	set_process(true)
	"""

# Connection failed handler
func connection_failed():
	get_node("/root/Lobby/join").disabled = false
	print("Connection failed")
	join_server()  # Retry to join the server

# Server disconnected handler
func _server_disconnected():
	get_node("/root/Lobby").show()  # Show the lobby
	print("server disconnected")

# Called when connected to the server
func _connected_to_server():
	get_node("/root/Lobby").hide()  # Hide the lobby
	print("Connected to server")
	start_game()  # Start the game after connection

# Start the game (called remotely)
remote func start_game():
	# Load and instance the selected map
	var scene = load("res://Maps/"+Globals.choosen_map+".tscn").instance()
	scene.name = Globals.choosen_map
	if !Globals.has_node(scene.name):
		get_tree().root.add_child_below_node(Globals, scene)
	spawn_position = scene.get_node("Spawn_Area").global_position
	scene.z_index = -5  # Set the map's z-index to render behind
	## Add chat UI
	var chat = load("res://GUI/Chat.tscn").instance()
	get_tree().root.add_child_below_node(Globals, chat)
	# Notify the server of the player's data
	rpc_id(1, "add_player", [Globals.choosen_character, Globals.local_name, Globals.choosen_map])

# Function to send a message to the chat
func add_to_chat(message):
	rpc_id(1, "message_send", get_tree().get_network_unique_id(), message)

# Sync function to receive a message
sync func message_received(player_id, message,color):
	get_tree().get_root().get_node("Chat").message(player_id, message,color)

# Remote function to instance a player in the game
remote func instance_player(id, player_data):
	# Determine whether the player is local or not and instance the correct player
	var p = player if get_tree().get_network_unique_id() == id else otherplayer
	var player_instance = Globals.instance_node(p, Nodes, spawn_position, player_data, id)
	player_instance.name = str(id)

# Remote function to update the player’s position, rotation, and velocity
remote func update_player_transform(id, position, rotation, velocity):
	if get_tree().get_network_unique_id() != id:
		if Nodes.has_node(str(id)):
			Nodes.get_node(str(id)).update_transform(position, rotation, velocity)
		else:
			join_server()  # If the player is not found, rejoin the server

# Remote function to delete a disconnected player
remote func delete_disconnected_player(player_id):
	if Nodes.has_node(str(player_id)):
		Nodes.get_node(str(player_id)).queue_free()  # Free the disconnected player's node
