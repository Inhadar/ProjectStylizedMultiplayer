extends Control

# Called when the "Accept" button is pressed
func _on_accept_pressed():
	# Set the player's local name to the text entered in the LineEdit (input field)
	Globals.local_name = $SetNameMenu/LineEdit.text
	
	# Change the scene to the Character Menu
	get_tree().change_scene("res://Menus/Character_Menu.tscn")
