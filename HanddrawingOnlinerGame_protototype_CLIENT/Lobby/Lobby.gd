extends Control

# This function is called when the node is ready (i.e., when the scene is fully loaded and the node is part of the scene tree)
func _ready():
	# Check if the network peer is null (meaning the client is not connected to a server)
	if get_tree().network_peer == null:
		# If not connected, attempt to join a server using the 'Server.join_server()' function
		Server.join_server()
	else:
		# If already connected to a server, do nothing (pass)
		pass
