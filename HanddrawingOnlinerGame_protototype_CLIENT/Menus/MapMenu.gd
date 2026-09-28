extends Control

# Called when the scene is loaded and ready
func _ready():
	# Set up buttons when the scene is ready
	set_buttons()

# Function to set up buttons
func set_buttons():
	# Iterate through all child nodes of the Maps node
	for i in $Maps.get_children():
		# Connect the "pressed" signal of each button to the button_pressed function
		# Pass the name of the button as an argument to button_pressed
		i.connect("pressed", self, "button_pressed", [i.name])
		
		# Set the label text of each button to its name (for visual display)
		i.get_node("Label").text = i.name

# Function to handle the button press
func button_pressed(button_name):
	# Store the chosen map name in a global variable
	Globals.choosen_map = button_name
	# Change the scene to the Lobby scene
	get_tree().change_scene("res://Lobby/Lobby.tscn")
