extends CanvasLayer

# Maximum number of messages allowed in the chat box
var max_messages = 6

# Nodes for the message container, chat box, and typed message input
onready var message = $Message
onready var chat_box = $ChatBox
onready var typed_message = $Message/TypedMessage

# Handle input events, specifically when the player presses the "Message" action
func _input(event):
	# Check if the player pressed the "Message" button (configured in Input Map)
	if event.is_action_pressed("Message"):
		var player_id = get_tree().get_network_unique_id()  # Get the player's unique network ID
		if message.visible:
			# If the message box is visible and there is text in the input field
			if typed_message.text != "":
				# Allow player to move while sending message
				Nodes.get_node(str(player_id)).move_perm = true
				# Send the message to the server
				Server.add_to_chat(typed_message.text)
				
			# Hide the message box and clear the input field
			message.visible = false
			typed_message.clear()
			typed_message.release_focus()
			Nodes.get_node(str(player_id)).move_perm = true
		else:
			# If the message box is hidden, show it and allow typing
			Nodes.get_node(str(player_id)).move_perm = false
			message.visible = true
			typed_message.grab_focus()

# Process the chat box to remove the oldest message when there are too many
func _process(_delta):
	# If there are more than the allowed number of messages, remove the oldest
	if chat_box.get_child_count() > max_messages:
		chat_box.get_child(0).queue_free()

# Display the received message in the chat box
func message(playerlocal_name, data,color):
	# Create a dynamic font for the chat messages
	var font = DynamicFont.new()
	font.font_data = load("res://fonts/AGENCYB.TTF")
	font.size = 24
	font.outline_color = Color(0, 0, 0)
	font.outline_size = 3
	# Create a new Label node to display the message
	var display_message = Label.new()
	# Add the new message label to the chat box
	chat_box.add_child(display_message)
	# Apply the custom font to the label
	display_message.add_font_override("font", font)
	display_message.add_color_override("font_color", color)
	# Set the message text, displaying the player's name and the message content
	display_message.text = "%s : %s" % [playerlocal_name, data]

# Handle when the player presses the back button to return to the map menu
func _on_BackToMaps_pressed():
	# Change to the map menu scene
	get_tree().change_scene("res://Menus/MapMenu.tscn")
	# Remove the current chosen map node from the root (cleanup)
	get_tree().root.get_node(Globals.choosen_map).queue_free()
	# Disconnect from the network
	get_tree().network_peer = null
	# Remove all child nodes of the current chat system (cleanup)
	for i in Nodes.get_children():
		i.queue_free()
	# Finally, remove the current scene node from the tree
	queue_free()
