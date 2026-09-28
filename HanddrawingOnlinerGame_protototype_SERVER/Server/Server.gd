extends Node2D

# Maximum number of players allowed in a single room
var room_max_size = 6

# Dictionary to keep track of all connected players and their data
var connected_players = {}

# Dictionary of rooms with unique keys (1 to 6), each containing a list of player IDs
var rooms = {
	1: [],
	2: [],
	3: [],
	4: [],
	5: [],
	6: []
}

func _ready():
	# Start the multiplayer server using ENet
	with_multiplayerapi()
	# Uncomment this to use WebSocket instead
	# with_websocket()

# Create a new ENet server and connect necessary signals
func with_multiplayerapi():
	var server = NetworkedMultiplayerENet.new()
	var err = server.create_server(4242)
	if err != OK:
		print("Unable to start server")
		return
	get_tree().network_peer = server
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	print("Server created")

# Handle player disconnection
func _player_disconnected(id):
	print("Player disconnected: ", id)
	if connected_players.has(id):

		# Notify other players in the same room that this player left
		var player_name = connected_players[id][1]
		var system_message = "[%s Left]" % player_name
		var room_id = connected_players[id][2]
		for player_id in rooms[int(room_id)]:
			if player_id != id:
				rpc_id(player_id, "message_received", "System", system_message,Color.red)
		
		# Clean up: remove player from room and connected list
		var room_name = connected_players[id][2]
		rooms[int(room_name)].erase(id)
		connected_players.erase(id)

	# Tell all clients to remove the disconnected player instance
	rpc("delete_disconnected_player", id)

# Called when a player joins. Adds player to tracking dictionary and places them in a room
remote func add_player(player_data):
	var sender_id = get_tree().get_rpc_sender_id()
	connected_players[sender_id] = player_data
	join_room(sender_id, player_data[2])
	var player_name = player_data[1]
	var system_message = "[%s Joined]" % player_name
	for player_id in rooms[int(player_data[2])]:
		if player_id == sender_id:
			rpc_id(player_id, "message_received", "System", system_message,Color.green)
	
# Add player to the appropriate room
func join_room(id, room_id):
	# Remove player from all other rooms in case they are in another
	for r in rooms:
		rooms[r].erase(id)

	# Check if room has space
	if rooms.has(int(room_id)):
		if rooms[int(room_id)].size() < room_max_size:
			rooms[int(room_id)].append(id)
			instance_player_for_room(id, connected_players[id])
			
			# Notify other players in the room that a new player has joined
			var player_name = connected_players[id][1]
			var system_message = "[%s Joined]" % player_name
			for player_id in rooms[int(room_id)]:
				if player_id != id:
					rpc_id(player_id, "message_received", "System", system_message,Color.green)
		else:
			print("Room is Full")

# Spawn new player instance for others in the room
func instance_player_for_room(new_id, player_data):
	var room_name = player_data[2]
	for id in rooms[int(room_name)]:
		var existing_player_data = connected_players[id]
		if id != new_id:
			# Send the new player instance to existing players in the room
			rpc_id(id, "instance_player", new_id, player_data)

			# Send the existing players to the new player
			rpc_id(new_id, "instance_player", id, existing_player_data)
		else:
			# Send the new player to itself to instantiate its own character
			rpc_id(id, "instance_player", new_id, player_data)

# Print when a new client connects
func _player_connected(id):
	print("Player connected: ", id)

# Receive updated transform data (position, rotation, velocity) from a player
# and send it to all other players in the same room
remote func update_transform(plsyer_position, plsyer_rotation, velocity):
	var player_id = get_tree().get_rpc_sender_id()
	var room = connected_players[player_id][2]
	for id in rooms[int(room)]:
		if id != player_id:
			rpc_id(id, "update_player_transform", player_id, plsyer_position, plsyer_rotation, velocity)

# Handle chat message from player and broadcast to players in the same room
remote func message_send(player_id, message):
	var sender_room = connected_players[player_id][2]
	for id in rooms[int(sender_room)]:
		rpc_id(id, "message_received", connected_players[player_id][1], message,Color.white)

"""
# Optional: WebSocket alternative server method
func with_websocket():
	var server = WebSocketServer.new()
	var err = server.listen(4242, PoolStringArray(), true)
	if err != OK:
		print("Unable to start server")
		set_process(false)
		return
	get_tree().network_peer = server
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	print("Server created")
"""
