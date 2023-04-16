extends PlayerState

var cling_speed = 20
var initial_dir: int

# Called when the node enters the scene tree for the first time.
func enter(_msg := {}) -> void:
	player.floor_snap_length = 0.1
	initial_dir = player.sprite.scale.x
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(_delta):
	player.velocity.y = cling_speed
	if Input.is_action_just_pressed("ui_up"):
		state_machine.transition_to("Air", {do_walljump = true})
	if (player.direction.x == -initial_dir) or (!player.wall_detector[0].has_overlapping_bodies() and !player.wall_detector[1].has_overlapping_bodies()):
		state_machine.transition_to("Air")
	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Walk")
	pass
