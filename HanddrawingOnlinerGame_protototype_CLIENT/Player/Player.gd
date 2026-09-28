extends KinematicBody2D

# Declare variables
var move_perm = true  # Flag to determine if the character can move
var velocity = Vector2()  # Velocity of the character (used for movement)
var speed = 200  # Movement speed of the character

# Called when the node is ready (initialization)
func _ready():
	reset_character()  # Reset the character (set up its appearance)
	$NameLabel.text = Globals.local_name  # Set the local player's name

# Called every frame during physics updates (used for movement)
func _physics_process(_delta):
	# Get input for movement direction (x and y axes)
	var x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# Normalize the velocity to avoid faster diagonal movement
	velocity = Vector2(x, y).normalized()

	# If movement is allowed, move the character
	if move_perm:
		move_and_slide(velocity * speed)
	else:
		velocity = Vector2.ZERO  # Stop movement if not allowed
	
	# Flip the character sprite based on the movement direction (x-axis)
	if sign(velocity.x) > 0:
		$Sprite.scale.x = abs($Sprite.scale.x)  # Facing right
	elif sign(velocity.x) < 0:
		$Sprite.scale.x = -abs($Sprite.scale.x)  # Facing left

	# Play the appropriate animation based on movement state
	if velocity != Vector2.ZERO:
		$AnimationPlayer.play("Move")  # Play the "Move" animation
	else:
		$AnimationPlayer.play("Stop")  # Play the "Stop" animation when idle

# Reset the character's appearance (set the sprite texture based on the chosen character)
func reset_character():
	$Sprite.texture = load("res://Assets/Player/"+Globals.choosen_character+".png")

# Called when the timer times out (sending position and velocity updates to the server)
func _on_Timer_timeout():
	Server.rpc_unreliable_id(1, "update_transform", global_position, rotation_degrees, velocity)
