extends Node2D

# This function is called when the node is ready (i.e., the scene is fully loaded and the node is part of the scene tree)
func _ready():
	# Dynamically loads a texture for the Background node using the scene's name
	$Background.texture = load("res://Assets/Background/bakground" + self.name + ".png")
