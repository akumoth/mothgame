extends PlayerState

var glide_angle: float
var glide_vel: Vector2
var glide_dir: Vector2
var flip_dir: int
var initial_dir: int

func enter(_msg := {}) -> void:
	# initialize the flip_dir and initial_dir variables.
	#
	# the first one is a boolean that tells the rest of the script
	# to adjust all calculated angles by PI when the player is facing left
	#
	# the second one is simply the direction the glide will be performed in,
	# for the sake of letting the player brake by pressing the opposite
	# direction
	flip_dir = (true if player.sprite.scale.x == -1 else false)
	initial_dir = player.sprite.scale.x
	# initialize the glide angle.
	#
	# if the player is currently moving up, and their angle of velocity is 
	# within a narrow 90°-wide cone whose center is in the cardinal north 
	# direction, they will begin gliding with a shallow dive towards the ground
	#
	# otherwise, use the player's current velocity angle 
	glide_angle = (
		(3*PI/5)+(PI * flip_dir)
		if (player.velocity.angle() > -(3*PI)/4 and player.velocity.angle() < -(PI)/4)
		else abs(player.velocity.angle())+(PI/2))
	pass


func physics_update(_delta):
	# calculates the velocity of the glide using the magnitude of the player's
	# current velocity vector and their current angular direction, 
	# applying gravity on their vertical velocity.
	#
	# the player can only accelerate up to 800 total speed this way
	glide_vel = Vector2(
		player.velocity.length()*sin(glide_angle),
		player.velocity.length()*cos(glide_angle) *-1 + _delta * 
			(player.gravity if glide_vel.length() < 800.0 else 0)
		)
	# to avoid players simply building vertical speed indefinitely, we
	# decelerate their velocity when they're moving upwards
	if glide_vel.y < 0.0:
		glide_vel *= 0.9993
	# and if their current speed is too low, they'll brake down to 0 speed, to
	# avoid players getting stuck in the glide state. This will also happen
	# if they're trying to move in a direction opposite from the one their
	# glide is currently facing.
	if glide_vel.length() < 75.0 or player.direction.x == -initial_dir:
		glide_vel.x *= 0.7
	player.velocity = glide_vel
	glide_dir = get_glide_direction()
	# Finally, their glide angle is clamped down to a 120° cone centered in the
	# direction they faced when initiating the glide.
	glide_angle = clampf(
		(glide_angle+(glide_dir.y)*0.05*player.sprite.scale.x),
		(PI/6)+(PI * flip_dir),
		((5*PI)/6)+(PI * flip_dir)
		)
	
	if (
		(player.wall_detector[0].has_overlapping_bodies() 
		and Input.is_action_pressed("ui_left")
		and player.sprite.scale.x < 0) or 
		(player.wall_detector[1].has_overlapping_bodies() 
		and Input.is_action_pressed("ui_right")
		and player.sprite.scale.x > 0)
		):
		state_machine.transition_to("WallCling")
	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Walk")
	
	# if the player's total speed is too low, we force them into the
	# Air state.
	if glide_vel.length() < 30.0 or (player.direction.x == -initial_dir and glide_vel.length() < 75.0):
		state_machine.transition_to("Air")
	pass

func get_glide_direction():
	# change glide direction based on current keyboard input
	## (todo: set input keys to something that actually makes sense)
	glide_dir = Vector2(
		0.0,
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	return glide_dir
