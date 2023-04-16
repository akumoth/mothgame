extends PlayerState

var impulse: int


# Called when the node enters the scene tree for the first time.
func enter(msg := {}) -> void:
	# use impulse to jump higher
	if msg.has("do_jump"):
		player.velocity.y = (player._speed.y + ceil(player.impulse)/2) * player.direction.y
	if msg.has("do_walljump"):
		player.sprite.scale.x *= -1
		player.velocity = Vector2(
			player.walljump_speed.x*player.sprite.scale.x,
			(player.walljump_speed.y*-1+(player.walljump_counter*-16)) if player.walljump_counter > -2 else -200
			)
		if player.walljump_counter > -2:
			player.walljump_counter -= 1
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
	
	# flip sprite if facing left
	if player.direction.x != 0:
		if player.velocity.x > 0:
			player.sprite.scale.x = 1
			player.hurtbox.scale.x = 1
			player.hitbox.scale.x = 1
		else:
			player.sprite.scale.x = -1
			player.hurtbox.scale.x = -1
			player.hitbox.scale.x = -1
		
	# transition to gliding state if player presses down
	if Input.is_action_just_pressed("ui_down"):
		state_machine.transition_to("Glide")
	# transition to walking or idle state if player is on floor
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
	elif player.ceil_detector.is_colliding():
		state_machine.transition_to('Dash')
	pass

func calculate_hop_velocity(
	velocity,
	direction
	):
	if velocity.y != 0.0:
		velocity.x += (player._hop_accel if abs(velocity.x) > 180 else 40) * direction.x
	return velocity
