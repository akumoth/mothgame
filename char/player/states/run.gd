extends PlayerState

var initial_dir: int

# Called when the node enters the scene tree for the first time.
func enter(_msg := {}) -> void:
	initial_dir = player.sprite.scale.x
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(_delta: float) -> void:
	# transition to air state if falling off 
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
		
	if abs(player.velocity.x) < 500:
		player.velocity.x += (8 * initial_dir)
	else:
		player.velocity.x += (0.5 * initial_dir)
	if Input.is_action_just_pressed("ui_up"):
		state_machine.transition_to("Air", {do_jump = true})
	elif Input.is_action_just_pressed("dash") or player.ceil_detector.is_colliding():
		state_machine.transition_to("Dash")
	elif player.direction.x == -initial_dir or player.direction.x == 0.0:
		state_machine.transition_to("Skid")
	pass
