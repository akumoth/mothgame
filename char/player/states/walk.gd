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
	

	# implement some kind of buffer system to make the execution for bunnyhopping
	# or long jumping easier
	if Input.is_action_just_pressed("ui_up"):
		state_machine.transition_to("Air", {do_jump = true})
	elif is_equal_approx(player.direction.x, 0.0) and is_equal_approx(player.velocity.x, 0.0):
		state_machine.transition_to("Idle")


