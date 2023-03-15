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
	# if 
	glide_angle = (
		(3*PI/5)+(PI * flip_dir)
		if (player.velocity.angle() > -(3*PI)/4 and player.velocity.angle() < -(PI)/4)
		else abs(player.velocity.angle())+(PI/2))
	player.flip_sprite = false
	pass


func physics_update(_delta):
	# calculates gravity
	glide_vel = Vector2(
		player.velocity.length()*sin(glide_angle),
		player.velocity.length()*cos(glide_angle) *-1 + _delta * 
			(player.gravity if glide_vel.length() < 800.0 else 0)
		)
	if glide_vel.y < 0.0:
		glide_vel.y *= 0.99
	if glide_vel.length() < 75.0 or player.direction.x == -initial_dir:
		glide_vel.x *= 0.7
	player.velocity = glide_vel
	glide_dir = get_glide_direction()
	glide_angle = clampf(
		(glide_angle+(glide_dir.y)*0.05*player.sprite.scale.x),
		(PI/6)+(PI * flip_dir),
		((5*PI)/6)+(PI * flip_dir)
		)
	
	if player.is_on_floor():
		player.flip_sprite = true
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Walk")
	
	if glide_vel.length() < 25.0:
		player.flip_sprite = true
		state_machine.transition_to("Air")
	pass

func get_glide_direction():
	# set direction based on current keyboard input
	## (todo: set input keys to something that actually makes sense)
	glide_dir = Vector2(
		0.0,
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	# cancel out direction if the player is about to move towards a wall
	return glide_dir
