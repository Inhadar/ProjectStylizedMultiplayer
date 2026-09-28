extends KinematicBody2D

# Declare variables and nodes
onready var tween = $Tween   # Reference to the Tween node
var speed = 200              # Movement speed of the character
var puppet_pos = Vector2()   # Position of the character
var puppet_rot = 0           # Rotation of the character (though unused here)
var puppet_vel = Vector2()   # Velocity of the character

# Update the character's transform (position, rotation, and velocity)
func update_transform(_puppet_pos, _puppet_rot, _puppet_vel):
	# Update the position and velocity
	new_puppet_pos(_puppet_pos)
	puppet_vel = _puppet_vel

	# Flip the sprite based on the x-velocity direction
	if puppet_vel.x != 0:
		if puppet_vel.x > 0:
			$Sprite.scale.x = puppet_vel.x  # Flip to the right
		elif puppet_vel.x < 0:
			$Sprite.scale.x = puppet_vel.x  # Flip to the left
	
	# Play animations based on velocity
	if puppet_vel.x != 0 or puppet_vel.y != 0:
		$AnimationPlayer.play("Move")  # Play the "Move" animation when moving
	elif puppet_vel.x == 0 and puppet_vel.y == 0:
		$AnimationPlayer.play("Stop")  # Play the "Stop" animation when stationary

# Update the character's position smoothly using a Tween
func new_puppet_pos(value):
	puppet_pos = value  # Update the puppet position
	tween.interpolate_property(self, "global_position", global_position, puppet_pos, 0.05)  # Interpolate position with a 0.05 second duration
	tween.start()  # Start the animation of the position change
