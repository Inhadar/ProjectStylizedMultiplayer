extends Control

# This function is called when the node is ready (i.e., the scene is fully loaded and the node is part of the scene tree)
func _ready():
	# Play the "Move" animation using the AnimationPlayer node
	$AnimationPlayer.play("Move")

# This function is triggered when the button is pressed (usually connected to the signal of a button)
func _on_Button_pressed(): 
	# Change the current scene to the scene located at "res://Menus/SetUsername.tscn"
	get_tree().change_scene("res://Menus/SetUsername.tscn")
