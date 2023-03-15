extends PlayerState

var impulse: int
# Called when the node enters the scene tree for the first time.
func enter(msg := {}) -> void:
	# set impulse variable (additional velocity from hops) and, if the player
	# entered this state by inputting a jump, use it to jump higher
	impulse = abs(player.velocity.x) - player._speed.x if floor(abs(player.velocity.x)) > player._speed.x else 0
	if msg.has("do_jump"):
		player.velocity.y = (player._speed.y + ceil(impulse)/2) * player.direction.y
	# change snap length so there's no abrupt halt when falling onto a corner platform
	player.floor_snap_length = 0.1
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta: float):
	# calculates gravity
	player.velocity.y += delta * player.gravity
	# calculates horizontal velocity (to give the player air drift)
	player.velocity = player.calculate_move_velocity()
	# calculates hopping velocity (creates additional horizontal acceleration 
	# while jumping)
	player.velocity = calculate_hop_velocity(player.velocity, player.direction)
	# should the player let go of the jump button, cancel out the jump, and
	# smooth it out by multiplying the velocity by 0.5
	var is_jump_interrupted = Input.is_action_just_released("ui_up") and player.velocity.y < 0.0
	if is_jump_interrupted:
		player.velocity.y *= 0.5
	# transition to gliding state if player presses down
	if Input.is_action_just_pressed("ui_down"):
		state_machine.transition_to("Glide")
	# transition to walking or idle state if player is on floor
	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Walk")
	
	pass

func calculate_hop_velocity(
	velocity,
	direction
	):
	if velocity.y != 0.0:
		velocity.x += player._hop_accel * direction.x
	return velocity
