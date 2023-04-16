extends PlayerState


func enter(_msg := {}) -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(_delta: float):

	player.velocity = player.calculate_move_velocity()
	if not owner.is_on_floor():
		state_machine.transition_to("Air")
		return
	if Input.is_action_just_pressed("ui_up"):
		state_machine.transition_to("Air", {do_jump = true})
	elif Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")
	elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		state_machine.transition_to("Walk")
	
