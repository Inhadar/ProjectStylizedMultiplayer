extends Node

# Variables to store the chosen map, character, and local player's name
var choosen_map = "1"
var choosen_character = "player1"
var local_name = ""

# This function is responsible for instancing a node (such as a player character or other entities), adding it to a parent, setting its position, and configuring its properties based on the player's data
func instance_node(node, parent, location, player_data, id):
	# Create an instance of the provided node (usually a player or other in-game object)
	var node_instance = node.instance()
	
	# Set the global position of the node to the provided location (coordinates)
	node_instance.global_position = location
	
	# Add the node as a child of the provided parent node (usually the main scene or a specific container)
	parent.add_child(node_instance)
	
	# Set the texture of the node's sprite based on the player's data (player data[0] is expected to contain the image file name)
	node_instance.get_node("Sprite").texture = load("res://Assets/Player/"+player_data[0]+".png")
	
	# Set the text of the node's "NameLabel" to the player's name (player_data[1] is expected to contain the player's name)
	node_instance.get_node("NameLabel").text = player_data[1]
	
	# Return the instance of the node, allowing further manipulation if needed
	return node_instance
