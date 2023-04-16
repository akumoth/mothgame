# Run.gd
extends PlayerState

func enter(_msg := {}) -> void:
	# change snap length to not fall when going down slopes
	player.floor_snap_length = 16.0
	pass

func physics_update(_delta: float) -> void:
	# transition to air state if falling off 
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
	
	# use the player's calculate_move_velocity function to change our horizontal
	# velocity depending on input
	player.velocity = player.calculate_move_velocity()
	
	# flip sprite if facing left
	if player.direction.x != 0:
		if (player.direction.x > 0 and player.velocity.x > 0):
			player.sprite.scale.x = 1
			player.hurtbox.scale.x = 1
			player.hitbox.scale.x = 1
		elif (player.direction.x < 0 and player.velocity.x < 0):
			player.sprite.scale.x = -1
			player.hurtbox.scale.x = -1
			player.hitbox.scale.x = -1
	
	# implement some kind of buffer system to make the execution for bunnyhopping
	# or long jumping easier
	if Input.is_action_just_pressed("ui_up"):
		state_machine.transition_to("Air", {do_jump = true})
	elif Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")
	elif Input.is_action_pressed("run"):
		state_machine.transition_to("Run")
	elif is_equal_approx(player.direction.x, 0.0) and is_equal_approx(player.velocity.x, 0.0):
		state_machine.transition_to("Idle")
	elif player.ceil_detector.is_colliding():
		state_machine.transition_to('Dash')


