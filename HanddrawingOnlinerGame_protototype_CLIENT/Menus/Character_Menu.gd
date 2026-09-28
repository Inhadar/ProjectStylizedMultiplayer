extends Control

# Getting all the buttons or items (such as character options) from the GridContainer
onready var characters = $GridContainer.get_children()

# Called when the scene is ready
func _ready():
	# Set up the buttons when the scene is ready
	set_the_buttons()

# Function to connect each character button to the character selection process
func set_the_buttons():
	for i in characters:
		# Connect each button's "pressed" signal to the "select_character" function
		i.connect("pressed",self,"select_character",[i.name])

# Function to handle character selection
func select_character(character):
	# Print the selected character's name to the console
	print(character)
	
	# Set the chosen character in the global variable
	Globals.choosen_character = character
	
	# Change the scene to the map menu
	get_tree().change_scene("res://Menus/MapMenu.tscn")
